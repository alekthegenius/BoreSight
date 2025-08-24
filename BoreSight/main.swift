//
//  main.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/8/25.
//

import Foundation
import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
