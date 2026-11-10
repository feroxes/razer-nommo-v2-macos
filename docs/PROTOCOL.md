# Nommo V2 USB protocol

These notes describe how Nommo Control talks to a Razer Nommo V2 over USB. Razer doesn't publish this protocol, so everything here was worked out by observing the device and then confirmed on a Nommo V2. Treat it as field notes, not as an official specification.

In the code, the byte layout lives in [`PacketLayout.swift`](../Sources/NommoKit/Protocol/PacketLayout.swift) and the command values in [`CommandCode.swift`](../Sources/NommoKit/Protocol/CommandCode.swift).

## Device

| Property | Value |
| --- | --- |
| USB vendor ID | `0x1532` |
| USB product ID | `0x055C` (Nommo V2) |
| Control interface | The HID interface whose maximum feature report size is at least 90 bytes (interface 0, Consumer usage page `0x0C`) |

The speaker exposes more than one HID interface; only the one above accepts commands. Nommo Control opens it without exclusive access, and macOS asks for no privacy permission.

## Reports

Each command is a HID feature report with report ID `0x07`. A report is 91 bytes long, including the report ID.

| Byte | Content |
| --- | --- |
| 0 | Report ID, `0x07` |
| 1 | Status. Requests send `0x00`; see [Exchange](#exchange) for replies |
| 2 | Transaction ID, always `0x1F` |
| 3–5 | Zero |
| 6 | Data size: how many argument bytes the command uses |
| 7 | Command class |
| 8 | Command ID |
| 9–88 | Arguments, 80 bytes, zero-padded |
| 89 | Checksum: XOR of bytes 3 to 88 |
| 90 | Zero |

Below, `args[n]` means argument byte `n`, which is report byte `9 + n`.

### Exchange

1. Send the request with a feature SetReport, report ID `0x07`.
2. Wait about 3 ms, then fetch the reply with a feature GetReport, report ID `0x07`.
3. A status of `0x00` or `0x01` means the reply isn't ready yet. Wait and fetch again. Nommo Control tries up to 20 times, 3 ms apart. Replies to supported commands come back with `0x02`.
4. The reply repeats the command class and ID, and its arguments hold the result. Depending on the path through macOS, GetReport returns either all 91 bytes or the 90 bytes after the report ID, so a reader should accept both.

**The speaker acknowledges commands that it doesn't apply.** A good status doesn't prove that anything changed, so Nommo Control reads the subwoofer, the equalizer, the brightness and auto power-off back after it writes them. There is no command to read the lighting, so a lighting change can't be confirmed this way.

### Example

Setting the subwoofer to level 2 (class `0x08`, ID `0x07`, size `0x02`, arguments `00 02`) sends:

```text
07 00 1F 00 00 00 02 08 07 00 02 00 … 00 0F 00
```

The checksum `0F` is the XOR of bytes 6 to 10, `02 ^ 08 ^ 07 ^ 00 ^ 02`, because every other byte from 3 to 88 is zero.

## Commands

All values are hexadecimal. Nommo Control sends only the commands in these tables.

### Audio, class `0x08`

| Setting | Write | Read | Notes |
| --- | --- | --- | --- |
| Subwoofer level | ID `07`, size `02`, args `00 L` | ID `87`, size `02`, result in `args[1]` | `L` is 1 to 7. The speaker keeps it while switched off. |
| Equalizer curve | ID `04`, size `0B`, args `00 b1 … b10` | ID `84`, size `0B`, result in `args[1…10]` | Ten bands. Writing a curve also switches the equalizer mode to `10`. The speaker keeps it while switched off. |
| Equalizer mode | – | ID `82`, size `02`, result in `args[1]` | `10` means the custom curve is active. Any other value is one of the speaker's built-in modes. |

Razer Synapse on Windows switches between the built-in modes with ID `02`, size `02`, args `01 M`: `01` is Game, `02` Music and `03` Movie; its Default preset sends nothing. Nommo Control doesn't send this command.

A band byte is the band's level plus `0x0C`. The valid bytes are `00` to `18`, which means levels from −12 to +12. The unit of these levels isn't documented and wasn't measured, so Nommo Control doesn't call them decibels. The app labels the ten bands by octave, from 31 Hz to 16 kHz.

### Lighting, class `0x0F`

| Action | Command | Notes |
| --- | --- | --- |
| Write brightness | ID `04`, size `03`, args `01 00 V` | `V` is 0 to 255. Nommo Control maps 0–100 % onto this range. The speaker keeps it while switched off. |
| Read brightness | ID `84`, size `03`, args `01 00`, result in `args[2]` | |
| Enter frame mode | ID `02`, size `06`, args `00 00 08 00 01` | Stops the built-in animation, so the LEDs show frames sent by the host. |
| Fill frame | ID `03`, size `29`, args `00 00 00 00 0B` followed by 12 × `R G B` | LEDs 0–5 are on the left speaker and 6–11 on the right. The frame stays until the speaker switches off. |
| Resume animation | ID `02`, size `06`, args `00 00 00` | Leaves frame mode, and the built-in Spectrum cycle continues. |

The two lighting modes in the app are built from these commands:

- **Static** enters frame mode, then fills the frame with the chosen color on all 12 LEDs.
- **Spectrum** resumes the animation.

### Power, class `0x07`

| Setting | Write | Read | Notes |
| --- | --- | --- | --- |
| Auto power-off | ID `08`, size `02`, args `00 S` | ID `88`, size `02`, result in `args[1]` | `S` is `01` for on and `00` for off. With it off, the speaker never switches itself off. |
| Power-off delay | ID `03`, size `02`, args `HH LL` | ID `83`, size `02`, result in `args[0…1]` | Seconds of silence, big-endian. The speaker accepts only `0384` (15 min), `0708` (30 min) and `0A8C` (45 min) and ignores any other value. |

The speaker keeps both settings while switched off.

## Power behavior

- With auto power-off on, the speaker switches itself off after the power-off delay of silence (15 minutes by default) and disappears from USB.
- When it is switched on again, it appears as a new HID device and runs its built-in animation. The subwoofer level, the equalizer, the brightness and auto power-off survive; the lighting mode doesn't. That's why Nommo Control applies the saved lighting every time the speaker connects.
- The first reads right after power-on can fail. Nommo Control tries to read the state up to three times, 0.5 s apart.
- Some unknown read commands take about 5 seconds to time out.

## Commands that don't work

These were tried on a Nommo V2. Nommo Control doesn't send any of them.

- The lighting effect command (class `0x0F`, ID `02`) with args `00 00 01 …` (static) or `00 00 02 …` (breathing) shows the color only for a moment, and then the built-in animation takes over again.
- Args `00 00 03` and `01 00 03` for the same command don't leave frame mode.
- Device mode (class `0x00`, ID `04`) changes nothing.
- Power-off delays other than 15, 30 and 45 minutes (class `0x07`, ID `03`) are ignored.

## References

The general structure of Razer HID reports, such as the transaction ID, the data size and the XOR checksum, is documented by the open-source [OpenRazer](https://github.com/openrazer/openrazer) project, and [SignalRGB](https://signalrgb.com) device support served as a further reference. Nommo Control contains no code from either project, and the Nommo V2 details on this page were confirmed on the device itself.
