//
//  PaintMeHeaderView.swift
//  PaintMe
//
//  Created by Yuki Suzuki on 5/9/25.
//

import SwiftUI
import ThemeKit
import TimerKit

 
struct PaintMeHeaderView: View {
    @State private var isSwitched = true
    @Binding var isShowing: Bool;
    let secondsElapsed: Int
    let secondsRemaining: Int
    let theme: Theme
    private var totalSeconds: Int {
        secondsElapsed + secondsRemaining
    }
    private var progress: Double {
        guard totalSeconds > 0 else { return 1 }
        return Double (secondsElapsed) / Double(totalSeconds)
    }
    private var minutesRemaining: Int {
        secondsRemaining / 60
    }

    var body: some View {

        //VStack {
            Toggle(isOn: $isSwitched.animation(.spring()), label: {
                HStack {
                    Button{
                        isShowing.toggle()
                    } label: {
                        Image(systemName: "forward.frame.fill") //play.fill
                            .resizable()
                            .frame(width: 24, height: 24)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.gray, .background)
                            .opacity(0.85)
                    }
                    
                    if(isSwitched){
                            HStack {
                                ProgressView(value: progress)
                                    .progressViewStyle(ScrumProgressViewStyle(theme: theme))
                                    .opacity(0.85)
                                    
                                    
                            }
                            .padding(.horizontal, 8)
                            .transition(.scale)
                    }
                    else{
                            HStack{
                                VStack(alignment: .leading){
                                    let seconds = String(format: "%02d", secondsElapsed%60)
                                    Label("\(secondsElapsed/60) : \(seconds)", systemImage: "hourglass.bottomhalf.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.gray, .background)
                                        .opacity(0.85)
                                        
                                }
                                Spacer()
                                VStack(alignment: .trailing){
                                    
                                    let seconds = String(format: "%02d", secondsRemaining%60)
                                    Label("\(secondsRemaining/60) : \(seconds)", systemImage: "hourglass.tophalf.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.gray, .background)
                                        .opacity(0.85)
                                    
                                }
                            }
                            .transition(.identity)
                    }
                }
            })
            .toggleStyle(ImageToggleStyle())
            .padding(.horizontal, UIScreen.main.bounds.width/80)

    }
}

struct ImageToggleStyle: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {

        HStack {
            configuration.label

            Spacer()

            RoundedRectangle(cornerRadius: 30)
                .fill(configuration.isOn ? Color(.systemGray5) : Color(.systemGray5))
                
                .overlay {
                    Image(systemName: configuration.isOn ? "hourglass.bottomhalf.fill" : "hourglass.tophalf.fill")
                        .resizable()
                        .scaledToFill()
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .background)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(configuration.isOn ? 0 : -360))
                        .offset(x: configuration.isOn ? 1 : -1)
                        .opacity(0.85)
                        
                }
                .frame(width: UIScreen.main.bounds.width/18, height: UIScreen.main.bounds.height/36)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}


struct MyView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var isShowing:Bool = false
        var body: some View {
            PaintMeHeaderView(isShowing: $isShowing, secondsElapsed: 60, secondsRemaining: 180, theme: .buttercup)
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
