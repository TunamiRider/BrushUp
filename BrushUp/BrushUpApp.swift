//
//  BrushUpApp.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 5/6/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
      //let db = Firestore.firestore()
      
    return true
  }
}

@main
struct BrushUpApp: App {
    @State var unsplashImage = UnsplashImage()
    @State var brushUpTimer = BrushUpTimer()
    @State var fireBaseService = FirebaseService()
    
    @State var goMainView = false
    @State var isResume = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomePageMain()
                .environment(fireBaseService)
                .environment(unsplashImage)
                .environment(brushUpTimer)
//            ContentView(goMainView: $goMainView, isResume: $isResume)
//                .environment(dataModel).environment(brushUpTimer)
        }
    }
}
