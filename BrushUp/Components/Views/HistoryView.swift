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
    @State private var isWeeklyList: Bool = true
    @State private var sortedList: [(key: String, value: [URL])] = [] // Array of Tuple
    
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
            AppConstants.spaceblack
                .ignoresSafeArea()
            
            VStack(spacing: 0){
                VStack {
                    HStack(spacing: 20) {
                        
                        Text(isWeeklyList ? "Daily History" : "Monthly History")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                        
                        Group {
                            isWeeklyList ? Image(systemName: "calendar.circle")
                                .foregroundStyle(isWeeklyList ? .white : .gray)
                                .onTapGesture {
                                    showFullScreen = false
                                    isWeeklyList = false
                                    getMonthlyActivityHistryList()
                                }
                            
                            :Image(systemName: "calendar")
                                .foregroundStyle(isWeeklyList ? .gray: .white)
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
                    LazyVGrid(columns: rows, spacing: 10) {
                        if isWeeklyList {
                            retrieveWeeklyHistoryList()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        } else {
                            retrieveYearlyHistoryList()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: isWeeklyList)
                .task {
                    do {
                        showFullScreen = false
                        historyViewModel = HistoryViewModel(firebaseService: services.firebaseService)
                        await historyViewModel?.loadHistory()
                        getDailyActivityHistoryList()
                    } catch {
                        print("Failed to load data: \(error)")
                    }
                }
            }
        }
        //.background(AppConstants.spaceblack.edgesIgnoringSafeArea(.all))
        
        // VStack Outest
    }
    
    private struct FullScreenImageView: View {
        @Binding var showFullScreen: Bool
        @Binding var selectedURL: URL?
        //let url: URL
        //@Environment(\.dismiss) private var dismiss
        
        var body: some View {
            ZStack(alignment: .topLeading){
                //Color.black.ignoresSafeArea()
                AsyncImage(url: selectedURL!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .gesture(
                            TapGesture().onEnded { showFullScreen = false } // Dismiss on tap
                        )
                } placeholder: {
                    ProgressView().tint(.white)
                }
                Button {
                    showFullScreen = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate func retrieveWeeklyHistoryList() -> some View {
        ForEach(sortedList, id: \.key) { (key, urls) in
            
            Text(key) // the dictionary key
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 0)
                .padding(.leading, 15)
                .foregroundStyle(.white)
            ScrollViewReader { proxy in
                ZStack{
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        LazyHGrid(rows: [GridItem(.fixed(80))]) {
                            
                            ForEach(urls, id: \.self) { item in
                                imageCell(for: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                }// ZStack
            } //ScrollViewReader
        }
    }
    
    @ViewBuilder
    fileprivate func retrieveYearlyHistoryList() -> some View {
        ScrollView {
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
        }
    }
    
    @ViewBuilder
    fileprivate func imageCell(for url: URL) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
                .onTapGesture {
                    guard !showFullScreen else { return }
                    // showFullScreen = true
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

//#Preview {
//    //@Previewable @State var firebaseServiceModel = FirebaseService()
//    @Previewable @State var appServices = AppServices()
//    HistoryView().environment(appServices)            //.background(AppConstants.spaceblack.edgesIgnoringSafeArea(.all))
//}
