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
    @State private var isWeeklyList: Bool = true
    private let frameSize:CGFloat = 32
    var body: some View {
        ZStack {
            
            if isPhotoPlayerScreen {
                PhotoPlayerScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume, isPlaying: $isPlaying)
            }
            else {
                Group {
                    if AppConstants.isiPad {
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
        .onAppear {
            let saved = UserDefaults.standard.integer(forKey: "minutes")
            if saved == 0 {
                UserDefaults.standard.set(5, forKey: "minutes")
            }
        }
        
//        ZStack {
//
//
//            // Photo Player overlay
//            if isPhotoPlayerScreen {
//                PhotoPlayerScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume, isPlaying: $isPlaying)
//                    .transition(.asymmetric(
//                        insertion: .move(edge: .bottom).combined(with: .opacity),
//                        removal: .scale.combined(with: .opacity)
//                    ))
//            }else {
//                // Main content (Home Screen)
//                Group {
//                    if AppConstants.isiPad {
//                        HStack(spacing: 0) {
//                            sidebarView
//                                .frame(width: isSidebarCollapsed ? 60 : 280)
//                                .animation(.easeInOut(duration: 0.3), value: isSidebarCollapsed)
//                            Divider()
//                            tabContent
//                        }
//                    } else {
//                        VStack(spacing: 0) {
//                            tabContent
//                            bottomTabBar
//                        }
//                        .ignoresSafeArea(edges: .bottom)
//                    }
//                }
//                .background(AppConstants.spaceblack)
//                .transition(.asymmetric(
//                    insertion: .move(edge: .bottom).combined(with: .opacity),
//                    removal: .scale.combined(with: .opacity)
//                ))
//            }
//        }
//        .animation(.easeInOut(duration: 0.4), value: isPhotoPlayerScreen)
    }
    
    // MARK: - Sidebar (Collapsible)
    private var sidebarView: some View {
        ZStack(alignment: .leading) {
            // Invisible overlay for full-height swipe area
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            if value.translation.width > 50 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isSidebarCollapsed = false
                                }
                            } else if value.translation.width < -50 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isSidebarCollapsed = true
                                }
                            }
                        }
                )
            VStack(alignment: .leading, spacing: 0) {
                // Collapse Toggle Button (top)
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSidebarCollapsed.toggle()
                    }
                } label: {
                    Image(systemName: isSidebarCollapsed ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                        .font(AppConstants.boldRoundedFont)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .rotationEffect(.degrees(isSidebarCollapsed ? 0 : -0))
                        .animation(.easeInOut(duration: 0.3), value: isSidebarCollapsed)
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
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: frameSize, height: frameSize)
                                    
                                    
                                if !isSidebarCollapsed {
                                    Text(tab.title)
                                        .font(AppConstants.boldRoundedFont)
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
            HistoryView(isWeeklyList: $isWeeklyList)
        case .settings:
            Settings(isMonochrome: $isMonochrome)
        }
    }
    
//    private var tabContent: some View {
//        TabView(selection: $selectedTab) {
//            ForEach(Tab.allCases, id: \.self) { tab in
//                tabContent(for: tab)
//                    .tag(tab)
//                    
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .never))
//        .indexViewStyle(.page(backgroundDisplayMode: .always))
//        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: selectedTab)
//        .clipped() // Clips edge slides
//        .tint(.white)
//    }
//    private var tabContent: some View {
//        Group {
//            if selectedTab == .home {
//                HomeScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume)
//            }
//            if selectedTab == .history {
//                HistoryView(isWeeklyList: $isWeeklyList)
//            }
//            if selectedTab == .settings {
//                Settings(isMonochrome: $isMonochrome)
//            }
//        }
//        .animation(.easeInOut(duration: 0.3), value: selectedTab)
//        .transition(.asymmetric(
//            insertion: .move(edge: .trailing).combined(with: .opacity),
//            removal: .move(edge: .leading).combined(with: .opacity)
//        ))
//    }
//    private var tabContent: some View {
//        TabView(selection: $selectedTab) {
//            ForEach(Tab.allCases, id: \.self) { tab in
//                tabContent(for: tab)
//                    .tag(tab)
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .never))
//        .indexViewStyle(.page(backgroundDisplayMode: .always))
//        .clipped()
//        .tint(.white)
//        // ✅ Short tab animation - completes before HistoryView triggers
//        .animation(.easeInOut(duration: 0.2), value: selectedTab)
//    }
    
//    private var tabContent: some View {
//        GeometryReader { geometry in
//            HStack(spacing: 0) {
//                Group {
//                    HomeScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume)
//                    HistoryView(isWeeklyList: $isWeeklyList)
//                    Settings(isMonochrome: $isMonochrome)
//                }
//                .frame(width: geometry.size.width)
//            }
//            .frame(width: geometry.size.width * 3)
//            .offset(x: -CGFloat(selectedTab.rawValue) * geometry.size.width)
//            .gesture(
//                DragGesture()
//                    .onEnded { value in
//                        let offset = value.translation.width / geometry.size.width
//                        let newIndex = selectedTab.rawValue + (offset > 0 ? -1 : 1)
//                        if newIndex >= 0 && newIndex < Tab.allCases.count {
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                selectedTab = Tab.allCases[Int(newIndex)]
//                            }
//                        }
//                    }
//            )
//        }
//        .animation(.easeInOut(duration: 0.3), value: selectedTab)
//        .clipped()
//    }
    
    private var tabContent: some View {
        GeometryReader { geometry in  // geometry scoped HERE ↓
            HStack(spacing: 0) {
                HomeScreen(goMainView: $isPhotoPlayerScreen, isResume: $isResume)
                HistoryView(isWeeklyList: $isWeeklyList)
                Settings(isMonochrome: $isMonochrome)
            }
            .frame(width: geometry.size.width * 3)  // ✅ Uses geometry
            .offset(x: -CGFloat(selectedTab.rawValue) * geometry.size.width)  // ✅ Uses geometry
            .gesture(  // ✅ Gesture INSIDE GeometryReader - geometry accessible
//                DragGesture(minimumDistance: 30, coordinateSpace: .local)
//                    .onEnded { value in
//                        let horizontalAmount = value.translation.width / geometry.size.width  // ✅ Works!
//                        let newIndex = selectedTab.rawValue - Int(horizontalAmount > 0 ? 1 : -1)
//                        
//                        if newIndex >= 0 && newIndex < Tab.allCases.count {
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                selectedTab = Tab.allCases[newIndex]
//                            }
//                        }
//                    }
                DragGesture(minimumDistance: 5)
                    .onEnded { value in
                        //OPtion 1
                        // ✅ FIXED: Check predictedEndTranslation (not translation)
//                        let predictedOffset = value.predictedEndTranslation.width
//                        let shouldSwipeLeft = predictedOffset < -10  // Swipe to NEXT tab
//                        let shouldSwipeRight = predictedOffset > 10  // Swipe to PREV tab
//                        
//                        let newIndex: Int
//                        if shouldSwipeLeft {
//                            print("Left Swipe")
//                            newIndex = min(selectedTab.rawValue + 1, Tab.allCases.count - 1)
//                        } else if shouldSwipeRight {
//                            print("Right Swipe")
//                            newIndex = max(selectedTab.rawValue - 1, 0)
//                        } else {
//                            print("not enought")
//                            return  // Not enough swipe distance
//                        }
//                        
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            selectedTab = Tab.allCases[newIndex]
//                        }
                        
                        //Option 2
                        let dragThreshold: CGFloat = 10  // Smaller threshold
                        let xMovement = abs(value.translation.width)
                        
                        guard xMovement > dragThreshold else { return }
                        
                        let newIndex: Int
                        if value.translation.width > 0 {
                            // Right swipe → PREVIOUS tab (Home→History works!)
                            newIndex = max(selectedTab.rawValue - 1, 0)
                        } else {
                            // Left swipe → NEXT tab
                            newIndex = min(selectedTab.rawValue + 1, Tab.allCases.count - 1)
                        }
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = Tab.allCases[newIndex]
                        }
                        
                        //Option 3
//                        let xMovement = value.translation.width  // Use translation.x (not predicted)
//                        
//                        // Left swipe (negative X) → NEXT tab (Home 0 → History 1)
//                        // Right swipe (positive X) → PREVIOUS tab
//                        let threshold: CGFloat = 30
//                        guard abs(xMovement) > threshold else {
//                            print("Not enough swipe distance")
//                            return
//                        }
//                        
//                        let newIndex: Int
//                        print("Swipe detected: \(xMovement > 0 ? "Right" : "Left")")
//                        
//                        if xMovement > 0 {
//                            // Right swipe → PREVIOUS (History→Home)
//                            newIndex = max(selectedTab.rawValue - 1, 0)
//                            print("Going to index: \(newIndex)")
//                        } else {
//                            // Left swipe → NEXT (Home→History)
//                            newIndex = min(selectedTab.rawValue + 1, Tab.allCases.count - 1)
//                            print("Going to index: \(newIndex)")
//                        }
//                        
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            selectedTab = Tab.allCases[newIndex]
//                        }
                    }
            )
            .contentShape(Rectangle())
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .clipped()

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
    
//    private var isPad: Bool {
//        UIDevice.current.userInterfaceIdiom == .pad
//    }
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
