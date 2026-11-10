struct PanelActions {
    let showAbout: @MainActor () -> Void
    let checkForUpdates: @MainActor () -> Void
    let donate: @MainActor () -> Void
    let quit: @MainActor () -> Void
}
