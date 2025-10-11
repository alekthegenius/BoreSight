//
//  UserDefaultsExtensions.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/30/25.
//

import Foundation
import SwiftUI

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

extension UserDefaults {
    func setCGPoint(_ point: CGPoint, forKey key: String) {
        let dict: [String: CGFloat] = ["x": point.x, "y": point.y]
        set(dict, forKey: key)
    }

    func cgPoint(forKey key: String) -> CGPoint? {
        guard let dict = dictionary(forKey: key) as? [String: CGFloat],
              let x = dict["x"], let y = dict["y"] else { return nil }
        return CGPoint(x: x, y: y)
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
