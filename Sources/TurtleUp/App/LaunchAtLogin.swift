import ServiceManagement

/// 开机自启：SMAppService Login Item（macOS 13+）。
/// 状态以系统为准（用户可在 系统设置 → 通用 → 登录项 →「打开时登录」列表里直接管理），不另存 UserDefaults。
///
/// 为什么无需 helper target / 额外 Info.plist 键：`SMAppService.mainApp` 注册的是主 App 本身，
/// 系统把它列入「登录项 → 打开时登录」（带开关，用户可关）；helper 才会出现在「允许在后台」。
/// 用户在系统设置里关掉后 `status != .enabled`，设置页下次 onAppear 回读即同步。
/// 注意：需以打好的 .app（建议放 /Applications）运行；`swift run` 裸二进制无法注册。
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// 开关自启；失败只记日志（例如 swift run 裸二进制无法注册登录项）
    static func setEnabled(_ enabled: Bool) {
        let service = SMAppService.mainApp
        do {
            if enabled {
                guard service.status != .enabled else { return }
                try service.register()
            } else {
                guard service.status == .enabled else { return }
                try service.unregister()
            }
            DebugLog.log("launchAtLogin \(enabled ? "enabled" : "disabled")")
        } catch {
            DebugLog.log("launchAtLogin setEnabled(\(enabled)) failed: \(error.localizedDescription)")
        }
    }
}
