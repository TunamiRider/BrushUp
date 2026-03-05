//
//  TimerPlayView.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/26/26.
//
import SwiftUI
import ThemeKit
import TimerKit
import Combine
struct TimerPlayView: View {
    let secondsElapsed: Int
    let secondsRemaining: Int
    @Environment(BrushUpTimer.self) private var brushupTimer
    
    private var totalSeconds: Int {
        secondsElapsed + secondsRemaining
    }
    @State var isDimmed = false
    @State private var dimTimerToken: String = UUID().uuidString
    private var progress: Double {
        guard totalSeconds > 0 else { return 1 }
        return Double (secondsElapsed) / Double(totalSeconds)
    }
    //Player button controls
    @Binding var isNext: Bool
    @Binding var isPrevious: Bool
    @Binding var isHome: Bool
    @Binding var isSettings: Bool
    
    @Binding var isPaused: Bool
    @State private var dimTimer: Timer?

    var body: some View {
        ZStack {
            AppConstants.spaceblack
                .ignoresSafeArea()
            //GeometryReader { geometry in
                VStack{
                    //Spacer()
                    HStack {
                        VStack(alignment: .leading){
                            let seconds = String(format: "%02d", secondsElapsed%60)
                            Text("\(secondsElapsed/60) : \(seconds)")
                                .foregroundStyle(.white, .background)
                                .font(.subheadline)
                                .opacity(0.85)
                            
                        }
                        .opacity((isDimmed && secondsRemaining>0) ? 0 : 1.0)
                        .animation(.easeInOut(duration: 0.8), value: isDimmed)
                        
                        ProgressView(value: progress)
                            .progressViewStyle(ScrumProgressViewStyle(theme: .bubblegum))
                            .frame(height: 10)
                            .opacity(0.85)
                            .animation(.linear(duration: 0.1), value: progress)
                        
                        VStack(alignment: .trailing){
                            
                            let seconds = String(format: "%02d", secondsRemaining%60)
                            Text("\(secondsRemaining/60) : \(seconds)")
                                .foregroundStyle(.white, .background)
                                .font(.subheadline)
                                .opacity(0.85)
                            
                        }
                        .opacity((isDimmed && secondsRemaining>0) ? 0 : 1.0)
                        .animation(.easeInOut(duration: 1), value: isDimmed)
                    }
                    .padding(.horizontal, 8)
                    .transition(.scale)
                    
                    HStack {
                        // Left: Home
                        Button(action: {
                            // home action
                            isHome.toggle()
                        }) {
                            Image(systemName: "house")
                                .font(.title2)
                        }
                        .padding(.horizontal, 18)
                        .opacity((isDimmed && secondsRemaining>0) ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 1), value: isDimmed)
                        
                        Spacer()
                        
                        // Middle: Previous, Pause, Next
                        HStack(spacing: 24) {
                            Button(action: {
                                // previous action
                                isPrevious.toggle()
                            }) {
                                Image(systemName: "backward.end")
                                    .font(.title)
                            }
                            .padding(.horizontal, 18)
                            .opacity((isDimmed && secondsRemaining>0) ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 1), value: isDimmed)
                            
                            Button(action: {
                                isPaused.toggle()
                                isDimmed.toggle()
                            }) {
                                Group {
                                    !isPaused ?
                                    Image(systemName: "pause.rectangle")
                                        .font(.title) :
                                    Image(systemName: "play.circle")
                                        .font(.title)
                                }
                                .frame(width: 32, height: 32)  // fixed size - prevents layout shift
                                .clipped()
                            }
                            .padding(.horizontal, 18)
                            .opacity(isDimmed ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 1), value: isDimmed)
                            .disabled(secondsRemaining<=0)
                            
                            
                            Button(action: {
                                // next action
                                isNext.toggle()
                            }) {
                                Image(systemName: "forward.end")
                                    .font(.title)
                            }
                            .padding(.horizontal, 18)
                            .opacity((isDimmed && secondsRemaining>0) ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 1), value: isDimmed)
                        }
                        
                        Spacer()
                        
                        // Right: Settings
                        Button(action: {
                            // settings action
                            isSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                        }
                        .padding(.horizontal, 18)
                        .opacity((isDimmed && secondsRemaining>0) ? 0.3 : 1.0)
                        .animation(.easeInOut(duration: 1), value: isDimmed)
                    }
//                    .opacity(isDimmed ? 0.3 : 1.0)
//                    .animation(.easeInOut(duration: 1), value: isDimmed)
                    //.padding()
                    .foregroundStyle(.white)
                }
//                .frame(height: geometry.size.height / 10)  // Exactly 1/10 height
//                .frame(maxHeight: .infinity, alignment: .bottom)  // Align to bottom
                
            //}
            .onChange(of: isPaused) {
                
                dimTimer?.invalidate()
                
                if !isPaused { // when playing (not paused)
                    isDimmed = false
                    dimTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                        DispatchQueue.main.async {
                            isDimmed = true  // ✅ Runs on main actor
                        }
                    }
                }
            }
        }
        
    }
}

//#Preview{
//    @Previewable @State var secondsElapsed: Int = 60
//    @Previewable @State var  secondsRemaining: Int = 60
//    @Previewable @State var isNext: Bool = false
//    @Previewable @State var isPrevious: Bool = false
//    @Previewable @State var isHome: Bool = false
//    @Previewable @State var isSettings: Bool = false
//    @Previewable @State var isPaused2: Bool = false
//    
//    TimerPlayView(secondsElapsed: 60, secondsRemaining: 60,isNext: $isNext, isPrevious: $isPrevious, isHome: $isHome, isSettings: $isSettings, isPaused: $isPaused2).border(Color.red)
//
//}
