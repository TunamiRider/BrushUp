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

public struct ContentView: View {


    @Environment(\.modelContext) private var context
    @Environment(UnsplashImage.self) private var unsplashImageModel
    @Environment(BrushUpTimer.self) private var brushupTimer
    //@State var brushupTimer = BrushUpTimer()
    @State var presentSideMenu: Bool = false
    
    
    @Binding var minutes: Int
    @Binding var isMonochrone: Bool
    // private let player = AVPlayer.dingPlayer()
    @State private var uiScreenSize = UIScreen.main.bounds.size

    @State private var showOverlay = true
    @State private var isNextImage: Bool = false
    @State private var userDevice = UIDevice.current.userInterfaceIdiom

    @State private var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var previousOrientation: UIDeviceOrientation?
    private var orientationPublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
    @Binding var goMainView: Bool
    @Binding var isResume: Bool
    
    @State private var showPopupView = false;
    @State private var isKeptImage = false;
    
    
    init(goMainView: Binding<Bool>, isResume: Binding<Bool>, minutes: Binding<Int>, isMonochrone: Binding<Bool>) {
        self._goMainView = goMainView
        self._isResume = isResume
        self._minutes = minutes
        self._isMonochrone = isMonochrone
    }
    public var body: some View {
        ZStack(){
            VStack(spacing: 0){
                // Reflect image to the screen
                AsyncImage(url: unsplashImageModel.getImageURL()) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .ignoresSafeArea(.all)
                            .grayscale(isMonochrone ? 1.0 : 0.0)

                } placeholder: {
                    ProgressView()
                        .scaleEffect(x: 2.0, y: 2.0, anchor: .center)
                }

            }

            if(showOverlay){
                VStack(){
                PaintMeHeaderView(isShowing: $isNextImage, secondsElapsed: brushupTimer.secondsElapsed, secondsRemaining: brushupTimer.secondsRemaining, theme: .buttercup)
                        .frame(maxWidth: UIScreen.main.bounds.size.width*0.9,
                               maxHeight: uiScreenSize.height,
                               alignment: .top)

                    
                    BrushUpTabView(isSettings: $presentSideMenu, isHistory: $presentSideMenu, goMainView: $goMainView, uiScreenSize: $uiScreenSize, minutes: $minutes, isMonochrone: $isMonochrone)
                        .frame(maxWidth: UIScreen.main.bounds.size.width*0.9,
                               maxHeight: uiScreenSize.height,
                               alignment: .bottom)
                    
                }.transition(.opacity)
            }
            
            if(showPopupView){
                PopupView(isNextImage: $isNextImage, isKeptImage: $isKeptImage)
            }
            
        }//ZStack
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            isOrientationChanged(currentOrientation, previousOrientation)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 2.0)) {
                showOverlay.toggle()
            }
        }
        .task {
            
            if(!isResume){
                do {
                    try await unsplashImageModel.fetchImage()
                    brushupTimer.start()
                    //UserDefaults.standard.removeObject(forKey: "minutes")

                } catch {
                    print("Failed to fetch data:", error)
                }
            }else {
                isResume.toggle()
                brushupTimer.toggleTimer()
            }


        }
        .onDisappear {
            if brushupTimer.secondsRemaining > 0 {
                isResume.toggle()
                brushupTimer.toggleTimer()
            }else {
                brushupTimer.endTimer()
            }
            
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        .onChange(of: brushupTimer.secondsElapsed){
            
            if(brushupTimer.secondsRemaining==0){
                brushupTimer.toggleTimer()
                showPopupView.toggle()
            }
        }
        .onChange(of: presentSideMenu){

            brushupTimer.toggleTimer()

            let value = UserDefaults.standard.string(forKey: "minutes")
            if let minutes: Int = Int(value ?? "1"){
                self.minutes = minutes
            }

        }
        .onChange(of: isNextImage){
            if(isNextImage){
                isNextImage.toggle()
                showPopupView.toggle()
                brushupTimer.toggleTimer()
                brushupTimer.reset()
                Task{
                    do {
                        try await unsplashImageModel.fetchImage()
                        brushupTimer.reset()
                    } catch {
                        print("Failed to fetch data2 :", error)
                    }
                }
                brushupTimer.start()
            }
        }
        .onChange(of: isKeptImage){
            if(isKeptImage){
                isKeptImage.toggle()
                showPopupView.toggle()
                brushupTimer.toggleTimer()
                brushupTimer.reset()
                brushupTimer.start()
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
        
//        .onReceive(orientationPublisher
//            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
//        ) { _ in
//            self.previousOrientation = self.currentOrientation
//            self.currentOrientation = UIDevice.current.orientation
//            print("Changed \(Date())")
//        }
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
    
//    private func startScrum() {
//        //print("onChanged: \(scrumTimer.secondsElapsed) : \(scrumTimer.secondsRemaining) : scrum: \(scrum.lengthInMinutes) : \(scrum.attendees.map(\.name))");
//        //scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendeeNames: scrum.attendees.map { $0.name })
////        scrumTimer.speakerChangedAction = {
////            //player.seek(to: .zero)
////            //player.play()
////        }
//        // scrumTimer.startScrum()
//        
//        paintTimer.start()
//        
//        
//    }
//    private func endScrum() throws {
//            paintTimer.endTimer()
////        scrumTimer.stopScrum()
////        let newHistory = History(attendees: scrum.attendees)
////        scrum.history.insert(newHistory, at: 0)
////        try context.save()
//    }
    private func mainThreadFetch() -> [TagDTO] {
        let config: ModelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container:ModelContainer = try! ModelContainer(for: Tag.self, configurations: config)
        let context = ModelContext(container)
        do {
            let start = Date()
            let result = try context.fetch(FetchDescriptor<Tag>(sortBy: [SortDescriptor(\Tag.name)]))
            print("Main thread fetch takes \(Date().timeIntervalSince(start))")
            return result.map{TagDTO(id: $0.id, name: $0.name)}
        } catch {
            print(error)
            return []
        }
    }
    
}



#Preview {

    @Previewable @State var dataModel = UnsplashImage()
    @Previewable @State var brushUpTimer = BrushUpTimer()
    @Previewable @State var minutes: Int = 1
    @Previewable @State var isMonochrone: Bool = true
    
    @State var goMainView2: Bool = false
    @State var isResume: Bool = false
    
    ContentView(goMainView: $goMainView2, isResume: $isResume, minutes: $minutes, isMonochrone: $isMonochrone)
        .environment(dataModel)
        .environment(brushUpTimer)
    
}




