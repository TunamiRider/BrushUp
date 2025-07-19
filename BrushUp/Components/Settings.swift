//
//  Settings.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 10/29/25.
//
import SwiftUI

struct Settings: View {
    @Binding var minutes: Int
    @Binding var isMonochrone: Bool
    
    
    var body: some View {
        SideMenu(minutes: $minutes, isMonochrome: $isMonochrone).scrollDisabled(true)
    }
    
}


#Preview {
    
    @Previewable @State var minutes: Int = 1
    @Previewable @State var isMonochrone: Bool = true
    Settings(minutes: $minutes, isMonochrone: $isMonochrone)
}
