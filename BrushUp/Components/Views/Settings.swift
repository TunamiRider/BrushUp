//
//  Settings.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/27/26.
//
import SwiftUI
struct Settings: View {

    @Binding var  isMonochrome: Bool
    //@Binding var selectedNumber: Int
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 10)
            Label("Settings", systemImage: "paintbrush")
                .imageScale(.large)
                .foregroundColor(.white)
                .font(AppConstants.mediumRoundedFont)
            //Divider()
            VStack {
                MinuteSelector()
                //Divider()
                makeMonochromeView()
                Spacer(minLength: 16)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 1)
            .background(AppConstants.spaceblack.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color(AppConstants.UISpaceBlack), lineWidth: 0.5)
            )
            .onChange(of: isMonochrome) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "isMonochrome")
            }
            .padding(.horizontal)
            .padding(.vertical)
            PhotoCategoryView()
        }
        .onAppear {
            isMonochrome = UserDefaults.standard.bool(forKey: "isMonochrome")
        }
    }
    struct ColoredToggleStyle: ToggleStyle {
        var onColor: Color
        var offColor: Color
        var thumbColor: Color
        @Binding var isOn: Bool

        func makeBody(configuration: Self.Configuration) -> some View {
            HStack {
                configuration.label
                Spacer()
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 56, height: 26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(thumbColor)
                            .frame(width: 36, height: 24)
                            .shadow(radius: 1, x: 0, y: 1)
                            .padding(4)
                            .offset(x: configuration.isOn ? 10 : -10)
                        
                    )
                    .overlay(
                        alignment: .trailing,
                        content: {
                            // Circle overlaid on toggle track (only when OFF)
                            if !isOn {
                                Image(systemName: "circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 20, height: 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.gray.opacity(0.6))
                                    )
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            configuration.isOn.toggle()
                        }
                    }
            }
        }
    }
    @ViewBuilder
    fileprivate func makeMonochromeView() -> some View {
        Toggle(isOn: $isMonochrome) {
            Label {
                Text("Monochrome")
                    .foregroundColor(.white)
                    .font(AppConstants.mediumRoundedFont)
            } icon: {
//                Image(systemName: "snowflake")
//                    .font(.system(size: 16))
//                    .foregroundColor(.white)
//                    .padding(8)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.gray.opacity(1))
//                    )
            }
        }
        .toggleStyle(ColoredToggleStyle(onColor: .gray, offColor: .gray, thumbColor: .white, isOn: $isMonochrome))
        
    }
}

#Preview {
    @Previewable @State var isMonochrome: Bool = false
    Settings(isMonochrome: $isMonochrome).scrollDisabled(true).background(AppConstants.spaceblack)
}

