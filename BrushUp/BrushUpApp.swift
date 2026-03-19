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

@MainActor
@Observable
final class AppServices {
    let firebaseService: FirebaseService
    let unsplashService: UnsplashService
    
    init(){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let fetchService = FetchService()
        let firebaseService = FirebaseService(uuidString: deviceID)
        self.firebaseService = firebaseService
        self.unsplashService = UnsplashService(fetchService: fetchService, firebaseService: firebaseService)
    }
}
@main
struct BrushUpApp: App {
    @State var brushUpTimer = BrushUpTimer()
    @State var appServices = AppServices()
    @State var appActiveObserver = AppActiveObserver.shared
    
    private var unsplashPhotoManager: UnsplashPhotoManager {
        UnsplashPhotoManager(
            unsplashService: appServices.unsplashService,
            firebaseService: appServices.firebaseService
        )
    }
    
    @State var goMainView = false
    @State var isResume = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    init() {
        // ✅ Perfectly safe - runs after Bundle.main is ready
//        let key = Secrets.apiKey
//        print("\(key)")
//        print("🚀 App launched - API Key: '\(key.isEmpty ? "MISSING" : "LOADED")'")
//        print("=== FULL DIAGNOSTIC ===")
//        print("1. Info.plist keys: \(Bundle.main.infoDictionary?.keys)")
//        print("2. MY_API_KEY raw: \(Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_KEY") ?? "MISSING")")
//        print("3. Secrets.apiKey: '\(Secrets.apiKey)'")
//        print("======================")
    }
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environment(appServices)
                .environment(brushUpTimer)
                .environment(unsplashPhotoManager)
                .environment(appActiveObserver)
        }
    }
}
