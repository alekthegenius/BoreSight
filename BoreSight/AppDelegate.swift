//
//  AppDelegate.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/5/25.
//

import Foundation
import Cocoa
import SwiftUI
import ApplicationServices
import KeyboardShortcuts
import ScreenCaptureKit
import CoreVideo

class AppDelegate: NSObject, NSApplicationDelegate {
    var boreSightWindow: NSWindow?
    var settingsWindow: NSWindow?
    var statusWindow: NSWindow?
    
    var lastBorderState: Bool = false
    var lastGapState: Bool = false
    var lastCrosshairState: Bool = false
    
    private var statusItem: NSStatusItem!
    
    var lastWindowState: Bool? = nil
    
    var mouseMonitor: CADisplayLink? = nil
    
    var boreSightLocked: Bool = false
    
    let model = CrosshairModel()
    
    var suspendMouseUpdates = false
    
    var activeCaptureDisplay: SCDisplay?
    
    var boreSightEnabled: Bool = true
    
    var currentScreen: NSScreen?
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        

        
        KeyboardShortcuts.onKeyDown(for: .toggleBoreSight) { [self] in
            self.toggleBoreSightWindow()
        }
        
        KeyboardShortcuts.onKeyDown(for: .toggleLockedBoreSight) { [self] in
            self.toggleLockedBoreSight()
        }
        
        KeyboardShortcuts.onKeyDown(for: .toggleCrosshairs) { [self] in
            self.toggleCrosshairs()
        }
        
        KeyboardShortcuts.onKeyDown(for: .toggleMouseCoordinates) { [self] in
            self.toggleMouseCoordinatesWindow()
        }
        
        
        KeyboardShortcuts.onKeyDown(for: .copyMouseCoordinates) { [self] in
            self.copyMouseCoordinatesToClipboard()
        }
        
        KeyboardShortcuts.onKeyDown(for: .toggleMouseOrigin) { [self] in
            self.toggleMouseOrigin()
        }
        
        
        
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "scope", accessibilityDescription: "1")
        }
        
        setupMenus()
        
        createBoreSightWindow()
        

    }
    
    func applicationWillTerminate(_ notification: Notification) {
        deinitMouseMonitor()
        destroyBoreSightWindow()
        
    }
    
    func createBoreSightWindow() {
        guard let screen = model.getTargetScreen() else { return }
        
        if boreSightWindow == nil {
            self.model.currentScreenSize = screen.frame.size
            boreSightWindow = NSWindow(
                    contentRect: screen.frame,
                    styleMask: [.borderless],
                    backing: .buffered,
                    defer: false
                )
            
            boreSightWindow?.title = "BoreSight"
            boreSightWindow?.ignoresMouseEvents = true
            
            
            
            
            let crosshairView = FullScreenCrosshairs(model: model)
            boreSightWindow?.contentView = NSHostingView(rootView: crosshairView)
            boreSightWindow?.collectionBehavior = [.canJoinAllSpaces]
            boreSightWindow?.level = .screenSaver
            boreSightWindow?.isOpaque = false
            boreSightWindow?.backgroundColor = .clear
            boreSightWindow?.hasShadow = false
            boreSightWindow?.orderFrontRegardless()

            
            showBoreSightWindow()
        }
            
       
    }
    
    func createSettingsWindow() {
        
        settingsWindow = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
                        styleMask: [.miniaturizable, .closable, .titled],
                        backing: .buffered,
                        defer: false,
                        screen: .main
            )
        
        settingsWindow?.isReleasedWhenClosed = false
        settingsWindow?.titleVisibility = .visible
        settingsWindow?.titlebarAppearsTransparent = true
        
        let settingsView = SettingsView(model: model, appDelegate: self)
        let settingsHostingView = NSHostingView(rootView: settingsView)
        
        settingsWindow?.delegate = self
        settingsWindow?.level = .normal
        
        
        settingsWindow?.contentView = settingsHostingView
        settingsWindow?.collectionBehavior = [.managed]
        settingsWindow?.orderFrontRegardless()
        

        
    }
    
    func showStatusWindow(message: String, duration: TimeInterval = 2) {
        guard let screen = NSScreen.main else { return }

        if let existing = statusWindow {
           existing.orderOut(nil)
           statusWindow = nil
       }

        let width: CGFloat = 200
        let height: CGFloat = 50
        let rect = NSRect(
            x: screen.frame.midX - width / 2,
            y: 75,
            width: width,
            height: height
        )

        statusWindow = NSWindow(
            contentRect: rect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        statusWindow?.level = .screenSaver
        statusWindow?.isOpaque = false
        statusWindow?.hasShadow = true
        statusWindow?.ignoresMouseEvents = true
        statusWindow?.alphaValue = 0
        

        // Label for the message
        let label = NSTextField(labelWithString: message)
        label.alignment = .center
        label.font = NSFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false

        let contentView = NSView(frame: rect)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        statusWindow?.backgroundColor = .clear
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        contentView.layer?.cornerRadius = 10
        contentView.layer?.masksToBounds = true
        
        statusWindow?.contentView = contentView
        statusWindow?.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
               context.duration = 0.25
               statusWindow?.animator().alphaValue = 1
           }

       // Fade out after delay
       DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
           guard let self = self, let window = self.statusWindow else { return }
           NSAnimationContext.runAnimationGroup { context in
               context.duration = 0.25
               window.animator().alphaValue = 0
           } completionHandler: {
               window.orderOut(nil)
               if self.statusWindow === window { self.statusWindow = nil }
           }
       }
    }
    
    @objc func showSettingsWindow(_ sender: NSMenuItem?) {
        
        
        
        if model.hideBoreSightWhenSettingsOpen && boreSightEnabled {
            lastWindowState = true
            hideBoreSightWindow()
        } else if model.hideBoreSightWhenSettingsOpen && !boreSightEnabled {
            lastWindowState = nil
        }
        

        
        createSettingsWindow()
        
        settingsWindow?.center()
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        if sender?.title == "About BoreSight" {
                model.activeSettingsTab = .about
            }
        
        updateBoreSightMenuItem()
    }
    
    @objc func toggleMouseOrigin() {
        model.mouseOriginShown.toggle()
        updateMouseOriginMenuItem()
    }
    
    func enableOverlayEditing(_ enabled: Bool) {
        boreSightWindow?.ignoresMouseEvents = !enabled
    }
    
    
    func hideBoreSightWindow() {
        boreSightEnabled = false
        if !model.keepBoreSightLocked {
            boreSightLocked = false
        }
        
        suspendMouseUpdates = true
        boreSightWindow?.orderOut(nil)
        updateBoreSightMenuItem()
        updateLockMenuItem()
    }
    
    func showBoreSightWindow() {
        if mouseMonitor == nil {
            initalizeMouseMonitor()
        }
        
        suspendMouseUpdates = false
        
        boreSightEnabled = true
        
        if !model.keepBoreSightLocked {
            boreSightLocked = false
        }
        
        if boreSightWindow == nil {
            createBoreSightWindow()
        }
        

        boreSightWindow?.makeKeyAndOrderFront(nil)
        updateBoreSightMenuItem()
        updateLockMenuItem()
    }
    
    
    
    
    func initalizeMouseMonitor() {
    
        
        guard let window = boreSightWindow else {
            return
        }
        
        currentScreen = model.getTargetScreen()
        
        mouseMonitor = window.displayLink(target: self, selector: #selector(updateMouseLocation))
        
        
        
        
        
        mouseMonitor?.add(to: .current, forMode: .common)
        
    }
    
    @objc func updateMouseLocation() {
        
        
        guard !suspendMouseUpdates else { return }
        
        if !boreSightLocked,
           let r = model.currentScreenAndLocalMousePoint() {
            model.mouseLocation = r.localPoint
        
            switch model.displayMode {
            case .followCursor:
                if currentScreen != r.screen {
                    currentScreen = r.screen
                    model.currentScreenSize = r.screen.frame.size
                    model.mouseOriginPosition = .init(x: r.screen.frame.width / 2, y: r.screen.frame.height / 2)
                    boreSightWindow?.setFrame(r.screen.frame, display: true)
                }
                
            case .fixedScreen:
                let fixedIndex = self.model.fixedScreenIndex
                guard fixedIndex < NSScreen.screens.count else { return }

                let screen = NSScreen.screens[fixedIndex]
                let mouseLocation = NSEvent.mouseLocation
                var adjustedFrame = screen.frame
                
                adjustedFrame.origin.y -= 0      // leave bottom unchanged
                if let bottomScreen = NSScreen.screens.min(by: { $0.frame.origin.y < $1.frame.origin.y }),
                   screen == bottomScreen {
                    adjustedFrame.size.height -= 2  // shrink top edge by 1
                }
                
                let isMouseOnScreen = adjustedFrame.insetBy(dx: -1, dy: -1).contains(mouseLocation)
                
                if isMouseOnScreen {
                    boreSightWindow?.alphaValue = 1.0
                } else {
                    boreSightWindow?.alphaValue = 0.0
                }
                
                self.updateBoreSightMenuItem()
            }
            
        }
    }
        
    func deinitMouseMonitor() {
        mouseMonitor?.invalidate()
        mouseMonitor = nil
    }
    
    @MainActor func setupMenus() {
        // 1
        let menu = NSMenu()

        // 2
        let toggleBoreSightVisibility = NSMenuItem(title: boreSightEnabled ? "Hide BoreSight" : "Show BoreSight", action: #selector(toggleBoreSightWindow) , keyEquivalent: "")
        menu.addItem(toggleBoreSightVisibility)
        

        let lockBoreSight = NSMenuItem(title: boreSightLocked ? "Unlock BoreSight" : "Lock BoreSight", action: #selector(toggleLockedBoreSight) , keyEquivalent: "")
        menu.addItem(lockBoreSight)
        
        menu.addItem(NSMenuItem.separator())
        
        let toggleCrosshairVisibility = NSMenuItem(title: model.crossHairsShown ? "Hide Crosshairs" : "Show Crosshairs", action: #selector(toggleCrosshairs) , keyEquivalent: "")
        menu.addItem(toggleCrosshairVisibility)
        
        
        menu.addItem(NSMenuItem.separator())
        
        let copyMouseCoordinates = NSMenuItem(title: "Copy Mouse Coordinates", action: #selector(copyMouseCoordinatesToClipboard) , keyEquivalent: "")
        menu.addItem(copyMouseCoordinates)
        
        let toggleMouseCoordinatesVisibility = NSMenuItem(title: model.mouseCoordinatesText ? "Hide Mouse Coordinates" : "Show Mouse Coordinates", action: #selector(toggleMouseCoordinatesWindow) , keyEquivalent: "")
        menu.addItem(toggleMouseCoordinatesVisibility)

        menu.addItem(NSMenuItem.separator())

        let toggleMouseOrigin = NSMenuItem(title: model.mouseOriginShown ? "Hide Mouse Origin" : "Show Mouse Origin", action: #selector(toggleMouseOrigin) , keyEquivalent: "")
        menu.addItem(toggleMouseOrigin)
        
        menu.addItem(NSMenuItem.separator())

        let aboutBoreSight = NSMenuItem(title: "About BoreSight", action: #selector(showSettingsWindow) , keyEquivalent: "")
        menu.addItem(aboutBoreSight)

        let settingsButton = NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow) , keyEquivalent: "")
        menu.addItem(settingsButton)


        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // 3
        statusItem.menu = menu
        updateMenuShortcutDisplay()
    }
    
    @MainActor
    func updateMenuShortcutDisplay() -> Void {
        guard let menu = statusItem.menu else { return }
        
        if let boreSightShortcut = KeyboardShortcuts.getShortcut(for: .toggleBoreSight),
           let equivalent = boreSightShortcut.nsMenuItemKeyEquivalent,
           let menuItem = menu.items.first(where: { $0.action == #selector(toggleBoreSightWindow) }) {
            menuItem.keyEquivalent = equivalent
            menuItem.keyEquivalentModifierMask = boreSightShortcut.modifiers
        }
        
        if let lockingShortcut = KeyboardShortcuts.getShortcut(for: .toggleLockedBoreSight),
           let equivalent = lockingShortcut.nsMenuItemKeyEquivalent,
           let menuItem = menu.items.first(where: { $0.action == #selector(toggleLockedBoreSight) }) {
            menuItem.keyEquivalent = equivalent
            menuItem.keyEquivalentModifierMask = lockingShortcut.modifiers
        }
        
        if let crossHairsShortcut = KeyboardShortcuts.getShortcut(for: .toggleCrosshairs),
           let equivalent = crossHairsShortcut.nsMenuItemKeyEquivalent,
           let menuItem = menu.items.first(where: { $0.action == #selector(toggleCrosshairs) }) {
            menuItem.keyEquivalent = equivalent
            menuItem.keyEquivalentModifierMask = crossHairsShortcut.modifiers
        }
        
        if let copyCoordinatesShortcut = KeyboardShortcuts.getShortcut(for: .copyMouseCoordinates),
           let equivalent = copyCoordinatesShortcut.nsMenuItemKeyEquivalent,
           let menuItem = menu.items.first(where: { $0.action == #selector(copyMouseCoordinatesToClipboard) }) {
            menuItem.keyEquivalent = equivalent
            menuItem.keyEquivalentModifierMask = copyCoordinatesShortcut.modifiers
        }
        
        if let mouseCoordinateShortcut = KeyboardShortcuts.getShortcut(for: .toggleMouseCoordinates),
           let equivalent = mouseCoordinateShortcut.nsMenuItemKeyEquivalent,
           let menuItem = menu.items.first(where: { $0.action == #selector(toggleMouseCoordinatesWindow) }) {
            menuItem.keyEquivalent = equivalent
            menuItem.keyEquivalentModifierMask = mouseCoordinateShortcut.modifiers
        }
        
        if let mouseOriginShortcut = KeyboardShortcuts.getShortcut(for: .toggleMouseOrigin),
           let equivalent = mouseOriginShortcut.nsMenuItemKeyEquivalent,
           let menuItem = menu.items.first(where: { $0.action == #selector(toggleMouseOrigin) }) {
            menuItem.keyEquivalent = equivalent
            menuItem.keyEquivalentModifierMask = mouseOriginShortcut.modifiers
        }
        
        
    }
    

    
    
    @objc func toggleCrosshairs() {
        let anyVisible = model.crossHairsShown || model.borderOn || model.gapShown
        if anyVisible {
            // Currently ON → going OFF
            // Save current states
            lastBorderState = model.borderOn
            lastGapState = model.gapShown
            lastCrosshairState = model.crossHairsShown

            // Hide all together
            model.crossHairsShown = false
            model.borderOn = false
            model.gapShown = false
       } else {
           
           // Restore previous states
           model.borderOn = lastBorderState
           model.gapShown = lastGapState
           model.crossHairsShown = lastCrosshairState
       }
        
        updateCrosshairsMenuItem()
        
    }
    
    
    @objc func toggleBoreSightWindow() {
        
        if boreSightEnabled {
            // If currently enabled, always hide
            hideBoreSightWindow()
            
            
            
            
       } else {
           // Only show if user explicitly wants it
           showBoreSightWindow()
       }
        

        
    }
    
    @objc func toggleMouseCoordinatesWindow() {
        if model.mouseCoordinatesText {
            model.mouseCoordinatesText = false
        } else {
            model.mouseCoordinatesText = true
        }
        
        
        updateMouseCoordinateMenuItem()
        
    }
    
    func destroyBoreSightWindow() {
        boreSightWindow?.close()
        boreSightWindow = nil
        
        settingsWindow?.close()
        settingsWindow = nil
    }
    
    @objc func toggleLockedBoreSight() {
        boreSightLocked.toggle()
        updateLockMenuItem()
        
        if model.showingAlerts {
            showStatusWindow(message: boreSightLocked ? "BoreSight Locked" : "BoreSight Unlocked")
        }
    }
    
    @objc func copyMouseCoordinatesToClipboard() {
        
        if model.mouseOriginShown {
            
            
            if let distX = model.calculateDistance().first,
               let distY = model.calculateDistance().last {
                let coordinateText =  String(format: "(x: %.2f, y: %.2f, θ: %.2f)", distX, distY, model.calculateTheta().degrees)
                copyToClipboard(coordinateText)
            } else {
                let coordinateText =  String(format: "(x: %.2f, y: %.2f)", model.mouseLocation.x, model.mouseLocation.y)
                copyToClipboard(coordinateText)
            }
        
            
            
        } else {
            let coordinateText =  String(format: "(x: %.2f, y: %.2f)", model.mouseLocation.x, model.mouseLocation.y)
            copyToClipboard(coordinateText)
        }
        
        
        
        if model.showingAlerts {
            showStatusWindow(message: "Copied to Clipboard")
        }
    }
    
    func copyToClipboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
    
    
    
    func updateBoreSightMenuItem() {
        if let menu = statusItem.menu,
           let boreSightMenuItem = menu.items.first(where: { $0.action == #selector(toggleBoreSightWindow) }) {
            boreSightMenuItem.title = boreSightEnabled ? "Hide BoreSight" : "Show BoreSight"
        }
    }
    
    func updateLockMenuItem() {
        if let menu = statusItem.menu,
           let lockMenuItem = menu.items.first(where: { $0.action == #selector(toggleLockedBoreSight) }) {
            lockMenuItem.title = boreSightLocked ? "Unlock BoreSight" : "Lock BoreSight"
        }
    }
    
    func updateMouseCoordinateMenuItem() {
        if let menu = statusItem.menu,
           let mouseCoordinatesMenuItem = menu.items.first(where: { $0.action == #selector(toggleMouseCoordinatesWindow) }) {
            mouseCoordinatesMenuItem.title = model.mouseCoordinatesText ? "Hide Mouse Coordinates" : "Show Mouse Coordinates"
        }
    }
    
    func updateCrosshairsMenuItem() {
        if let menu = statusItem.menu,
           let crossHairMenuItem = menu.items.first(where: { $0.action == #selector(toggleCrosshairs) }) {
            let anyVisible = model.crossHairsShown || model.borderOn || model.gapShown
            crossHairMenuItem.title = anyVisible ? "Hide Crosshairs" : "Show Crosshairs"
        }
    }
    
    func updateMouseOriginMenuItem() {
        if let menu = statusItem.menu,
           let mouseOriginMenuItem = menu.items.first(where: { $0.action == #selector(toggleMouseOrigin) }) {
            mouseOriginMenuItem.title = model.mouseOriginShown ? "Hide Mouse Origin" : "Show Mouse Origin"
        }
    }
    
    
    func changingFixedScreen() {
        let index = model.fixedScreenIndex
        guard index < NSScreen.screens.count else { return }
        let screen = NSScreen.screens[index]
        
        
        model.currentScreenSize = screen.frame.size
        
        model.mouseOriginPosition = .init(x: screen.frame.width / 2, y: screen.frame.height / 2)
        
        boreSightWindow?.setFrame(screen.frame, display: true)
        
    }
    
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let w = notification.object as? NSWindow, w == settingsWindow {
            settingsWindow = nil
            

            if let lastState = lastWindowState, lastState && !boreSightEnabled {
                lastWindowState = nil
                showBoreSightWindow()
            }
            
        }
        
    }

    
}

