//
//  CrosshairModel.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/7/25.
//

import Foundation
import SwiftUI


enum SettingsTab {
    case appearance
    case control
    case shortcuts
    case about
}

enum GapType: String, CaseIterable {
    case none
    case square
    case circle
}

enum CrosshairDisplayMode: String, CaseIterable {
    case followCursor
    case fixedScreen
}

enum MouseCoordinateTextPosition: String, CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}


class CrosshairModel: ObservableObject {
    let defaults = UserDefaults.standard
    
    @Published var mouseLocation: CGPoint = .zero
    @Published var activeSettingsTab: SettingsTab = .appearance
    @Published var currentScreenSize: CGSize = .zero

    
    @Published var showingAlerts: Bool = true {
        didSet {
            defaults.set(showingAlerts, forKey: "showingAlerts")
        }
    }
    
    @Published var mouseCoordinatesText: Bool = true {
        didSet {
            defaults.set(mouseCoordinatesText, forKey: "mouseCoordinatesText")
            DispatchQueue.main.async {

                
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.updateMouseCoordinateMenuItem()
                }
            }
        }
        
    }
    
    @Published var crossHairsShown: Bool = true {
        didSet {
            defaults.set(crossHairsShown, forKey: "crossHairsShown")
            DispatchQueue.main.async {

                
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.updateCrosshairsMenuItem()
                }
            }
        }
    }
    
    @Published var gapShown: Bool = true {
        didSet {
            defaults.set(gapShown, forKey: "gapShown")
            
        }
    }
    
    @Published var borderOn: Bool = true {
        didSet {
            defaults.set(borderOn, forKey: "borderOn")
        }
    }
    
    
    
    @Published var hideBoreSightWhenSettingsOpen: Bool = true {
        didSet {
            defaults.set(hideBoreSightWhenSettingsOpen, forKey: "hideBoreSightWhenSettingsOpen")
            DispatchQueue.main.async {

                
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    if !self.hideBoreSightWhenSettingsOpen {
                        appDelegate.lastWindowState = nil
                    }
                }
            }
        }
    }
    
    
    @Published var keepBoreSightLocked: Bool = true {
        didSet {
            defaults.set(keepBoreSightLocked, forKey: "keepBoreSightLocked")
            DispatchQueue.main.async {

                
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    print("Locked? \(appDelegate.boreSightLocked)")
                    if !self.keepBoreSightLocked && !appDelegate.boreSightEnabled {
                        
                        appDelegate.boreSightLocked = false
                    }
                    
                    appDelegate.updateLockMenuItem()
                }
            }
        }
    }

    
    @Published var displayMode: CrosshairDisplayMode = .followCursor {
        didSet {
            defaults.set(displayMode.rawValue, forKey: "displayMode")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let appDelegate = NSApp.delegate as? AppDelegate,
                  let targetScreen = self.getTargetScreen() {
                   // Update model size
                    appDelegate.boreSightWindow?.setFrame(targetScreen.frame, display: true)
               }
            }
        
        }
    }
    
    var isAutomaticDisplay: Bool {
        get { displayMode == .followCursor }
        set { displayMode = newValue ? .followCursor : .fixedScreen }
    }
    
    @Published var fixedScreenIndex: Int = 0 {
        didSet {
            defaults.set(fixedScreenIndex, forKey: "fixedScreenIndex")

        }
    }
    
    
    
    @Published var gapSize: Double = 30 {
        didSet {
            defaults.set(gapSize, forKey: "gapSize")
        }
    }
    
    @Published var gapType: GapType = .none {
        didSet {
            defaults.set(gapType.rawValue, forKey: "gapType")
        }
    }
    
    @Published var gapBorderThickness: Double = 1 {
        didSet {
            defaults.set(gapBorderThickness, forKey: "gapBorderThickness")
        }
    }
    
    @Published var gapBorderColor: Color = .white {
        didSet {
            defaults.setColor(gapBorderColor, forKey: "gapBorderColor")
        }
    }
    
    @Published var gapBorderTransparency: Double = 1.0 {
        didSet {
            defaults.set(gapBorderTransparency, forKey: "gapBorderTransparency")
        }
    }
    
    
    
    @Published var borderThickness: Double = 1 {
        didSet {
            defaults.set(borderThickness, forKey: "borderThickness")
        }
    }
    
    @Published var borderColor: Color = .white {
        didSet {
            defaults.setColor(borderColor, forKey: "borderColor")
        }
    }
    
    @Published var borderTransparency: Double = 1.0 {
        didSet {
            defaults.set(borderTransparency, forKey: "borderTransparency")
        }
    }
    
    
    
    @Published var mouseCoordinatesTextOffset: CGFloat = 0 {
        didSet {
            defaults.set(mouseCoordinatesTextOffset, forKey: "mouseCoordinatesTextOffset")
        }
    }
    
    
    
    @Published var mouseCoordinatesTextPosition: MouseCoordinateTextPosition = .bottomRight {
        didSet {
            defaults.set(mouseCoordinatesTextPosition.rawValue, forKey: "mouseCoordinatesText")
        }
    }
    
    @Published var mouseCoordinatesTextZoom: Double = 0 {
        didSet {
            defaults.set(mouseCoordinatesTextZoom, forKey: "mouseCoordinatesTextZoom")
        }
    }
    
    @Published var crossHairColor: Color = .red {
        didSet {
            defaults.setColor(crossHairColor, forKey: "crossHairColor")
        }
    }
    
    @Published var crossHairWidth: Double = 2 {
        didSet {
            defaults.set(crossHairWidth, forKey: "crossHairWidth")
        }
    }
    
    @Published var crossHairTransparency: Double = 1.0 {
        didSet {
            defaults.set(crossHairTransparency, forKey: "crossHairTransparency")
        }
    }
    
    init() {
        if defaults.object(forKey: "showingAlerts") != nil {
            self.showingAlerts = defaults.bool(forKey: "showingAlerts")
        }
        
        if defaults.object(forKey: "mouseCoordinatesText") != nil{
            self.mouseCoordinatesText = defaults.bool(forKey: "mouseCoordinatesText")
        }
        
        if defaults.object(forKey: "crossHairsShown") != nil {
            self.crossHairsShown = defaults.bool(forKey: "crossHairsShown")
        }
        
        if defaults.object(forKey: "gapShown") != nil {
            self.gapShown = defaults.bool(forKey: "gapShown")
        }
        
        if defaults.object(forKey: "borderOn") != nil {
               self.borderOn = defaults.bool(forKey: "borderOn")
        }
        
        
        
        
        if let raw = defaults.string(forKey: "displayMode"),
           let mode = CrosshairDisplayMode(rawValue: raw) {
                self.displayMode = mode
        }
        
        if defaults.object(forKey: "fixedScreenIndex") != nil {
           self.fixedScreenIndex = defaults.integer(forKey: "fixedScreenIndex")
            
        }
        
        if defaults.object(forKey: "hideBoreSightWhenSettingsOpen") != nil {
            self.hideBoreSightWhenSettingsOpen = defaults.bool(forKey: "hideBoreSightWhenSettingsOpen")
        }
        
        if defaults.object(forKey: "keepBoreSightLocked") != nil {
            self.keepBoreSightLocked = defaults.bool(forKey: "keepBoreSightLocked")
        }
        
        if defaults.object(forKey: "gapSize") != nil {
            self.gapSize = defaults.double(forKey: "gapSize")
        }
        
        if let raw = defaults.string(forKey: "gapType"),
           let type = GapType(rawValue: raw) {
                self.gapType = type
        }
        
        if defaults.object(forKey: "gapBorderThickness") != nil {
            self.gapBorderThickness = defaults.double(forKey: "gapBorderThickness")
        }
            
        if defaults.object(forKey: "gapBorderColor") != nil {
            if let color = defaults.color(forKey: "gapBorderColor") {
                self.gapBorderColor = Color(color)
            }
        }
        
        if defaults.object(forKey: "gapBorderTransparency") != nil {
            self.gapBorderTransparency = defaults.double(forKey: "gapBorderTransparency")
        }
        
        
        
        if defaults.object(forKey: "borderThickness") != nil {
           self.borderThickness = defaults.double(forKey: "borderThickness")
        }

        if defaults.object(forKey: "borderColor") != nil {
            if let color = defaults.color(forKey: "borderColor") {
                self.borderColor = Color(color)
            }
        }

        if defaults.object(forKey: "borderTransparency") != nil {
           self.borderTransparency = defaults.double(forKey: "borderTransparency")
        }
        
        
        if defaults.object(forKey: "mouseCoordinatesTextOffset") != nil {
            self.mouseCoordinatesTextOffset = defaults.double(forKey: "mouseCoordinatesTextOffset")
        }
        
        if let raw = defaults.string(forKey: "mouseCoordinatesTextPosition"),
           let type = MouseCoordinateTextPosition(rawValue: raw) {
            self.mouseCoordinatesTextPosition = type
        }
        
        if defaults.object(forKey: "mouseCoordinatesTextZoom") != nil {
            self.mouseCoordinatesTextZoom = defaults.double(forKey: "mouseCoordinatesTextZoom")
        }
        
        // Crosshair
        if defaults.object(forKey: "crossHairColor") != nil {
            if let color = defaults.color(forKey: "crossHairColor") {
                self.crossHairColor = Color(color)
            }
            
        }

        if defaults.object(forKey: "crossHairWidth") != nil {
           self.crossHairWidth = defaults.double(forKey: "crossHairWidth")
        }

        if defaults.object(forKey: "crossHairTransparency") != nil {
           self.crossHairTransparency = defaults.double(forKey: "crossHairTransparency")
       }
    }
    
    public func resetAppearance() {
        self.gapShown = true
        self.gapSize = 30
        self.gapType = .none
        self.gapBorderColor = .white
        self.gapBorderThickness = 1
        self.gapBorderTransparency = 1.0
        
        self.borderOn = true
        self.borderThickness = 1
        self.borderColor = .white
        self.borderTransparency = 1.0
        
        self.crossHairsShown = true
        self.crossHairColor = .red
        self.crossHairWidth = 2
        self.crossHairTransparency = 1.0
        
        self.mouseCoordinatesText = true
        self.mouseCoordinatesTextOffset = 0
        self.mouseCoordinatesTextZoom = 0
        self.mouseCoordinatesTextPosition = .bottomRight
        
    }
    
    func getTargetScreen() -> NSScreen? {
        switch displayMode {
        case .followCursor:
            let p = NSEvent.mouseLocation
            // Use a tiny inset to handle “edge” float rounding, 'Cause AI said So
            for s in NSScreen.screens {
                if s.frame.insetBy(dx: -1, dy: -1).contains(p) { return s }
            }
            return NSScreen.main
        case .fixedScreen:
            if NSScreen.screens.indices.contains(fixedScreenIndex) {
                return NSScreen.screens[fixedScreenIndex]
            }
            
            return NSScreen.main
        }
    }
    
    func currentScreenAndLocalMousePoint() -> (screen: NSScreen, localPoint: CGPoint)? {
        let global = NSEvent.mouseLocation
        for s in NSScreen.screens {
            if s.frame.insetBy(dx: -1, dy: -1).contains(global) {
                let local = CGPoint(
                    x: global.x - s.frame.origin.x,
                    y: global.y - s.frame.origin.y
                )
                return (s, local)
            }
        }
        guard let main = NSScreen.main else { return nil }
        return (main, CGPoint(x: global.x - main.frame.origin.x,
                              y: global.y - main.frame.origin.y))
    }
    
    var computedOffset: CGSize {
        switch mouseCoordinatesTextPosition {
        case .topLeft:
            return CGSize(width: -(80 + mouseCoordinatesTextOffset)-mouseCoordinatesTextZoom*3.2,
                          height: -(30 + mouseCoordinatesTextOffset)-mouseCoordinatesTextZoom)
        case .topRight:
            return CGSize(width: 80 + mouseCoordinatesTextOffset+mouseCoordinatesTextZoom*3.2,
                          height: -(30 + mouseCoordinatesTextOffset)-mouseCoordinatesTextZoom)
        case .bottomLeft:
            return CGSize(width: -(80 + mouseCoordinatesTextOffset)-mouseCoordinatesTextZoom*3.2,
                          height: 30 + mouseCoordinatesTextOffset+mouseCoordinatesTextZoom)
        case .bottomRight:
            return CGSize(width: 80 + mouseCoordinatesTextOffset+mouseCoordinatesTextZoom*3.2,
                          height: 30 + mouseCoordinatesTextOffset+mouseCoordinatesTextZoom)
        }
    }
}

extension UserDefaults {
    func setColor(_ color: Color, forKey key: String) {
        if let hex = color.hex {
            set(hex, forKey: key)
        }
    }
    
    func color(forKey key: String) -> NSColor? {
        guard let hex = string(forKey: key) else { return nil }
        return NSColor(hex: hex)
    }
    
}

extension NSColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension Color {
    var hex: String? {
            guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else { return nil }
            let r = Int(nsColor.redComponent * 255)
            let g = Int(nsColor.greenComponent * 255)
            let b = Int(nsColor.blueComponent * 255)
            let a = Int(nsColor.alphaComponent * 255)
            return "#" + String(format: "%02X%02X%02X%02X", r, g, b, a)
        }
}
