#!/usr/bin/env swift

import Foundation
import AppKit

// MARK: - Installer

class ExtensionInstaller {
    func run() {
        print("🔨 ArchitectTasks Xcode Extension Installer")
        print("===========================================\n")
        
        // Step 1: Build
        guard build() else {
            showError("Build failed")
            return
        }
        
        // Step 2: Install
        guard install() else {
            showError("Installation failed")
            return
        }
        
        // Step 3: Guide user
        showSuccessAndOpenSettings()
    }
    
    private func build() -> Bool {
        print("📦 Building extension...")
        
        let task = Process()
        task.launchPath = "/usr/bin/xcodebuild"
        task.arguments = [
            "-scheme", "ArchitectXcodeExtension",
            "-configuration", "Release",
            "-derivedDataPath", ".build"
        ]
        
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus == 0 {
            print("✅ Build complete\n")
            return true
        }
        return false
    }
    
    private func install() -> Bool {
        print("📂 Installing to /Applications...")
        
        let fm = FileManager.default
        let buildPath = ".build"
        
        // Find app
        guard let appPath = findApp(in: buildPath) else {
            print("❌ App not found in build output")
            return false
        }
        
        let destination = "/Applications/ArchitectTasks.app"
        
        // Remove existing
        if fm.fileExists(atPath: destination) {
            try? fm.removeItem(atPath: destination)
        }
        
        // Copy with elevated privileges
        let script = "do shell script \"cp -r '\(appPath)' '\(destination)'\" with administrator privileges"
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            
            if error == nil {
                print("✅ Installed to \(destination)\n")
                return true
            }
        }
        
        return false
    }
    
    private func findApp(in path: String) -> String? {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(atPath: path) else { return nil }
        
        while let file = enumerator.nextObject() as? String {
            if file.hasSuffix("ArchitectTasks.app") {
                return "\(path)/\(file)"
            }
        }
        return nil
    }
    
    private func showSuccessAndOpenSettings() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Installation Complete! ✨"
            alert.informativeText = """
            Next steps:
            
            1. Click "Open Settings" below
            2. Check ✓ ArchitectTasks in the list
            3. Restart Xcode if running
            4. Access via Editor > ArchitectTasks
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open Settings")
            alert.addButton(withTitle: "Done")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.extensions?Xcode Source Editor")!)
            }
            
            exit(0)
        }
        
        RunLoop.main.run()
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Installation Failed"
            alert.informativeText = message
            alert.alertStyle = .critical
            alert.runModal()
            exit(1)
        }
        
        RunLoop.main.run()
    }
}

// Run installer
ExtensionInstaller().run()
