//
//  ContentView.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/5/25.
//

import SwiftUI

struct FullScreenCrosshairs: View {
    @ObservedObject var model: CrosshairModel
    
    
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
                        
                    
                    HStack(spacing: 5) {
                        Text("x: \(round(model.mouseLocation.x), format: .number.precision(.fractionLength(0)))")
                            .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                            
                        Spacer()
                        Text("y: \(model.mouseLocation.y, format: .number.precision(.fractionLength(0)))")
                            .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                        
                }
                .fixedSize()
                .position(x: round(model.mouseLocation.x), y: model.currentScreenSize.height-model.mouseLocation.y)
                .offset(model.computedOffset)
            }
            
        }
        .frame(width: model.currentScreenSize.width, height: model.currentScreenSize.height)
        .ignoresSafeArea()
        .compositingGroup()
        
        
    }
    
   
}

#Preview {
    FullScreenCrosshairs(model: CrosshairModel())
}
