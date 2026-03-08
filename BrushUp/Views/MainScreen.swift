//
//  MainScreen.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/17/26.
//
import SwiftUI
struct MainScreen: View {
    @State private var selectedTab: Tab = .home
    @State private var isPhotoPlayerScreen: Bool = false
    @State private var isResume: Bool = false
    @State private var isMonochrome: Bool = false
    @State private var isSidebarCollapsed: Bool = true
    @State private var isPlaying: Bool = false
    @State private var sidebarDragOffset: CGFloat = 0
    
    var body: some View {
        
        if isPhotoPlayerScreen {
            PhotoPlayerScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume, isPlaying: $isPlaying)
        }
        else {
            Group {
                if isPad {
                    HStack(spacing: 0) {
                        sidebarView
                            .frame(width: isSidebarCollapsed ? 60 : 280)
                            .animation(.easeInOut(duration: 0.3), value: isSidebarCollapsed)
                        
                        Divider()
                        tabContent
                    }
                } else {
                    VStack(spacing: 0) {
                        tabContent
                        bottomTabBar
                    }
                    .ignoresSafeArea(edges: .bottom)
                    
                }
                
            }
            .background(AppConstants.spaceblack)
        }
    }
    
    // MARK: - Sidebar (Collapsible)
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapse Toggle Button (top)
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSidebarCollapsed.toggle()
                }
            } label: {
                Image(systemName: isSidebarCollapsed ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Divider()
                .opacity(isSidebarCollapsed ? 0 : 1)
            
            // Tab buttons (conditional text)
            VStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack {
                            Image(systemName: tab.image)
                                .frame(width: 24, height: 24)
                            
                            if !isSidebarCollapsed {
                                Text(tab.title)
                                    .font(.body)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                            }
                            
                            Spacer()
                        }
                        .foregroundStyle(selectedTab == tab ? .white : .gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // Pass parameters to tab content
    @ViewBuilder
    private func tabContent(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume)
        case .history:
            HistoryView()
        case .settings:
            Settings(isMonochrome: $isMonochrome)
        }
    }
    
    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tag(tab)
                    
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: selectedTab)
        .clipped() // Clips edge slides
        .tint(.white)

    }
    
    // bottomTabBar unchanged...
    private var bottomTabBar: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack {
                        Image(systemName: tab.image)
                            .font(.title2)
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                        Text(tab.title)
                            .font(.caption2)
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .gray)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        //.background(AppConstants.spaceblack)
    }
    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
#Preview {
    let appServices = AppServices()
    let unsplashPhotoManager = UnsplashPhotoManager(
        unsplashService: appServices.unsplashService,
        firebaseService: appServices.firebaseService
    )
    
    MainScreen()
        .environment(appServices)
        .environment(unsplashPhotoManager)
        .environment(BrushUpTimer())
}


//import SwiftUI
//
//struct MainScreen: View {
//    
//    @State private var goMainView = false
//    @State private var isResume = false
//    @State private var isPlaying: Bool = false
//    @State private var selectedNumber: Int = 1
//    @State private var isMonochrome: Bool = false
//    @State private var selectedTab = 0
//    
//    init(){
////        let appearance = UITabBarAppearance()
////        appearance.backgroundColor = UIColor.systemGray6
////        UITabBar.appearance().standardAppearance = appearance
////        UITabBar.appearance().scrollEdgeAppearance = appearance
//
////        if #available(iOS 15.0, *) {
////            UITabBar.appearance().scrollEdgeAppearance = appearance
////        }
//        
//        //UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.8)
////
//        UITabBar.appearance().unselectedItemTintColor = UIColor.white
//        // UITabBar.appearance().tintColor = UIColor.red  // Selected tab
//        
//    }
//    
//    var body: some View {
//        
//        ZStack {
//            //AppConstants.spaceblack.ignoresSafeArea()
//            if(goMainView){
//                PhotoPlayerScreen(goMainView: $goMainView, isResume: $isResume, minutes: $selectedNumber, isMonochrone: $isMonochrome, isPlaying: $isPlaying)
//            }else {
//                TabView(selection: $selectedTab) {
//                    HomeScreen(goMainView: $goMainView, isResume: $isResume)
//                        .tag(0)
//                        .tabItem {
//                            Label("Home", systemImage: "house")
//                        }
//
//                    HistoryView()
//                        .tag(1)
//                        .tabItem {
//                            Label("History", systemImage: "clock.fill")
//                        }
//                    
//                    Settings(isMonochrone: $isMonochrome, selectedNumber: $selectedNumber)
//                        .tag(2)
//                        .tabItem {
//                            Label("Settings", systemImage: "gear")
//                        }
//                    
//                }
//                .animation(
//                    .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3),
//                    value: selectedTab
//                )
//                .tint(.white)
//            }
//        }
//        .onAppear {
//            let saved = UserDefaults.standard.integer(forKey: "minutes")
//            if saved != 0, AppConstants.minutesList.contains(saved) {
//                selectedNumber = saved
//            }
//            isMonochrome = UserDefaults.standard.bool(forKey: "isMonochrome")
//        }
//
//    }
//}
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
