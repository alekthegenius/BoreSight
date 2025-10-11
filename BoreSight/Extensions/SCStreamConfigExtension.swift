//
//  SCStreamConfigExtension.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/26/25.
//

import Foundation
import ScreenCaptureKit

extension SCStreamConfiguration {
    static func defaultConfiguration(width: Int, height: Int) -> SCStreamConfiguration {
        let config = SCStreamConfiguration()
        config.width = width
        config.height = height
        config.showsCursor = false
        
        config.captureResolution = .nominal
        
        
        return config
    }
}
