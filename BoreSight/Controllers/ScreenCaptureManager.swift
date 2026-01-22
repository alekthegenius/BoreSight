//
//  ScreenCaptureManager.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/28/25.
//

import Foundation
import AVFoundation
import ScreenCaptureKit
import VideoToolbox

class ScreenCaptureManager: NSObject, ObservableObject {
    @Published var latestFrame: CGImage?
    
    private var stream: SCStream?
    private var streamOutput: CaptureStreamOutput?
    
    private var continuation: AsyncThrowingStream<CGImage, Error>.Continuation?
    
    func startCapture(for display: SCDisplay) -> AsyncThrowingStream<CGImage, Error> {
        AsyncThrowingStream<CGImage, Error> { continuation in
            Task {
                
                
                guard let content = try? await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true),
                    content.displays.contains(display)
                    else {
                        continuation.finish()
                        return
                }
                
                let excluded = content.windows.filter { window in
                    window.owningApplication?.bundleIdentifier == Bundle.main.bundleIdentifier || window.title == "BoreSight"
                }

                
                
                // Create a filter for the chosen display
                let filter = SCContentFilter(display: display, excludingWindows: excluded)

                // Configure stream
                let config = SCStreamConfiguration.defaultConfiguration(width: display.width, height: display.height)

                self.continuation = continuation
                
                
                let streamOutput = CaptureStreamOutput(continuation: continuation)
                self.streamOutput = streamOutput
                
                do {
                    stream = SCStream(filter: filter, configuration: config, delegate: streamOutput)
                    try stream?.addStreamOutput(streamOutput, type: .screen, sampleHandlerQueue: .global())
                    try await stream?.startCapture()
                } catch {
                    continuation.finish(throwing: error)
                }
           
            }
        }
    }

    func stopCapture() async {
        do {
            try await stream?.stopCapture()
            stream = nil
            streamOutput = nil
            continuation?.finish()
            
        } catch {
            continuation?.finish(throwing: error)
        }
    }
}

private class CaptureStreamOutput: NSObject, SCStreamOutput, SCStreamDelegate {
    
    var capturedFrameHandler: ((CGImage) -> Void)?
    
    // Store the  startCapture continuation, so you can cancel it if an error occurs.
    private var continuation: AsyncThrowingStream<CGImage, Error>.Continuation?
    
    init(continuation: AsyncThrowingStream<CGImage, Error>.Continuation?) {
        self.continuation = continuation
    }
    
    /// - Tag: DidOutputSampleBuffer
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        
        // Return early if the sample buffer is invalid.
        guard sampleBuffer.isValid else { return }
        
        guard outputType == .screen,
              let pixelBuffer = sampleBuffer.imageBuffer else { return }

        var cgImage: CGImage?
        _ = VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cgImage {
            continuation?.yield(cgImage)
        }
    }
}



class FrameBuffer {
    private let lock = NSLock()
    private var _latest: CGImage? = nil

    var latest: CGImage? {
        get { lock.lock(); defer { lock.unlock() }; return _latest }
        set { lock.lock(); defer { lock.unlock() }; _latest = newValue }
    }
}
