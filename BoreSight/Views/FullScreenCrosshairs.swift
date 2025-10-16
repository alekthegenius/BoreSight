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
    @State private var globalMouseMonitor: Any?

    
    @State var isDraggingOrigin = false
    @State var mouseDown = false
    
    @State var lastBorderState: Bool = false
    @State var lastGapState: Bool = false
    @State var lastCrosshairState: Bool = false
    
    @State private var coordOverlaySize: CGSize = .zero
    
    
    @State private var justEndedDrag = false
    
    @State private var cursorShown = true
    
    
    @State private var localMonitor: Any?
    @State private var globalMonitor: Any?
    
    
    var isMouseOverOrigin: Bool {
        // Make sure we compare in the same coordinate space. mouseLocation is in top-left origin
        // while mouseOriginPosition is stored in the view's coordinate space. Flip mouseLocation's
        // y so both are comparable.
        let mouseYFlipped = model.currentScreenSize.height - model.mouseLocation.y
        let dx = model.mouseLocation.x - model.mouseOriginPosition.x
        let dy = mouseYFlipped - model.mouseOriginPosition.y
        let distance = sqrt(dx*dx + dy*dy)
        return distance <= 27.5 // half of the expanded overlay size
    }

    

    
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
            
            if model.mouseOriginShown  {
                ZStack {
                    if mouseDown && (mouseOriginHover || isDraggingOrigin) {
                        GeometryReader { proxy in
                                Rectangle()
                                .fill(.black.opacity(0.25))
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    
                        }
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
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Begin dragging and update the origin relative to the drag location (avoid snapping to the live mouseLocation)
                                    isDraggingOrigin = true

                                    // Update origin using the gesture's location in the overlay's coordinate space.
                                    // Use value.location which is in the view's coordinate space so we avoid flipping mistakes.
                                    let newOrigin = CGPoint(x: value.location.x, y: value.location.y)
                                    model.mouseOriginPosition = newOrigin

                                    // Ensure cursor state updates immediately when drag begins/continues
                                    handleCursorVisibility()
                                }
                                .onEnded { _ in
                                    isDraggingOrigin = false
                                    handleCursorVisibility()
                                }
                        )
                }
                .animation(.easeInOut(duration: 0.25), value: mouseDown && (mouseOriginHover || isDraggingOrigin))
                    
            }
            
            
            
        }
        .frame(width: model.currentScreenSize.width, height: model.currentScreenSize.height)
        .ignoresSafeArea()
        .compositingGroup()
        .onAppear() {
            setupMonitoring()
        }
        .onDisappear() {
            if let lm = localMonitor {
                NSEvent.removeMonitor(lm)
            }
            
            if let gm = globalMonitor {
                NSEvent.removeMonitor(gm)
            }
        }
        .animation(nil, value: model.mouseOriginPosition)

        
    }
    
    func setupMonitoring() {
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .leftMouseDragged]) { event in
            switch event.type {
            case .leftMouseDown, .leftMouseDragged:
                mouseDown = true
            case .leftMouseUp:
                mouseDown = false
            default:
                break
            }
            handleCursorVisibility()
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .leftMouseDragged]) { event in
            switch event.type {
            case .leftMouseDown, .leftMouseDragged:
                mouseDown = true
            case .leftMouseUp:
                mouseDown = false
            default:
                break
            }
            handleCursorVisibility()
        }
    }
    
    private func handleCursorVisibility() {
        if mouseDown && isMouseOverOrigin {
            if cursorShown {
                NSCursor.hide()
                cursorShown = false
            }
        } else {
            if !cursorShown && !mouseDown {
                NSCursor.unhide()
                cursorShown = true
            }
        }
    }
    
    @ViewBuilder
    func mouseOriginOverlay() -> some View {
        Circle()
            .fill(.white)
            .blendMode(.destinationOut)
            .frame(width: (mouseOriginHover || isDraggingOrigin)  ? (model.gapSize >= 55 ? model.gapSize : 55) : 30, height: (mouseOriginHover || isDraggingOrigin) ? (model.gapSize >= 55 ? model.gapSize : 55) : 30)
            .animation(isDraggingOrigin ? nil : .spring(response: 0.25, dampingFraction: 0.7), value: mouseDown || mouseOriginHover)
        
        Circle()
            .fill(mouseDown && (mouseOriginHover || isDraggingOrigin) ? .white.opacity(0.1) : (mouseOriginHover ? .blue.opacity(0.6) : .gray.opacity(0.6)))
            .stroke(mouseDown && (mouseOriginHover || isDraggingOrigin) ? .clear : .white, lineWidth: mouseDown && (mouseOriginHover || isDraggingOrigin) ? 0 : 4)
            .frame(width: (mouseOriginHover || isDraggingOrigin)  ? (model.gapSize >= 55 ? model.gapSize : 55) : 30, height: (mouseOriginHover || isDraggingOrigin) ? (model.gapSize >= 55 ? model.gapSize : 55) : 30)
            .animation(isDraggingOrigin ? nil : .spring(response: 0.25, dampingFraction: 0.7), value: mouseDown || mouseOriginHover)
            .onHover() { hovering in
                
                
                mouseOriginHover = hovering
                
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.enableOverlayEditing(hovering)
                }
                
                
                
            }
        
        if mouseDown && (mouseOriginHover || isDraggingOrigin) {
            ZStack {
                Rectangle()
                    .fill(model.crossHairColor)
                    .frame(width: (model.gapSize >= 55 ? model.gapSize : 55), height: 1)
                    
                Rectangle()
                    .fill(model.crossHairColor)
                    .frame(width: 1, height: (model.gapSize >= 55 ? model.gapSize : 55))
                    
            }
            
            
        }
                
                
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
