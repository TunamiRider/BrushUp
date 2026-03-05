//
//  MainScreen.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/17/26.
//

import SwiftUI

struct MainScreen: View {
    
    @State private var goMainView = false
    @State private var isResume = false
    @State private var isPlaying: Bool = false
    @State private var selectedNumber: Int = 1
    @State private var isMonochrome: Bool = false
    @State private var selectedTab = 0
    
    init(){
//        let appearance = UITabBarAppearance()
//        appearance.backgroundColor = UIColor.systemGray6
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance

//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
        
        //UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.8)
//
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        // UITabBar.appearance().tintColor = UIColor.red  // Selected tab
        
    }
    
    var body: some View {
        
        ZStack {
            //AppConstants.spaceblack.ignoresSafeArea()
            if(goMainView){
                PhotoPlayerScreen(goMainView: $goMainView, isResume: $isResume, minutes: $selectedNumber, isMonochrone: $isMonochrome, isPlaying: $isPlaying)
            }else {
                TabView(selection: $selectedTab) {
                    HomeScreen(goMainView: $goMainView, isResume: $isResume)
                        .tag(0)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        //.background(AppConstants.spaceblack.ignoresSafeArea())
/*                        .background(AppConstants.lightgray, in: Rectangle()) */ // forces dark blur
//                        .preferredColorScheme(.light)
                    
                    
                    HistoryView()
                        .tag(1)
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }
//                        .background(AppConstants.spaceblack, in: Rectangle())  // forces dark blur
//                        .preferredColorScheme(.light)
//                        .background(AppConstants.spaceblack.ignoresSafeArea())
                    
                    Settings(isMonochrone: $isMonochrome, selectedNumber: $selectedNumber)
                        .tag(2)
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
//                        .background(AppConstants.spaceblack.ignoresSafeArea())
                    
                }
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3),
                    value: selectedTab
                )
                
                //            .tabViewStyle(.sidebarAdaptable)
                //            .toolbarBackground(.visible, for: .tabBar).ignoresSafeArea(.all)
                .tint(.white)
            }
        }
        .onAppear {
            let saved = UserDefaults.standard.integer(forKey: "minutes")
            if saved != 0, AppConstants.minutesList.contains(saved) {
                selectedNumber = saved
            }
            isMonochrome = UserDefaults.standard.bool(forKey: "isMonochrome")
        }
/*        .background(AppConstants.spaceblack, in: Rectangle()) */ // forces dark blur
//        .preferredColorScheme(.light)

        //.background(AppConstants.spaceblack.edgesIgnoringSafeArea(.all))

    }
}
//#Preview {
//    let appServices = AppServices()
//    let unsplashPhotoManager = UnsplashPhotoManager(
//        unsplashService: appServices.unsplashService,
//        firebaseService: appServices.firebaseService
//    )
//    
//    MainScreen()
//        .environment(appServices)
//        .environment(unsplashPhotoManager)
//        .environment(BrushUpTimer())
//}
