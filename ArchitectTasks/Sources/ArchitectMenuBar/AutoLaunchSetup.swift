import Foundation
import ServiceManagement

// MARK: - Auto Launch Setup

final class AutoLaunchSetup {
    private static let launchAgentLabel = "com.architect.menubar"
    private static let launchAgentFileName = "\(launchAgentLabel).plist"
    
    static func setup() {
        if isLaunchAgentInstalled() {
            return
        }
        
        if createLaunchAgent() {
            loadLaunchAgent()
        } else {
            promptLoginItemsFallback()
        }
    }
    
    // MARK: - Launch Agent
    
    private static func isLaunchAgentInstalled() -> Bool {
        launchAgentPath().path.fileExists()
    }
    
    private static func launchAgentPath() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
            .appendingPathComponent(launchAgentFileName)
    }
    
    private static func createLaunchAgent() -> Bool {
        guard let executablePath = Bundle.main.executablePath else { return false }
        
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(launchAgentLabel)</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(executablePath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <false/>
            <key>ProcessType</key>
            <string>Interactive</string>
        </dict>
        </plist>
        """
        
        let launchAgentsDir = launchAgentPath().deletingLastPathComponent()
        
        do {
            try FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true)
            try plist.write(to: launchAgentPath(), atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Failed to create launch agent: \(error)")
            return false
        }
    }
    
    private static func loadLaunchAgent() {
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["load", launchAgentPath().path]
        task.launch()
    }
    
    // MARK: - Login Items Fallback
    
    private static func promptLoginItemsFallback() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Enable Auto-Launch"
            alert.informativeText = """
            ArchitectTasks needs to launch automatically to monitor Xcode.
            
            Follow these steps:
            1. Click "Open Settings" below
            2. Find "ArchitectTasks" in the list
            3. Toggle it ON
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Skip")
            
            if alert.runModal() == .alertFirstButtonReturn {
                openLoginItemsSettings()
            }
        }
    }
    
    private static func openLoginItemsSettings() {
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.users")!)
        }
    }
}

// MARK: - String Extension

private extension String {
    func fileExists() -> Bool {
        FileManager.default.fileExists(atPath: self)
    }
}
