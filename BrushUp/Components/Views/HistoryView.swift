//
//  HistoryView.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 10/19/25.
//
import SwiftUI

struct HistoryView: View {
    //@Environment(FirebaseService.self) private var firebaseService
    @Environment(AppServices.self) var services
    private let rows = [GridItem(.flexible())]  // One column for LazyVGrid

    @State private var historyViewModel: HistoryViewModel?
    @State private var showFullScreen = false
    @State private var selectedURL: URL? = nil
    //@State private var isWeeklyList: Bool = true
    @Binding var isWeeklyList: Bool
    @State private var sortedList: [(key: String, value: [URL])] = [] // Array of Tuple
    @State private var numOfYearlyGridItems: Int =  AppConstants.isiPad ? 8 : 3
    
    //TEST
    @State private var currentFullScreenIndex = 0
    @State private var fullScreenURLs: [URL] = []
    //TEST
    
    private func getDailyActivityHistoryList(){
        let viewModel = historyViewModel ?? {
            let vm = HistoryViewModel(firebaseService: services.firebaseService)
            historyViewModel = vm
            Task {await vm.loadHistory() }
            return vm
        }()
        viewModel.getDailyActivityHistoryList()
        sortedList = viewModel.getDisplayHistoryList()
    }
    private func getMonthlyActivityHistryList(){
        let viewModel = historyViewModel ?? {
            let vm = HistoryViewModel(firebaseService: services.firebaseService)
            historyViewModel = vm
            Task {await vm.loadHistory() }
            return vm
        }()
        viewModel.getMonthlyActivityHistoryList()
        sortedList = viewModel.getDisplayHistoryList()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                VStack {
                    HStack(spacing: 20) {
                        
                        Text(isWeeklyList ? "Daily History" : "Monthly History")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                            .font(AppConstants.boldRoundedFont)
                        
                        Group {
                            isWeeklyList ? Image(systemName: "calendar.circle")
                                .foregroundStyle(isWeeklyList ? .white : .gray)
                                .font(AppConstants.boldRoundedFont)
                                .onTapGesture {
                                    showFullScreen = false
                                    isWeeklyList = false
                                    getMonthlyActivityHistryList()
                                }
                            
                            :Image(systemName: "calendar")
                                .foregroundStyle(isWeeklyList ? .gray: .white)
                                .font(AppConstants.boldRoundedFont)
                                .onTapGesture {
                                    showFullScreen = false
                                    isWeeklyList = true
                                    getDailyActivityHistoryList()
                                }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    //.imageScale(.large)
                    .foregroundStyle(.gray)
                    .padding()
                    .animation(.easeInOut(duration: 0.35), value: isWeeklyList)
                }
                
                ScrollView {// Vertical scroll for the whole grid
                    
                    //Group {
                    LazyVGrid(columns: rows, spacing: 10) {
                        if isWeeklyList {
                            retrieveWeeklyHistoryList2()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        } else {
                            retrieveYearlyHistoryList2()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: isWeeklyList)
                }
                
                .task {
                    do {
                        showFullScreen = false
                        historyViewModel = HistoryViewModel(firebaseService: services.firebaseService)
                        await historyViewModel?.loadHistory()
                        getDailyActivityHistoryList()
                    }
//                    catch {
//                        print("Failed to load data: \(error)")
//                    }
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func retrieveWeeklyHistoryList2() -> some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(sortedList, id: \.key) { key, urls in
                // Header
                Text(key)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                    .foregroundStyle(.white)
                    .font(AppConstants.mediumRoundedFont)
                
                // Horizontal scroll row (wrapped to match yearly structure)
                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHGrid(rows: [GridItem(.fixed(80))],spacing: 10) {
//                        ForEach(urls, id: \.self) { item in
//                            imageCell(for: item)
//                        }
//                    }
//                    .padding(.horizontal)
                    LazyHGrid(rows: [GridItem(.fixed(80))], spacing: 10) {
                        ForEach(Array(urls.enumerated()), id: \.offset) { index, item in
                            imageCell2(for: item, at: index, urls: urls)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
        }
    }

    @ViewBuilder
    fileprivate func retrieveYearlyHistoryList2() -> some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(Array(sortedList), id: \.key) { key, urls in
                Text(key)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                    .foregroundStyle(.white)
                    .font(AppConstants.mediumRoundedFont)
                
                // 3-per-row groups
                ForEach(Array(stride(from: 0, to: urls.count, by: numOfYearlyGridItems).map{ i in
                    Array(urls[i..<Swift.min(i + numOfYearlyGridItems, urls.count)])
                }), id: \.first!) { group in
//                    LazyHGrid(rows: [GridItem(.fixed(80))], spacing: 10) {
//                        ForEach(group, id: \.self) { url in
//                            imageCell(for: url)
//                        }
//                    }
//                    .padding(.horizontal)
                    LazyHGrid(rows: [GridItem(.fixed(80))], spacing: 10) {
                        ForEach(Array(group.enumerated()), id: \.offset) { index, item in
                            imageCell2(for: item, at: index, urls: group)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    
    private struct FullScreenImageView: View {
        @Binding var showFullScreen: Bool
        @Binding var selectedURL: URL?
        @State private var isScaledToFit = true
        //let url: URL
        //@Environment(\.dismiss) private var dismiss
        
        var body: some View {
            VStack(){

                //Color.black.ignoresSafeArea()
                AsyncImage(url: selectedURL!) { image in
                    image
                        .resizable()
                        .scaleEffect(isScaledToFit ? 1.0 : 0.8) // Optional: add zoom effect during transition
                        .scaledToFill() // Default
                        .transformEffect(isScaledToFit ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)) // Smooth transition helper
                        .clipped()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .animation(.easeInOut(duration: 0.3), value: isScaledToFit) // Smooth toggle animation
                        .onTapGesture(count: 1) {
                            withAnimation(.spring()) {
                                if !AppConstants.isiPad {
                                    isScaledToFit.toggle()
                                }
                                
                            }
                        }
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            }
            .background(AppConstants.spaceblack)
            .overlay(alignment: .top) {
                    
                GeometryReader { geo in
                    Button {
                        showFullScreen = false
                        //print("geo.size.width: \(geo.size.width) geo.size.height:\(geo.size.height)")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: AppConstants.isiPad ? 64 : 42, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: AppConstants.isiPad ? 66 : 44, height: AppConstants.isiPad ? 66 : 44)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 0)
                    }
                    .position(
                        x: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.width / 1.45 :geo.size.width / 1.1) : (geo.size.width > geo.size.height ? geo.size.width / 1.75 : geo.size.width / 1.5),
                        y: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.height / 10 : geo.size.height / 8) : geo.size.height / 10
                    )
                }
            }.padding(0)
            .overlay(alignment: .bottom) {
                GeometryReader { geo in
                    VStack {
                        HStack {
                            Image("InstagramIcon")
                                .resizable()
                                .frame(width: 18, height: 18)
                            Text("Description")
                                .font(AppConstants.mediumRoundedFont)
                        }
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .position(
                        x: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.width / 1.5 : geo.size.width / 1.1) : (geo.size.width > geo.size.height ? geo.size.width / 1.9 : geo.size.width / 1.7),
                        y: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.height / 1.05 : geo.size.height / 1.1) : geo.size.height / 1.05
                    )
                }
            }
            .ignoresSafeArea()
        }
    }
    
    //TEST
    private struct FullScreenImageView2: View {
        @Binding var showFullScreen: Bool
        @Binding var selectedURL: URL?
        @State private var isScaledToFit = true
        @Binding var currentIndex: Int
        @Binding var urls: [URL] // Pass the full array here
        
        // You'll need to pass the full urls array and current index from parent
        var body: some View {
            GeometryReader { geo in
                TabView(selection: $currentIndex) {
                    ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaleEffect(isScaledToFit ? 1.0 : 0.8) // Optional: add zoom effect during transition
                                .scaledToFill()
                                .transformEffect(isScaledToFit ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)) // Smooth transition helper
                                .clipped()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .animation(.easeInOut(duration: 0.3), value: isScaledToFit) // Smooth toggle animation
                                .clipped()
                                .onTapGesture(count: 1) {
                                    if !AppConstants.isiPad {
                                        isScaledToFit.toggle()
                                    }
                                }
                        } placeholder: {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tag(index)
                        .ignoresSafeArea()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(AppConstants.spaceblack)
                .overlay(alignment: .top) {
                    // Your existing X button overlay
                    closeButton(geo: geo)
                }
                .overlay(alignment: .bottom) {
                    // Your existing description overlay
                    descriptionOverlay(geo: geo)
                }
            }
            .ignoresSafeArea()
            //.environment(\.dismiss, DismissAction { showFullScreen = false })
        }
        
        @ViewBuilder
        private func closeButton(geo: GeometryProxy) -> some View {
            // Your existing close button code here
            Button {
                showFullScreen = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: AppConstants.isiPad ? 64 : 42, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: AppConstants.isiPad ? 66 : 44, height: AppConstants.isiPad ? 66 : 44)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 0)
            }
            .position(
                x: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.width / 1.45 :geo.size.width / 1.1) : (geo.size.width > geo.size.height ? geo.size.width / 1.75 : geo.size.width / 1.2),
                y: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.height / 10 : geo.size.height / 10) : geo.size.height / 10
            )
        }
        
        @ViewBuilder
        private func descriptionOverlay(geo: GeometryProxy) -> some View {
            // Your existing description overlay code here
            VStack {
                HStack {
                    Image("InstagramIcon")
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text("Description")
                        .font(AppConstants.mediumRoundedFont)
                }
                .foregroundStyle(.white)
                .padding(8)
                .background(Color.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .position(
                x: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.width / 1.5 : geo.size.width / 1.1) : (geo.size.width > geo.size.height ? geo.size.width / 1.9 : geo.size.width / 1.4),
                y: AppConstants.isiPad ? (geo.size.width > geo.size.height ? geo.size.height / 1.05 : geo.size.height / 1.05) : geo.size.height / 1.05
            )
        }
    }
    
    @ViewBuilder
    fileprivate func imageCell2(for url: URL, at index: Int, urls: [URL]) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
                .onTapGesture {
                    guard !showFullScreen else { return }
                    showFullScreen = true
                    selectedURL = url
                    // Set these new state variables
                    currentFullScreenIndex = index
                    fullScreenURLs = urls
                }
        } placeholder: {
            ProgressView()
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenImageView2(
                showFullScreen: $showFullScreen,
                selectedURL: $selectedURL,
                currentIndex: $currentFullScreenIndex,
                urls: $fullScreenURLs
            )
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white, lineWidth: 4))
        .shadow(radius: 3)
    }
    
    //TEST
    
    
    
    @ViewBuilder
    fileprivate func retrieveWeeklyHistoryList() -> some View {
        ForEach(sortedList, id: \.key) { (key, urls) in
            
            Text(key) // the dictionary key
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 0)
                .padding(.leading, 15)
                .foregroundStyle(.white)
            //ScrollViewReader { proxy in
                //ZStack{
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        LazyHGrid(rows: [GridItem(.fixed(80))]) {
                            
                            ForEach(urls, id: \.self) { item in
                                imageCell(for: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)

                //}// ZStack
            //} //ScrollViewReader
        }
    }
    
    @ViewBuilder
    fileprivate func retrieveYearlyHistoryList() -> some View {
        //ScrollView {
            LazyVStack(alignment: .leading, spacing: 10){
                ForEach(Array(sortedList), id: \.key) { (key, urls) in
                    
                    Text(key) // the dictionary key
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 0)
                        .padding(.leading, 15)
                        .foregroundStyle(.white)
                    
                    ForEach(Array(stride(from: 0, to: urls.count, by: 3).map{ i in
                        Array(urls[i..<Swift.min(i + 3, urls.count)])
                    }), id: \.first!) { group in
                        LazyHGrid(rows: [GridItem(.fixed(80))], spacing: 10) {
                            ForEach(group, id: \.self) { url in
                                imageCell(for: url)
                            }
                        }.padding(.horizontal)
                    }
                }
            }
        //}
    }
    
    @ViewBuilder
    fileprivate func imageCell(for url: URL) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
                .onTapGesture {
                    guard !showFullScreen else { return }
                    showFullScreen = true
                    selectedURL = url
                }
        } placeholder: {
            ProgressView()
        }
        .fullScreenCover(isPresented: $showFullScreen) {
                FullScreenImageView(showFullScreen: $showFullScreen, selectedURL: $selectedURL)
            
            
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white, lineWidth: 4))
        .shadow(radius: 3)
    }
    
    
}

#Preview {
    //@Previewable @State var firebaseServiceModel = FirebaseService()
    @Previewable @State var appServices = AppServices()
    @Previewable @State var isWeeklyList: Bool = true
    HistoryView(isWeeklyList: $isWeeklyList).environment(appServices)            .background(AppConstants.spaceblack.edgesIgnoringSafeArea(.all))
}
