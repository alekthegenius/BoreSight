//
//  SettingsView.swift
//  BoreSight
//
//  Created by Alek Vasek on 8/13/25.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var model: CrosshairModel
    
    @State private var showFullscreenPreview = false
    @State private var hoveringPreview = false
    @State private var isHoveringClose = false
    @State private var isHoveringReset = false
    
    var appDelegate: AppDelegate
    
    var crossHairTransparencyText: Text {
        Text(model.crossHairTransparency.formatted(.number.precision(.fractionLength(2))))
            .fontWeight(.semibold)
    }
    
    var borderTransparencyText: Text {
        Text(model.borderTransparency.formatted(.number.precision(.fractionLength(2))))
            .fontWeight(.semibold)
    }
    
    var gapSizeText: Text {
        Text("\(Int(model.gapSize)) px")
            .fontWeight(.semibold)
    }
    
    var mosueCoordinatesTextOffset: Text {
        Text("\(Int(model.mouseCoordinatesTextOffset)) px")
            .fontWeight(.semibold)
    }
    
    var gapBorderTransparencyText: Text {
        Text(model.gapBorderTransparency.formatted(.number.precision(.fractionLength(2))))
            .fontWeight(.semibold)
    }
    
    
    
    var body: some View {
        ZStack {
            BlurView(material: .underWindowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            TabView(selection: $model.activeSettingsTab) {
               
                
                Tab("Appearance", systemImage: "lightbulb", value: .appearance) {
                    appearanceMenu()
                }
                
                Tab("Controls", systemImage: "lightbulb", value: .control) {
                    controlMenu()
                        .onAppear() {
                            showFullscreenPreview = false
                        }
                }
                
                Tab("Shortcuts", systemImage: "lightbulb", value: .shortcuts) {
                    shortcutsMenu()
                        .onAppear() {
                            showFullscreenPreview = false
                        }
                }
                
                Tab("About", systemImage: "lightbulb", value: .about) {
                    aboutMenu()
                        .onAppear() {
                            showFullscreenPreview = false
                        }
                }
            }
            
        }
        .overlay {
            if showFullscreenPreview {
                ZStack {
                    BlurView(material: .fullScreenUI, blendingMode: .withinWindow)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showFullscreenPreview = false
                        }
                    
                    

                    VStack {
                        crosshairPreview()
                            .padding(50)

                        Button {
                            showFullscreenPreview = false
                        } label : {
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isHoveringClose ? .white.opacity(0.3) : .clear)
                                    .stroke(.white, style: .init(lineWidth: 2))
                                    
                                
                                Text("Close")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 15)
                            }
                        }
                        .fixedSize()
                        .fontDesign(.rounded)
                        .buttonStyle(.plain)
                        .padding()
                        .onHover() { hover in
                            withAnimation(.easeInOut) {
                                isHoveringClose = hover
                            }
                        }
                    }
                }
                .transition(.scale)
            }
        }
        
        
    }
    
    @ViewBuilder
    func appearanceMenu() -> some View {
        VStack(alignment: .center) {
            
                
                HStack {
                    Text("Appearance")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.opacity(0.75))
                        .shadow(radius: 5, x: -5, y: 5)
                        .padding(.top, 10)
                        .padding(.leading, 20)
                        
                    
                    
                    Spacer()
                }
                .padding(.bottom, 5)
            

            
                ZStack {
                    crosshairPreview()
                    
                    if hoveringPreview {
                        Color.white.opacity(0.3) // 25% white overlay
                                .transition(.opacity)
                                .animation(.easeIn(duration: 0.05), value: hoveringPreview)
                        }
                }
                .frame(height: 125)
                .onTapGesture {
                    showFullscreenPreview = true
                }
                .onHover { hovering in
                        withAnimation {
                            hoveringPreview = hovering
                        }
                }
                
                
            
            
                HStack {
                    ScrollView(.vertical) {
                        VStack {
                            crossHairSettings()
                            crosshairGapSettings()
                            borderSettings()
                            mouseCoordinatesTextSettings()
                            mouseOriginSettings()

                            HStack {
                                Spacer()
                                
                                Button() {
                                    model.resetAppearance()
                                } label: {
                                    ZStack {
                                        
                                        
                                        BlurView(material: .popover, blendingMode: .behindWindow)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isHoveringReset ? .white.opacity(0.3) : .clear)
                                            .strokeBorder(.white.opacity(0.2), style: .init(lineWidth: 1))
                                            
                                        Text("Reset Appearance")
                                    }
                                }
                                .buttonStyle(.plain)
                                .frame(width: 175, height: 30)
                                .padding(.bottom, 15)
                                .onHover() { hover in
                                    withAnimation(.easeInOut) {
                                        isHoveringReset = hover
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .scrollIndicators(.automatic)
                    }
                    
                }
        }

    }
    
    @ViewBuilder
    func crossHairSettings() -> some View {

        Form() {
            
            Toggle(isOn: $model.crossHairsShown){
                Text("Crosshair")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.opacity(0.75))
            }
            
            if model.crossHairsShown {
                VStack {
                    ColorPicker("Color", selection: $model.crossHairColor, supportsOpacity: false)
                        .listRowBackground(Color.clear)
                    

                    
                    Slider(value: $model.crossHairWidth, in: 2...10, step: 2) {
                        HStack {
                            Text("Thickness:")
                            Text("\(Int(model.crossHairWidth)) px")
                                .fontWeight(.semibold)
                        }
                        
                    }
                    
                    
                    
                    Slider(value: $model.crossHairTransparency, in: 0...1, step: 0.05) {
                        HStack{
                            Text("Opacity:")
                            crossHairTransparencyText
                        }
                    }
                    
                    
                    
                    
                }
                .padding(.leading, 20)
                .padding(.trailing, 15)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            
            
        }
        .animation(.easeInOut(duration: 0.25), value: model.crossHairsShown)
        .scrollDisabled(true)
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
            
    }
    
    @ViewBuilder
    func mouseCoordinatesTextSettings() -> some View {
        Form() {
            Toggle(isOn: $model.mouseCoordinatesText) {
                Text("Mouse Coordinates Overlay")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.opacity(0.75))
            }
            
            if model.mouseCoordinatesText {
                VStack {
                    Slider(value: $model.mouseCoordinatesTextOffset, in: 0...100, step: 5) {
                        HStack{
                            Text("Offset:")
                            mosueCoordinatesTextOffset
                        }
                    }
                    
                    Slider(value: $model.mouseCoordinatesTextZoom, in: 0...20, step: 2) {
                        Text("Zoom:")
                    }
                    
                    Picker("Position:", selection: $model.mouseCoordinatesTextPosition) {
                        ForEach(MouseCoordinateTextPosition.allCases, id: \.self) { pos in
                            switch pos {
                            case .bottomLeft:
                                Text("Bottom Left")
                                    .tag(pos)
                            case .bottomRight:
                                Text("Bottom Right")
                                    .tag(pos)
                            case .topLeft:
                                Text("Top Left")
                                    .tag(pos)
                            case .topRight:
                                Text("Top Right")
                                    .tag(pos)
                            }
                               
                        }
                    }
                    .pickerStyle(.palette)
                    
                    
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            
        }
        .animation(.easeInOut(duration: 0.25), value: model.mouseCoordinatesText)
        .scrollDisabled(true)
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    func mouseOriginSettings() -> some View {
        Form() {
            Toggle(isOn: $model.mouseOriginShown) {
                Text("Set Mouse Origin")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.opacity(0.75))
            }
            
            Button() {
                // Show a Help Menu Popover
            } label: {
                Text("What the heck is Mouse Origin?")
            }
        }
        .animation(.easeInOut(duration: 0.25), value: model.mouseOriginShown)
        .scrollDisabled(true)
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
        
    @ViewBuilder
    func borderSettings() -> some View {
        Form() {
            
            Toggle(isOn: $model.borderOn) {
                Text("Border")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.opacity(0.75))
            }
                
            
            
            if model.borderOn {
                VStack {
                    ColorPicker("Color", selection: $model.borderColor, supportsOpacity: false)
                        .listRowBackground(Color.clear)
                    

                    
                    Slider(value: $model.borderThickness, in: 1...10, step: 2) {
                        HStack {
                            Text("Thickness:")
                            Text("\(Int(model.borderThickness)) px")
                                .fontWeight(.semibold)
                        }
                        
                    }
                    
                    Slider(value: $model.borderTransparency, in: 0...1, step: 0.05) {
                        HStack{
                            Text("Opacity:")
                            borderTransparencyText
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 15)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            
            
        }
        .animation(.easeInOut(duration: 0.25), value: model.borderOn)
        .scrollDisabled(true)
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    func crosshairGapSettings() -> some View {
        Form {
            Toggle(isOn: $model.gapShown){
                Text("Gap")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.opacity(0.75))
            }
            
            
            
            if model.gapShown {
                VStack {
                    Slider(value: $model.gapSize, in: 0...100) {
                        HStack{
                            Text("Size:")
                            gapSizeText
                        }
                    }
                    
                    Picker("Border Type", selection: $model.gapType) {
                        ForEach(GapType.allCases, id: \.self) { gap in
                            Text(gap.rawValue.capitalized)
                                .tag(gap)
                        }
                    }
                    
                    if model.gapType != .none{
                        ColorPicker("Color", selection: $model.gapBorderColor, supportsOpacity: false)
                            .listRowBackground(Color.clear)
                        
                        Slider(value: $model.gapBorderThickness, in: 2...10, step: 2) {
                            HStack {
                                Text("Border:")
                                Text("\(Int(model.gapBorderThickness)) px")
                                    .fontWeight(.semibold)
                            }
                            
                        }
                        
                        Slider(value: $model.gapBorderTransparency, in: 0...1, step: 0.05) {
                            HStack{
                                Text("Opacity:")
                                gapBorderTransparencyText
                            }
                        }
                    }
                    
                }
                .padding(.leading, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
                
        }
        .animation(.easeInOut(duration: 0.25), value: model.gapShown)
        .scrollDisabled(true)
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
    
   
    
    
    @ViewBuilder
    func controlMenu() -> some View {
        HStack {
            Text("Controls")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.opacity(0.75))
                .shadow(radius: 5, x: -5, y: 5)
                .padding(.top, 10)
                .padding(.leading, 20)
                
            
            
            Spacer()
        }
        .padding(.bottom, 5)
    
        Divider()
        
        Form {
            Toggle(isOn: $model.isAutomaticDisplay) {
                Text("Automatically Move to Screen With Cursor:")
            }
            
            
            if !model.isAutomaticDisplay {
                Picker("Display:", selection: $model.fixedScreenIndex) {
                    ForEach(Array(NSScreen.screens.enumerated()), id: \.offset) { index, screen in
                        Text(screen.localizedName)
                            .tag(index)
                                                        
                    }
                }
                .pickerStyle(.palette)
                .onChange(of: model.fixedScreenIndex) {
                    appDelegate.changingFixedScreen()
                }
                .onAppear() {
                    appDelegate.changingFixedScreen()
                }
            }
            
            Toggle(isOn: $model.keepBoreSightLocked) {
                Text("Keep Crosshairs Locked When Hidden:")
            }
            
            Toggle(isOn: $model.hideBoreSightWhenSettingsOpen) {
                Text("Hide BoreSight When Settings Opens:")
            }
            
            Toggle(isOn: $model.showingAlerts) {
                Text("Show Alerts:")
            }
        }
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        
    }
    @ViewBuilder
    func shortcutsMenu() -> some View {
        HStack {
            Text("Shortcuts")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.opacity(0.75))
                .shadow(radius: 5, x: -5, y: 5)
                .padding(.top, 10)
                .padding(.leading, 20)
                
            
            
            Spacer()
        }
        .padding(.bottom, 5)
    
        Divider()
        
        Form {
            KeyboardShortcuts.Recorder("Toggle BoreSight:", name: .toggleBoreSight) { _ in
                Task { @MainActor in
                    appDelegate.updateMenuShortcutDisplay()
                }
            }
            
            
            KeyboardShortcuts.Recorder("Lock/Unlock BoreSight:", name: .toggleLockedBoreSight) { _ in
                Task { @MainActor in
                    appDelegate.updateMenuShortcutDisplay()
                }
            }
            
            KeyboardShortcuts.Recorder("Toggle Crosshairs:", name: .toggleCrosshairs) { _ in
                Task { @MainActor in
                    appDelegate.updateMenuShortcutDisplay()
                }
            }
            
            KeyboardShortcuts.Recorder("Toggle Mouse Coordinates:", name: .toggleMouseCoordinates) { _ in
                Task { @MainActor in
                    appDelegate.updateMenuShortcutDisplay()
                }
            }
            
            KeyboardShortcuts.Recorder("Copy Mouse Coordinates:", name: .copyMouseCoordinates) { _ in
                Task { @MainActor in
                    appDelegate.updateMenuShortcutDisplay()
                }
            }
            
            KeyboardShortcuts.Recorder("Toggle Mouse Origin:", name: .toggleMouseOrigin) { _ in
                Task { @MainActor in
                    appDelegate.updateMenuShortcutDisplay()
                }
            }
            
            
        }
        .fontDesign(.rounded)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    func aboutMenu() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Image("aboutMe_Icon")
                    .interpolation(.medium) 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(radius: 5, x: -2, y: 2)
                
                
                Spacer()
                
                
                VStack(alignment: .leading) {
                    Text("BoreSight")
                        .font(.system(size: 40))
                        .fontWeight(.medium)
                        .padding(.bottom, 5)
                    
                    Text("Crafted by Alek Vasek")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .offset(x: 3)

                }
            }
            .frame(width: 420)
            
            Spacer()
            
            Divider()
                .padding(.bottom, 7.5)
            
            Text("from tx with ❤️ © 2025")
                .font(.system(size: 13, weight: .thin))
                .padding(.bottom, 15)
        }
        .fontDesign(.rounded)
    }
    
    @ViewBuilder
    func crosshairPreview() -> some View {
        ZStack {
            
            if showFullscreenPreview {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.black.opacity(0.3))
            } else{
                Rectangle()
                    .fill(Color.black.opacity(0.3))
            }
                
            
            GeometryReader { proxy in
                
                if model.borderOn {
                    ZStack {
                        // Vertical Border
                        Rectangle()
                            .fill(model.borderColor)
                            .frame(width: (model.borderThickness*2)+model.crossHairWidth, height: proxy.size.height)
                            .opacity(model.borderTransparency)
                        
                        // Vertical Masking Crosshair
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: model.crossHairWidth, height: proxy.size.height)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    
                    ZStack {
                        // Horizontal Border
                        Rectangle()
                            .fill(model.borderColor)
                            .frame(width: proxy.size.width, height: (model.borderThickness*2)+model.crossHairWidth)
                            .opacity(model.borderTransparency)
                        
                        // Horizontal Masking Crosshair
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: proxy.size.width, height: model.crossHairWidth)
                            .blendMode(.destinationOut)
                    }
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
                

                if model.crossHairsShown {
                    // Vertical Crosshair
                    Rectangle()
                        .fill(model.crossHairColor)
                        .frame(width: model.crossHairWidth, height: proxy.size.height)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        .opacity(model.crossHairTransparency)

                    
                    // Horizontal Crosshair
                    Rectangle()
                        .fill(model.crossHairColor)
                        .frame(width: proxy.size.width, height: model.crossHairWidth)
                        .position(x: proxy.size.width / 2, y: proxy.size.height/2)
                        .opacity(model.crossHairTransparency)
                }
                
                if model.gapShown {
                    //Gap
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
                    .position(x: proxy.size.width / 2, y: proxy.size.height/2)
                }
                
                if model.mouseCoordinatesText {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.clear)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                        
                        BlurView(material: .fullScreenUI, blendingMode: .behindWindow)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        
                        HStack(spacing: 5) {
                            Text("x: 100")
                                .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                            Spacer()
                            Text("y: 100")
                                .font(.system(size: 12+model.mouseCoordinatesTextZoom, weight: .medium))
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                            
                    }
                    .fixedSize()
                    .position(x: proxy.size.width / 2, y: proxy.size.height/2)
                    .offset(model.computedOffset)
                }
                    
                
            }
            .clipped()
            .compositingGroup()
            
            if showFullscreenPreview {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.clear)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            } else {
                VStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1) // Top border
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1) // Bottom border
                }
            }
            
        }

    }

}

#Preview {
    SettingsView(model: CrosshairModel(), appDelegate: AppDelegate())
}
