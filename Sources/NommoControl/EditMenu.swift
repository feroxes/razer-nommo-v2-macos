import AppKit

enum EditMenu {
    private enum Key {
        static let undo = "z"
        static let redo = "Z"
        static let cut = "x"
        static let copy = "c"
        static let paste = "v"
        static let selectAll = "a"
    }

    private enum Action {
        static let undo = Selector(("undo:"))
        static let redo = Selector(("redo:"))
    }

    @MainActor
    static func makeMainMenu() -> NSMenu {
        let edit = NSMenu(title: Strings.edit)
        edit.addItem(withTitle: Strings.undo, action: Action.undo, keyEquivalent: Key.undo)
        edit.addItem(withTitle: Strings.redo, action: Action.redo, keyEquivalent: Key.redo)
        edit.addItem(.separator())
        edit.addItem(withTitle: Strings.cut, action: #selector(NSText.cut(_:)), keyEquivalent: Key.cut)
        edit.addItem(withTitle: Strings.copy, action: #selector(NSText.copy(_:)), keyEquivalent: Key.copy)
        edit.addItem(withTitle: Strings.paste, action: #selector(NSText.paste(_:)), keyEquivalent: Key.paste)
        edit.addItem(withTitle: Strings.selectAll, action: #selector(NSText.selectAll(_:)), keyEquivalent: Key.selectAll)
        let item = NSMenuItem()
        item.submenu = edit
        let menu = NSMenu()
        menu.addItem(item)
        return menu
    }
}
