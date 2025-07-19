//
//  HistoryView.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 10/19/25.
//
import SwiftUI

struct HistoryView: View {
    private let firebaseService : FirebaseService = FirebaseService()
    
    let rows = [GridItem(.flexible())]  // One column for LazyVGrid
    let imageURL = URL(string: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4")!
    
    @State var horizontalList: [String: [URL]] = [:]
    @State private var showFullScreen = false
    @State private var selectedURL: URL? = nil
    
    private func retrieveHorizontalHistoryList(){
        // var horizontalList: [String: [String]] = [:]
        // print(firebaseService.historyDataList.count)
        for data in firebaseService.historyDataList {
            // print("\(data.addDt) +A \(data.url)")
            let dateKey = data.addDt.formatted(.dateTime.month(.wide).day().year())
            // print(dateKey)
            if var urls = horizontalList[dateKey] {
                let newUrl = URL(string: data.url) ?? imageURL
                urls.append(newUrl)
                horizontalList[dateKey] = urls  // Assign mutated array back
            } else {
                let newUrl = URL(string: data.url) ?? imageURL
                
                horizontalList[dateKey] = [newUrl]  // Create new array for key
            }
//            if(horizontalList.keys.contains(date2)){
//                
//                // horizontalList[date2]?.append(data.url)
//            } else {
//                horizontalList[date2] = [data.url]
//            }
        }
        
        let calendar = Calendar(identifier: .iso8601)  // Week starts on Monday
        let today = Date()
        if let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start {
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            print("Start of week: \(formatter.string(from: startOfWeek))")
            print("End of week: \(formatter.string(from: endOfWeek))")
        }

        // 確認用プリント
//        for (key, value) in horizontalList {
//            print("\(key): \(value)")
//        }
    }

    var body: some View {

        ScrollView {// Vertical scroll for the whole grid
                HStack(spacing: 20) {
                    Text("Weekly History").frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "calendar") // weekly
                    Image(systemName: "calendar.circle") // monthly
                    // Image(systemName: "calendar.badge.clock") // yearly
                }
                .imageScale(.large)
                .foregroundStyle(.gray)
                .padding()

            
            LazyVGrid(columns: rows, spacing: 10) {
                ForEach(Array(horizontalList).sorted { $0.key < $1.key }, id: \.key) { (key, urls) in

                        Text(key) // the dictionary key
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 0)
                                .foregroundStyle(.white)
                    ScrollViewReader { proxy in
                        ZStack{
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            LazyHGrid(rows: [GridItem(.fixed(80))]) {
                                
                                // Spacer(minLength: 2)
                                ForEach(urls, id: \.self) { item in
                                    
                                    AsyncImage(url: item) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .onTapGesture {
                                                showFullScreen = true     // Trigger full-screen view
                                                selectedURL = item
                                            }
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .fullScreenCover(isPresented: $showFullScreen) {
                                        FullScreenImageView(showFullScreen: $showFullScreen, selectedURL: $selectedURL)
                                        // FullScreenImageView(showFullScreen: $showFullScreen)
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 5)
                                    
                                    .background(Color.secondary.opacity(0.2))
                                }

                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 120)
                           
                        
//                            HStack {
//                                
//                                
//                            Button("Scroll Left") {
//                                if let first = urls.first {
//                                    withAnimation {
//                                        proxy.scrollTo(first, anchor: .leading)
//                                    }
//                                }
//                            }
//                            .frame(width: 10, height: 100)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            //.padding(.trailing, 1)
//                                
//                            Spacer()
//                                
//                                
//                            Button("Scroll Right") {
//                                if let last = urls.last {
//                                    withAnimation {
//                                        proxy.scrollTo(last, anchor: .trailing)
//                                    }
//                                }
//                            }
//                            .frame(width: 10, height: 100)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            //.padding(.leading, 1)
//                            }
                            //.frame(height: 100)
                        }// ZStack

                    } //ScrollViewReader

                }
            }.padding()

        }
        .background(Color.black.opacity(0.8).edgesIgnoringSafeArea(.all))
        .task {
            do {
                try await firebaseService.readHistoryData()
                
                retrieveHorizontalHistoryList()
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }
    
    struct FullScreenImageView: View {
        @Binding var showFullScreen: Bool
        @Binding var selectedURL: URL?
        //let url: URL
        //@Environment(\.dismiss) private var dismiss
        
        var body: some View {
            
            ZStack(alignment: .topLeading){
                Color.black.ignoresSafeArea()
                //"https://picsum.photos/1000"
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
    
}

#Preview {
    
    HistoryView()
}
