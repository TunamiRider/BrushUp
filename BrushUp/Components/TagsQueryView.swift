//
//  TagsQueryView.swift
//  PaintMe
//
//  Created by Yuki Suzuki on 7/9/25.
//
import SwiftUI
import SwiftData

struct TagsQueryView: View {
    let modelContainer: ModelContainer
    @State var isCreatingDatabase = true
    @State var isFetchingUsers = false
    @State private var tags: [TagDTO] = []
    var viewModel: TagsQueryViewModel
    @State var tagText = ""
    let screenSize: CGRect = UIScreen.main.bounds
    @State var rows: [[TagDTO]] = []
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        viewModel = TagsQueryViewModel(modelContainer: modelContainer)
    }
    
    var body: some View {
        VStack {
            if isCreatingDatabase {
                ProgressView("Creating database")
                //let _ = print("\(tags.count)")
            } else {
                HStack{
                    HStack {
                        Image(systemName: "tag")
                        TextField("Enter Tag...", text: $tagText)
                    }.modifier(customViewModifier(roundedCornes: 32, startColor: .orange, endColor: .purple, textColor: .white))
                    .onSubmit {
                        Task{
                            try await viewModel.saveTag(tagText)
                            tags = try await viewModel.backgroundFetch()
                            getTagGrids()
                            tagText = ""
                        }
                    }
                    
                    HStack{
                        
                        Button(action: {
                            //clear tag list
                            tags = []
                            //delete all tags
                        }) {

                            Image(systemName: "multiply.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(LinearGradient(
                                            colors: [.yellow, .red],
                                            startPoint: .top,
                                            endPoint: .bottom).opacity(0.9))
                                        
                                )
                                
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Circle())
                    }
                }.padding()
                
                if tags.count == 0 {
                    ContentUnavailableView("No Tags Added", systemImage: "person.crop.circle.badge.exclamationmark")
                } else {
                    ForEach(rows, id:\.self){ rows in
                        HStack(spacing: 6){
                            ForEach(rows){ row in
                                Text(row.name)
                                    .font(.system(size: 16))
                                    .padding(.leading, 14)
                                    .padding(.trailing, 30)
                                    .padding(.vertical, 8)
                                    .background(
                                        ZStack(alignment: .trailing){
                                            RoundedRectangle(cornerRadius: 64)
                                                .fill(LinearGradient(
                                                    colors: [.yellow, .red],
                                                    startPoint: .top,
                                                    endPoint: .bottom).opacity(0.6))
                                            Button{
                                                //let _ = print(row.id)
                                                Task{
                                                    try await viewModel.deleteTag(row.id)
                                                    tags = try await viewModel.backgroundFetch()
                                                    getTagGrids()
                                                }
                                                
                                            } label:{
                                                Image(systemName: "xmark")
                                                    .frame(width: 12, height: 12)
                                                    .padding(.trailing, 8)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    )
                            }//.border(Color.black)
                        }//.border(Color.black)
                    }//.border(Color.gray)
                    
                }

                
            }
            
//            AsyncImage(url:
//                        URL(string: "https://images.unsplash.com/photo-1491328480217-db46cf0876c5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjQ3MDh8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTMxOTIyMjZ8&ixlib=rb-4.1.0&q=80&w=1080")!)
//                .scaleEffect(currentZoom + totalZoom)
//                .gesture(
//                    MagnifyGesture()
//                        .onChanged { value in
//                            currentZoom = value.magnification - 1
//                        }
//                        .onEnded { value in
//                            totalZoom += currentZoom
//                            currentZoom = 0
//                        }
//                )
//                .accessibilityZoomAction { action in
//                    if action.direction == .zoomIn {
//                        totalZoom += 1
//                    } else {
//                        totalZoom -= 1
//                    }
//                }
            
        }
        .task() {
            await viewModel.createDatabase()
            tags = mainThreadFetch()
            getTagGrids()
            
            let _ = print("create database: \(tags.count)")
            isCreatingDatabase = false
        }
        //.border(.gray, width: 3)
    }
    
    private func mainThreadFetch() -> [TagDTO] {
        let context = ModelContext(modelContainer)
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
    
    private func getTagGrids(){
        var rows: [[TagDTO]] = []
        var currentRow: [TagDTO] = []
        
        var totalWidth: CGFloat = 0
        let screenWidth: CGFloat = screenSize.width
        let tagSpacing: CGFloat = 14 /*Leading Padding*/ + 30 /*Trailing Padding*/ + 6 + 6 /*Leading & Trailing 6, 6 Spacing */
        
        if !tags.isEmpty {
            
            tags.forEach{  tag in
                totalWidth += (tag.size + tagSpacing)
                
                if(totalWidth > screenWidth){
                    totalWidth = (tag.size + tagSpacing)
                    rows.append(currentRow)
                    currentRow.removeAll()
                    currentRow.append(tag)
                } else {
                    currentRow.append(tag)
                }
            }
            
            if !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow.removeAll()
            }
            
            self.rows = rows
        } else {
            self.rows = []
        }
        
    }
    
}

struct customViewModifier: ViewModifier {
    var roundedCornes: CGFloat
    var startColor: Color
    var endColor: Color
    var textColor: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(roundedCornes)
            .padding(3)
            .foregroundColor(textColor)
            
            .overlay(RoundedRectangle(cornerRadius: roundedCornes)
                        .stroke(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
            .font(.custom("Open Sans", size: 18))

            .shadow(radius: 10)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Tag.self, configurations: config)
        return TagsQueryView(modelContainer: container)
    } catch {
        fatalError("Failed to create container")
    }
    
}
