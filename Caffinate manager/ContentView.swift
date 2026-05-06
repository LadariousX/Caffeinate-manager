import Cocoa
import SwiftUI

@main
struct StayAwakeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { Settings {} }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var caffeinateProcess: Process?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // hides Dock icon

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: nil)
            button.image?.isTemplate = true // matches dark/light mode
        }

        constructMenu()
    }

    func constructMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Activate Caffeinate", action: #selector(toggleCaffeinate(_:)), keyEquivalent: "")
        toggleItem.state = .off
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func toggleCaffeinate(_ sender: NSMenuItem) {
        sender.title = "Activate Caffeinate"

        if sender.state == .off {
            startCaffeinate()
            sender.state = .on
//            sender.title = "Deactivate Caffeinate"
            updateIcon(active: true)
        } else {
            stopCaffeinate()
            sender.state = .off
            updateIcon(active: false)
        }
    }

    func startCaffeinate() {
        let process = Process()
        process.launchPath = "/usr/bin/caffeinate"
        process.arguments = ["-d"]
        process.launch()
        caffeinateProcess = process
    }

    func stopCaffeinate() {
        caffeinateProcess?.terminate()
        caffeinateProcess = nil
    }

    func updateIcon(active: Bool) {
        // When caffeinate is ON  → filled cup
        // When caffeinate is OFF → outline cup
        let symbolName = active ? "cup.and.saucer.fill" : "cup.and.saucer"
        statusItem.button?.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
        statusItem.button?.image?.isTemplate = true
    }



    @objc func quit() {
        stopCaffeinate()
        NSApplication.shared.terminate(nil)
    }
}
