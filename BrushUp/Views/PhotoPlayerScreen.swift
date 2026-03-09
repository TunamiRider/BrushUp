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

    //@State var minutes: Int = 1
    @State var isMonochrome: Bool = false
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
    
    init(goMainView: Binding<Bool>, isResume: Binding<Bool>, isPlaying: Binding<Bool>) {
        self._goMainView = goMainView
        self._isResume = isResume
        self._isPlaying = isPlaying
    }
    public var body: some View {
        ZStack(alignment: .bottom){
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    AsyncImage(url: photoManager.photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: geometry.size.height * 0.9)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .scaleEffect(x: 2.0, y: 2.0, anchor: .center)
                            .frame(height: geometry.size.height * 0.9)
                    }
                    .grayscale(isMonochrome ? 1.0 : 0.0)
                
                    
                    TimerPlayView(isNext: $isNext, isPrevious: $isPrevious, isHome: $goMainView, isSettings: $isSettings, isPaused: $isPaused)
                    .sheet(isPresented: $isSettings) {
                        Settings(isMonochrome: $isMonochrome)
                            .presentationDetents([.medium, .large],
                             selection: .constant(
                                // iPhone: medium, iPad: large
                                AppConstants.isiOS ?
                                PresentationDetent.large :
                                    PresentationDetent.medium
                             ))
                            .presentationDragIndicator(.visible)
                            .background(AppConstants.spaceblack)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
            .ignoresSafeArea()
        }//ZStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            isOrientationChanged(currentOrientation, previousOrientation)
            isMonochrome = UserDefaults.standard.bool(forKey: "isMonochrome")
        }
        .task {
            if(!isResume){
                await photoManager.fetchRandomPhoto()
                brushupTimer.reset()
                brushupTimer.start()
                
                brushupTimer.stop()
                //brushupTimer.toggleTimer()
                isPaused = true

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
                if photoManager.isNextPhotoAvailable() {
                    await photoManager.fetchNextPhoto()
                }else {
                    await photoManager.fetchRandomPhoto()
                }

                brushupTimer.start()
                brushupTimer.play()
            }
            //print("next button clicked")
        }
        .onChange(of: isPrevious){oldValue, newValue in
            guard newValue else { return }
            
            if !photoManager.isPreviousPhotoAvailable() {
                isPrevious = false
                return
            }
            
            isPaused = false
            isPrevious = false
            brushupTimer.stop()
            brushupTimer.reset()
            
            Task {
                if photoManager.isPreviousPhotoAvailable() {
                    await photoManager.fetchPreviousPhoto()
                }
                
                brushupTimer.start()
                brushupTimer.play()
            }
            //print("previous button clicked")
        }
        .onChange(of: brushupTimer.secondsElapsed){
            if(brushupTimer.secondsRemaining==0){
                //isPaused = true
                brushupTimer.stop()
                Task {
                    await photoManager.savePhotoData()
                }
            }
        }
        .onChange(of: isSettings){
            if(isSettings && brushupTimer.secondsRemaining>0){
                isPaused = true
            }
        }
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
//    @Previewable @State var minutes: Int = 1
//    @Previewable @State var isMonochrone: Bool = false
    
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
    
    PhotoPlayerScreen(goMainView: $goMainView2, isResume: $isResume, isPlaying: $isPlaying)
        .environment(brushUpTimer)
        .environment(unsplashPhotoManager)
        .environment(appServices)
    
}




