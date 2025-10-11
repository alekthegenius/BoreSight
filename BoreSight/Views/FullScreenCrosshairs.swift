//
//  ContentView.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/5/25.
//

import SwiftUI

struct FullScreenCrosshairs: View {
    @ObservedObject var model: CrosshairModel
    
    @State var mouseOriginHover: Bool = false
    
    @State var isDraggingOrigin = false
    
    @State var lastBorderState: Bool = false
    @State var lastGapState: Bool = false
    @State var lastCrosshairState: Bool = false
    
    @State private var coordOverlaySize: CGSize = .zero
    
    var body: some View {
        
        ZStack {
                
            
            if model.borderOn {
                ZStack {
                    // Vertical Border
                    Rectangle()
                        .fill(model.borderColor)
                        .frame(width: (model.borderThickness*2)+model.crossHairWidth, height: model.currentScreenSize.height)
                        .opacity(model.borderTransparency)
                    
                    // Vertical Masking Crosshair
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: model.crossHairWidth, height: model.currentScreenSize.height)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .position(x: round(model.mouseLocation.x), y: model.currentScreenSize.height / 2)
                
                ZStack {
                    // Horizontal Border
                    Rectangle()
                        .fill(model.borderColor)
                        .frame(width: model.currentScreenSize.width, height: (model.borderThickness*2)+model.crossHairWidth)
                        .opacity(model.borderTransparency)
                    
                    // Horizontal Masking Crosshair
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: model.currentScreenSize.width, height: model.crossHairWidth)
                        .blendMode(.destinationOut)
                }
                .position(x: model.currentScreenSize.width / 2, y: model.currentScreenSize.height-model.mouseLocation.y)
            }

            
            if model.crossHairsShown {
                // Vertical Crosshair
                Rectangle()
                    .fill(model.crossHairColor)
                    .frame(width: model.crossHairWidth, height: model.currentScreenSize.height)
                    .position(x: round(model.mouseLocation.x), y: model.currentScreenSize.height / 2)
                    .opacity(model.crossHairTransparency)

                
                // Horizontal Crosshair
                Rectangle()
                    .fill(model.crossHairColor)
                    .frame(width: model.currentScreenSize.width, height: model.crossHairWidth)
                    .position(x: model.currentScreenSize.width / 2, y: model.currentScreenSize.height-model.mouseLocation.y)
                    .opacity(model.crossHairTransparency)
            }
            
            
            if model.gapShown {
                ZStack {
                    switch model.gapType {
                    case .none:

                        
                        Rectangle()
                            .fill(.black) // Or clear if your background is transparent
                            .frame(width: model.gapSize, height: model.gapSize)
                            .blendMode(.destinationOut)
                        
                    case .square:
                        Rectangle()
                            .fill(.black) // Or clear if your background is transparent
                            .frame(width: model.gapSize+model.gapBorderThickness, height: model.gapSize+model.gapBorderThickness)
                            .blendMode(.destinationOut)
                        
                        if model.borderOn {
                            Rectangle()
                                .fill(.black) // Or clear if your background is transparent
                                .stroke(.black, lineWidth: model.borderThickness)
                                .frame(width: model.gapSize+model.gapBorderThickness+model.borderThickness, height: model.gapSize+model.gapBorderThickness+model.borderThickness)
                                .blendMode(.destinationOut)
                            
                            Rectangle()
                                .stroke(model.borderColor.opacity(model.borderTransparency), lineWidth: model.borderThickness)
                                .frame(width: model.gapSize+model.gapBorderThickness+model.borderThickness, height: model.gapSize+model.gapBorderThickness+model.borderThickness)
                                
                        }
                        
                        Rectangle()
                            .fill(.clear)
                            .stroke(model.gapBorderColor.opacity(model.gapBorderTransparency), lineWidth: model.gapBorderThickness)
                            .frame(width: model.gapSize, height: model.gapSize)
                        
                        
                    
                    case .circle:
                        Circle()
                            .fill(.black) // Or clear if your background is transparent
                            .frame(width: model.gapSize+model.gapBorderThickness, height: model.gapSize+model.gapBorderThickness)
                            .blendMode(.destinationOut)
                        
                        if model.borderOn {
                            Circle()
                                .fill(.black) // Or clear if your background is transparent
                                .stroke(.black, lineWidth: model.borderThickness)
                                .frame(width: model.gapSize+model.gapBorderThickness+model.borderThickness, height: model.gapSize+model.gapBorderThickness+model.borderThickness)
                                .blendMode(.destinationOut)
                            
                            
                            
                            Circle()
                                .stroke(model.borderColor.opacity(model.borderTransparency), lineWidth: model.borderThickness)
                                .frame(width: model.gapSize+model.gapBorderThickness+model.borderThickness, height: model.gapSize+model.gapBorderThickness+model.borderThickness)
                                
                        }
                        
                        Circle()
                            .fill(.clear)
                            .stroke(model.gapBorderColor.opacity(model.gapBorderTransparency), lineWidth: model.gapBorderThickness)
                            .frame(width: model.gapSize, height: model.gapSize)
                    }
                }
                .position(x: round(model.mouseLocation.x), y: model.currentScreenSize.height-model.mouseLocation.y)
            }
            
            if model.mouseCoordinatesText {
                
                
                

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.clear)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                    
                    BlurView(material: .fullScreenUI, blendingMode: .behindWindow)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    
                    VStack{
                        
                        
                        
                        if model.mouseOriginShown {
                            if let distX = model.calculateDistance().first,
                               let distY = model.calculateDistance().last {
                                HStack(spacing: 5) {
                                    Text("x: \(round(distX), format: .number.precision(.fractionLength(0)))")
                                        .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                                        
                                    Spacer()
                                    Text("y: \(round(distY), format: .number.precision(.fractionLength(0)))")
                                        .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                                }
                            }
                            
                            
                            let theta: Angle = model.calculateTheta()
                            Text("θ: \(theta.degrees, format: .number.precision(.fractionLength(2)))")
                                .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                            
                        } else {
                            HStack(spacing: 5) {
                                Text("x: \(round(model.mouseLocation.x), format: .number.precision(.fractionLength(0)))")
                                    .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                                    
                                Spacer()
                                Text("y: \(round(model.mouseLocation.y), format: .number.precision(.fractionLength(0)))")
                                    .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                        
                }
                .fixedSize()
                .background(
                       GeometryReader { geo in
                           Color.clear
                               .onAppear {
                               coordOverlaySize = geo.size
                           }
                               .onChange(of: geo.size) {
                               coordOverlaySize = geo.size
                           }
                       }
                   )
                   .position({
                       let clamped = clampedCoordinateTextPosition(
                            mouse: CGPoint(
                                x: model.mouseLocation.x + model.computedOffset.width,
                                y: model.mouseLocation.y - model.computedOffset.height
                            ),
                            screenSize: model.currentScreenSize,
                            overlaySize: coordOverlaySize
                       )
                       return CGPoint(x: clamped.x, y: model.currentScreenSize.height - clamped.y)
                   }())
            }
            
            mouseOriginOverlay()
                .position(x: round(model.mouseOriginPosition.x), y: round(model.mouseOriginPosition.y))
                .onAppear {
                    if !isPointOnScreen(model.mouseOriginPosition,
                                        screenSize: model.currentScreenSize) {
                        model.mouseOriginPosition = CGPoint(
                            x: model.currentScreenSize.width / 2,
                            y: model.currentScreenSize.height / 2
                        )
                    }
                }
            
            magnifierView()
                .allowsHitTesting(false)
            
        }
        .frame(width: model.currentScreenSize.width, height: model.currentScreenSize.height)
        .ignoresSafeArea()
        .compositingGroup()
        
        
    }
    
    @ViewBuilder
    func mouseOriginOverlay() -> some View {
        if model.mouseOriginShown {
            Circle()
                .fill(mouseOriginHover ? .blue : .gray)
                .stroke(.white, lineWidth: mouseOriginHover ? 10 : 5)
                .frame(width: mouseOriginHover ? 30 : 25, height: mouseOriginHover ? 30 : 25)
                .onHover() { hovering in
                    let mouseIsDown = NSEvent.pressedMouseButtons != 0
                    
                    if !isDraggingOrigin {
                        // Only update hover if we're NOT dragging
                        mouseOriginHover = hovering
                    }
                    
                    
                    if let appDelegate = NSApp.delegate as? AppDelegate {
    
                        if hovering && !mouseIsDown {
                            
                            lastCrosshairState = model.crossHairsShown
                            lastBorderState = model.borderOn
                            lastGapState = model.gapShown
                            // Hide temporarily
                            model.crossHairsShown = false
                            model.borderOn = false
                            model.gapShown = false
                            
                        } else {
                            if !hovering && !mouseIsDown {
                                model.crossHairsShown = lastCrosshairState
                                model.borderOn = lastBorderState
                                model.gapShown = lastGapState
                            }
                            
                        
                        }
                        appDelegate.enableOverlayEditing(hovering)
                        
                    }
                    
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDraggingOrigin = true
                            // update origin position
                            model.mouseOriginPosition = CGPoint(
                                x: model.mouseLocation.x,
                                y: model.currentScreenSize.height - model.mouseLocation.y
                            )
                        }
                        .onEnded { _ in
                            isDraggingOrigin = false
                        }
                )
                
                
        }
    }
    
    @ViewBuilder
    func magnifierView() -> some View {
        let magnifierSize = CGSize(width: 120, height: 60)
        

        if isDraggingOrigin && mouseOriginHover {
            if let frame = model.magnifiedImage {
                let cropRect = CGRect(
                    x: model.mouseLocation.x - magnifierSize.width/2,
                    y: CGFloat(frame.height) - model.mouseLocation.y - magnifierSize.height/2,
                    width: magnifierSize.width,
                    height: magnifierSize.height
                )

                if let cropped = frame.cropping(to: cropRect) {
                    let offsetMouse = CGPoint(
                        x: model.mouseLocation.x,
                        y: model.mouseLocation.y + 75 // move magnifier 100 pts up
                    )

                    
                    let position = clampedMagnifierPosition(
                        mouse: offsetMouse,
                        screenSize: model.currentScreenSize,
                        magnifierSize: magnifierSize
                    )

                    ZStack {
                        Image(decorative: cropped, scale: 1.0, orientation: .up)
                            .resizable()
                            .interpolation(.none)
                            .scaleEffect(3.0)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: magnifierSize.width, height: magnifierSize.height)
                            .shadow(radius: 5)
                            
                            .position(x: position.x, y: model.currentScreenSize.height - position.y)
                        
                        Rectangle()
                            .fill(.red)
                            .frame(width: 120, height: 1)
                            .position(x: position.x, y: model.currentScreenSize.height - position.y)
                        
                        Rectangle()
                            .fill(.red)
                            .frame(width: 1, height: 60)
                            .position(x: position.x, y: model.currentScreenSize.height - position.y)
                    }
                        
                        
                }
            } else {

                RoundedRectangle(cornerRadius: 25)
                   .fill(Color.black.opacity(0.2))
                   .frame(width: 120, height: 120)
            }
        }
    }
    
    
    func clampedMagnifierPosition(mouse: CGPoint, screenSize: CGSize, magnifierSize: CGSize) -> CGPoint {
        var x = mouse.x
        var y = mouse.y

        // Horizontal clamp
        if x - magnifierSize.width/2 < 0 {
            x = magnifierSize.width/2
        } else if x + magnifierSize.width/2 > screenSize.width {
            x = screenSize.width - magnifierSize.width/2
        }

        // Vertical clamp
        if y - magnifierSize.height/2 < 0 {
            y = magnifierSize.height/2
        } else if y + magnifierSize.height/2 > screenSize.height {
            y = screenSize.height - magnifierSize.height/2
        }

        return CGPoint(x: x, y: y)
    }
    
    
    func clampedCoordinateTextPosition(mouse: CGPoint, screenSize: CGSize, overlaySize: CGSize) -> CGPoint {
        var x = mouse.x
        var y = mouse.y

        // Horizontal clamp
        if x - overlaySize.width/2 < 0 {
            x = overlaySize.width/2
        } else if x + overlaySize.width/2 > screenSize.width {
            x = screenSize.width - overlaySize.width/2
        }

        // Vertical clamp
        if y - overlaySize.height/2 < 0 {
            y = overlaySize.height/2
        } else if y + overlaySize.height/2 > screenSize.height {
            y = screenSize.height - overlaySize.height/2
        }

        return CGPoint(x: x, y: y)
    }
    
    func isPointOnScreen(_ point: CGPoint, screenSize: CGSize) -> Bool {
        return point.x >= 0 &&
               point.x <= screenSize.width &&
               point.y >= 0 &&
               point.y <= screenSize.height
    }
    
    
}

#Preview {
    FullScreenCrosshairs(model: CrosshairModel())
}
