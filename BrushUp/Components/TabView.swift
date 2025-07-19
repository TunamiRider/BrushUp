//
//  TaskBarView.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 7/23/25.
//
import SwiftUI
import SwiftData

struct BrushUpTabView: View {
    @Binding var isSettings: Bool
    @Binding var isHistory: Bool
    @Binding var goMainView: Bool
    @Binding var uiScreenSize: CGSize
    
    @Binding var minutes: Int
    @Binding var isMonochrone: Bool
    
    @State private var isSheetPresented = false

    
    var body: some View {
        
        HStack(spacing: uiScreenSize.width*0.15) { // Customize spacing as you like
            
            Button(action: {
                isSettings.toggle()
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 24))
                    .opacity(0.9)
                    .foregroundColor(.gray)
            }
            .sheet(isPresented: $isSettings) {
                SideMenu(minutes: $minutes, isMonochrome: $isMonochrone)
                    .presentationDetents([.medium, .large])
                    .padding(.top, 20)

            }
            .contentShape(Rectangle())
            
            Button(action: {
                isHistory.toggle()
            }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 24))
                    .opacity(0.9)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            
            
            Button(action: {
                goMainView.toggle()
            }) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24))
                    .opacity(0.9)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            
            
        }//.border(Color.green, width: 0.5)
    }
}

struct SideMenu: View {
    @Binding private var isMonochrome: Bool
    @Binding var minutes: Int
    var edgeTransition: AnyTransition = .move(edge: .leading)
    let screenSize: CGRect = UIScreen.main.bounds

    let config: ModelConfiguration
    let container:ModelContainer

    init(minutes: Binding<Int>, isMonochrome: Binding<Bool>){
        self._minutes = minutes
        self._isMonochrome = isMonochrome
        
        config = ModelConfiguration(isStoredInMemoryOnly: false)
        container = try! ModelContainer(for: Tag.self, configurations: config)
    }
    var body: some View {
        ScrollView {
            
            Label("Settings", systemImage: "paintbrush")
                .imageScale(.large)
            Divider()
            CustomStepper(value: $minutes, range: 1...10)
                .padding(.horizontal, screenSize.width*0.05)
            
            Divider()
            
            Toggle(isOn: $isMonochrome) {
                Label {
                    Text("Monochrome")
                } icon: {
                    Image(systemName: "snowflake")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.7))
                        )
                }
            }
            .tint(.yellow.opacity(0.6))
            .toggleStyle(.switch)
            .padding(.horizontal, screenSize.width*0.05)
            Divider()
            TagsQueryView(modelContainer: container)
            
            Spacer()
            
        }
        
    }
}
struct CustomStepper: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...30
    var step: Int = 1

    var body: some View {
        HStack(spacing: 6) {
            Label {
                Text("Timer")
            } icon: {
                Image(systemName: "timer")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                    )
            }
            Spacer()
            Button(action: {
                if value > range.lowerBound {
                    value -= step
                    UserDefaults.standard.set(value, forKey: "minutes")
                    //let value = UserDefaults.standard.string(forKey: "minutes")
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.yellow.opacity(0.6))
            }

            Text("\(value)")
                .font(.title)
                .frame(minWidth: 40)

            Button(action: {
                if value < range.upperBound {
                    value += step
                    UserDefaults.standard.set(value, forKey: "minutes")
                    //let value = UserDefaults.standard.string(forKey: "minutes")
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.yellow.opacity(0.6))
            }
        }
        
    }
}

#Preview {
    @Previewable @State var isSettings: Bool = false
    @Previewable @State var isHistory: Bool = true
    @Previewable @State var isCustom: Bool = true
    @Previewable @State var uiScreenSize = UIScreen.main.bounds.size
    
    @Previewable @State var minutes: Int = 1
    @Previewable @State var isMonochrone: Bool = true
    
//    BrushUpTabView(isSettings: $isSettings, isHistory: $isHistory, goMainView: $isCustom, uiScreenSize: $uiScreenSize, minutes: $minutes, isMonochrone: $isMonochrone).frame(width: 500, height: 700,alignment: .bottom)
    

    SideMenu(minutes: $minutes, isMonochrome: $isMonochrone).scrollDisabled(true)
    
    
}

