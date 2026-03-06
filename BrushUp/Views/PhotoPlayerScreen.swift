//
//  ContentView.swift
//  PaintMe
//
//  Created by Yuki Suzuki on 5/6/25.
//

import SwiftUI
import UIKit
import SwiftData
import Combine

public struct PhotoPlayerScreen: View {

    @Environment(UnsplashPhotoManager.self) private var photoManager
    @Environment(\.modelContext) private var context
    @Environment(BrushUpTimer.self) private var brushupTimer

    @Binding var minutes: Int
    @Binding var isMonochrone: Bool
    @Binding var goMainView: Bool
    @Binding var isResume: Bool
    @Binding var isPlaying: Bool
    
    @State var isSettings = false
    @State private var isNext: Bool = false
    @State private var isPrevious = false
    @State private var isPaused: Bool = true

    // private let player = AVPlayer.dingPlayer()
    @State private var uiScreenSize = UIScreen.main.bounds.size
    @State private var userDevice = UIDevice.current.userInterfaceIdiom
    @State private var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var previousOrientation: UIDeviceOrientation?
    private var orientationPublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)

    var shouldRefresh: Bool {
        isNext || brushupTimer.secondsElapsed <= 0
    }
    
    init(goMainView: Binding<Bool>, isResume: Binding<Bool>, minutes: Binding<Int>, isMonochrone: Binding<Bool>, isPlaying: Binding<Bool>) {
        self._goMainView = goMainView
        self._isResume = isResume
        self._minutes = minutes
        self._isMonochrone = isMonochrone
        self._isPlaying = isPlaying
    }
    public var body: some View {
        ZStack(alignment: .bottom){
            VStack(spacing: 0){
                // Reflect image to the screen
                AsyncImage(url: photoManager.photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .ignoresSafeArea(.all)
                            .grayscale(isMonochrone ? 1.0 : 0.0)

                } placeholder: {
                    ProgressView()
                        .scaleEffect(x: 2.0, y: 2.0, anchor: .center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .ignoresSafeArea(.all)
                }
                //.ignoresSafeArea(.container, edges: .top)
                //.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .bottom)
                
                
                TimerPlayView(isNext: $isNext, isPrevious: $isPrevious, isHome: $goMainView, isSettings: $isSettings, isPaused: $isPaused)
                    //.id(isNext)
                    //.id(brushupTimer.secondsElapsed)
                    .ignoresSafeArea(.all)
                    //.frame(maxHeight: .infinity, alignment: .bottom)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 14, alignment: .bottom)
                    //.ignoresSafeArea(.container)
                    //.padding(.horizontal, 20)
                    .ignoresSafeArea(.container, edges: .bottom)


            }
            .sheet(isPresented: $isSettings) {
                Settings(isMonochrone: $isMonochrone, selectedNumber: $minutes)
                    .presentationDetents([.medium, .large])
                    .grayBackgroundStyle()
            }
            

        }//ZStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            isOrientationChanged(currentOrientation, previousOrientation)
        }
        .task {
            if(!isResume){
                await photoManager.fetchRandomPhoto()
                brushupTimer.reset()
                brushupTimer.start()
                //brushupTimer.toggleTimer()
                //isPaused = true
            }else {
                isResume.toggle()
            }
        }
        .onDisappear {
            if brushupTimer.secondsRemaining > 0 {
                isResume = true
                brushupTimer.stop()
            }else {
                brushupTimer.endTimer()
            }
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        .onChange(of: isPaused){

            if(isPaused){
                brushupTimer.stop()
                isPlaying = false
            }else{
                brushupTimer.play()
                isPlaying = true
            }
        }
        .onChange(of: isNext){oldValue, newValue in
            guard newValue else { return }
            isPaused = false
            isNext = false
            brushupTimer.stop()
            brushupTimer.reset()

            Task{
                await photoManager.fetchRandomPhoto()
                brushupTimer.start()
                
                brushupTimer.play()
//                brushupTimer.stop()
//                print("Task... ")
            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

//            }
        }
        .onChange(of: brushupTimer.secondsElapsed){
            if(brushupTimer.secondsRemaining==0){
                //isPaused = true
                brushupTimer.stop()
            }
        }
        .onChange(of: isSettings){
            if(isSettings && brushupTimer.secondsRemaining>0){
                isPaused = true
            }
        }
//        .onChange(of: brushupTimer.secondsElapsed){
//
//            if(brushupTimer.secondsRemaining==0){
//                brushupTimer.stop()
//                isPaused = true
//                //brushupTimer.reset()
//                Task {
//                    await photoManager.savePhotoData()
//                    //await photoManager.fetchRandomPhoto()
//                    //brushupTimer.start()//test
//                    //brushupTimer.toggleTimer()//test
//                }
//                //brushupTimer.start()
//            }
//        }
//        .onChange(of: isSettings){
//            
//            
//            if isPlaying {
//                brushupTimer.toggleTimer()
//            }
//
//            let value = UserDefaults.standard.string(forKey: "minutes")
//            if let minutes: Int = Int(value ?? "1"){
//                self.minutes = minutes
//            }
//        }

        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let newOrientation = UIDevice.current.orientation
            if newOrientation.isValidInterfaceOrientation && newOrientation != self.currentOrientation {
                self.previousOrientation = self.currentOrientation
                self.currentOrientation = newOrientation
                isOrientationChanged(currentOrientation, previousOrientation)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    private func isOrientationChanged(_ curr: UIDeviceOrientation?, _ prev: UIDeviceOrientation?) {

        let currentUiSize = UIScreen.main.bounds.size

        if userDevice == .phone {
            switch (curr, prev) {
            case (.portrait, .none), (.portraitUpsideDown, .none), (.portrait, _):
                uiScreenSize.height = currentUiSize.height*0.9
                
            case (.landscapeLeft, .none), (.landscapeLeft, _), (.landscapeRight, .none), (.landscapeRight, _):
                uiScreenSize.height = currentUiSize.height*0.18
            default:
                uiScreenSize.height = currentUiSize.height*0.9
            }
        }

        if userDevice == .pad {
            switch (curr, prev) {
            case (.portrait, .none), (.portraitUpsideDown, .none), (.portrait, _):
                uiScreenSize.height = currentUiSize.height*0.45
            case (.landscapeLeft, .none), (.landscapeLeft, _), (.landscapeRight, .none), (.landscapeRight, _):
                uiScreenSize.height = currentUiSize.height*0.3
            default:
                uiScreenSize.height = currentUiSize.height*0.45
            }
        }
    }
}



#Preview {
    @Previewable @State var brushUpTimer = BrushUpTimer()
    @Previewable @State var minutes: Int = 1
    @Previewable @State var isMonochrone: Bool = true
    
    // @Previewable @State var fireBaseService = FirebaseService()
    @Previewable @State var appServices = AppServices()
    // @Previewable @State var unsplashService = UnsplashService(fetchService: FetchService())
    
    var unsplashPhotoManager: UnsplashPhotoManager {
        UnsplashPhotoManager(
            unsplashService: appServices.unsplashService,
            firebaseService: appServices.firebaseService
        )
    }
    
    @State var goMainView2: Bool = false
    @State var isResume: Bool = false
    @State var isPlaying: Bool = false
    
    PhotoPlayerScreen(goMainView: $goMainView2, isResume: $isResume, minutes: $minutes, isMonochrone: $isMonochrone, isPlaying: $isPlaying)
        .environment(brushUpTimer)
        .environment(unsplashPhotoManager)
        .environment(appServices)
    
}




