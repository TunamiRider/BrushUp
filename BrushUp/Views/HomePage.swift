//
//  HomePage.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 7/28/25.
//
import SwiftUI

struct HomePageMain: View {
    
    @State private var goMainView = false
    @State private var isResume = false
    
    @State private var minutes: Int = 1
    @State var isMonochrome: Bool = false
    
    //private var 
    
    init(){
//        let appearance = UITabBarAppearance()
//        appearance.backgroundColor = UIColor.systemGray6
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.8)// .systemGray4.withAlphaComponent(0.4)
//        if #available(iOS 15.0, *) {
//            UITabBar.appearance().scrollEdgeAppearance = appearance
//        }
        
    }
    
    var body: some View {
        
        if(goMainView){
            ContentView(goMainView: $goMainView, isResume: $isResume, minutes: $minutes, isMonochrone: $isMonochrome)
        }else {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomePage(goMainView: $goMainView, isResume: $isResume)
                }

                TabSection("Messages Related") {
                    Tab("History", systemImage: "clock.fill") {
                        HistoryView()
                    }
                    Tab("Archive", systemImage: "archivebox") {
                        SnowFlakeTest()
                    }
                }

                Tab("Settings", systemImage: "gear") {
                    Settings(minutes: $minutes, isMonochrone: $isMonochrome)
                }
            }
    //        .tabViewStyle(.sidebarAdaptable)
    //        .toolbarBackground(.visible, for: .tabBar).ignoresSafeArea(.all)
            .tint(.white)
        }

    }
}

struct HomePage: View {
    private let firebaseService : FirebaseService = FirebaseService()
    @State private var rotateX: Double = 20
    @State private var rotateY: Double = 20
    @Binding var goMainView: Bool
    @Binding var isResume: Bool
    
    // Precompute the days of the current week once
    let weekDays: [Date] = daysOfCurrentWeek()
    @State var weekdayActivityMap : [String:Int] = [:]
    
    enum WeekdayAbbreviation: String, CaseIterable, CustomStringConvertible {
        case sun = "Sun"
        case mon = "Mon"
        case tue = "Tue"
        case wed = "Wed"
        case thu = "Thu"
        case fri = "Fri"
        case sat = "Sat"
        
        // Human-readable description
        var description: String {
            rawValue
        }
    }
    
    // Formatter for weekday name
    let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // Full weekday name, e.g. Monday
        return formatter
    }()
    
    // Formatter for date (e.g. "7/31")
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"   // Month/Day format
        return formatter
    }()
    
    func readWeeklyHistoryData(){
        let calendar = Calendar(identifier: .iso8601)
        let today = Date()
        weekdayActivityMap = [:]
        
        // var weekdayActivityMap : [String:Int] = [:]
        // Get the start date of the current week
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { fatalError() }
        // Calculate the end of the week by adding 6 days to start
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        // Example data array
        // let dataArray: [DataItem] = [...]  // Your data here
        if( !firebaseService.historyDataList.isEmpty ){
            // Filter the array to include only items within current week
            let currentWeekData = firebaseService.historyDataList.filter { item in
                let weekday = calendar.component(.weekday, from: item.addDt)
                
                return item.addDt >= startOfWeek && item.addDt <= endOfWeek
            }
            
            for data in currentWeekData {
                 //print(data.addDt.formatted(.dateTime.weekday(.abbreviated)) + dateFormatter.string(from: data.addDt))
                
                let day = data.addDt.formatted(.dateTime.weekday(.abbreviated));
                //check if the map contains the key.
                let hasKey = weekdayActivityMap.contains{ $0.key == day }
                
                if(hasKey){
                    weekdayActivityMap[day] = weekdayActivityMap[day]! + 1
                } else {
                    weekdayActivityMap[day]  = 1
                }
            }
            
            for data in weekdayActivityMap {
                //print("\(data.key): \(weekdayActivityMap[data.key]!)")
            }
            // let sortedDic = weekdayActivityMap.sorted{ $0.key < $1.key }
            
        }
        
        
    }
    
    func color(for day: WeekdayAbbreviation) -> [String : Color] {
        switch day {
        case .sun: return ["base": .orange, "prime": .red, "secondary": .yellow]
        case .mon: return ["base": .gray, "prime": .blue, "secondary": .teal]
        case .tue: return ["base": .green, "prime": .mint, "secondary": .cyan]
        case .wed: return ["base": .indigo, "prime": .purple, "secondary": .pink]
        case .thu: return ["base": .yellow, "prime": .orange, "secondary": .brown]
        case .fri: return ["base": .mint, "prime": .teal, "secondary": .blue]
        case .sat: return ["base": .pink, "prime": .red, "secondary": .purple]
        }
    }

    @ViewBuilder
    func makeGridRow(_ day: WeekdayAbbreviation) -> some View {
        let refCont: Int = weekdayActivityMap[day.description] ?? 0
        let activityCont : Int = (refCont >= 10) ? 10 : refCont
        let fillCont: Int = (activityCont >= 10) ? 0 : (10 - activityCont)
        let colors = self.color(for: day)
        GridRow {
            Text(day.description).font(.system(size: 12, weight: .medium))
            ForEach(0..<activityCont, id: \.self) { index in
                makeRectangle(base: colors["base"]!, primary: colors["prime"]!, secondary: colors["secondary"]!)
            }
            ForEach(0..<fillCont, id: \.self){ index in
                makeRectangle(base: Color.white, primary: Color.white, secondary: Color.white)
            }
            if(activityCont>=10){
                Image(systemName: "plus")
                    .font(.footnote)
                    .foregroundColor(colors["prime"]!)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                List{
                    Section(header:
                    Text("Weekly Activity").foregroundStyle(.white)
                        .font(.subheadline).padding(.leading)
                    ) {
                        Grid {
                            makeGridRow(.sun)
                            makeGridRow(.mon)
                            makeGridRow(.tue)
                            makeGridRow(.wed)
                            makeGridRow(.thu)
                            makeGridRow(.fri)
                            makeGridRow(.sat)

                        }
                    }
                    .padding(.horizontal)
                    .listRowBackground(Color.white.opacity(0.9))
                    
                    
                    HStack(spacing: 8) {
                        ForEach(weekDays, id: \.self) { day in
                            VStack {
                                Text(dayNameFormatter.string(from: day))
                                    .font(.system(size: 8, weight: .medium, design: .default))
                                    
                                    //.bold()
                                Text(dateFormatter.string(from: day))
                                    .font(.system(size: 8, weight: .medium, design: .default))
                                    
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    //                    .background {
                    //                        Color.teal.opacity(0.3)
                    //                            .ignoresSafeArea()
                    //                    }
                }
                .scrollContentBackground(.hidden)
                
                //.border(.mint, width: 3)
                

                
                /* Rounded Button */
                Button(action: {
                    goMainView = true
                }) {
                    Text(isResume ? "Resume" : "Start")
                        .font(.system(size: 18))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 100)
                    
                        .foregroundColor(.white)
                        .background(.orange)
                        .cornerRadius(100)
                }
                .navigationDestination(isPresented: $goMainView) {
                    
                    ContentView4()
                }
                Spacer()
            }
            .background(Color.black.opacity(0.8).edgesIgnoringSafeArea(.top))
            //.border(Color.red, width: 3)
        }
        .task {
            do {
                try await firebaseService.readHistoryData()
                readWeeklyHistoryData()
                //retrieveHorizontalHistoryList()
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }
}

func daysOfCurrentWeek() -> [Date] {
    let calendar = Calendar.current
    let today = Date()
    
    // Get the weekday component (1 = Sunday, 2 = Monday, ..., depends on locale)
    let weekday = calendar.component(.weekday, from: today)
    
    // Calculate the start of the week (e.g., previous Sunday or your calendar's first weekday)
    // Calendar's firstWeekday gives the first day of week (e.g., 1 for Sunday)
    let firstWeekday = calendar.firstWeekday
    
    // Calculate the difference in days to get back to the start of the week
    let daysToSubtract = (weekday - firstWeekday + 7) % 7
    
    // Get the start of the week date (midnight)
    guard let weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: today)) else {
        return []
    }
    
    // Collect the 7 days of the week
    return (0..<7).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
    }
}

func makeRectangle(base: Color, primary: Color, secondary: Color) -> some View {
    Rectangle()
        .fill(
            LinearGradient(
                colors: [base.opacity(0.5), primary, secondary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
        )
        .frame(width: 15, height: 15)
        .cornerRadius(3)
        .rotation3DEffect(.degrees(20), axis: (x: 0, y: 0, z: 0))
        .rotation3DEffect(.degrees(20), axis: (x: 0, y: 0, z: 0))
        .shadow(color: .black.opacity(0.3), radius: 16, x: 8, y: 12)
}

struct HorizontalGridView: View {
    let items = 0..<50 // Sample data

    let rows = [
        GridItem(.fixed(100)), // Fixed height row
        GridItem(.adaptive(minimum: 50)) // Adaptive height row
    ]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, spacing: 20) {
                ForEach(items, id: \.self) { item in
                    Text("Item \(item)")
                        .frame(width: 150, height: 80) // Adjust size as needed
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var dataModel = UnsplashImage()
    @Previewable @State var brushUpTimer = BrushUpTimer()
    HomePageMain().environment(dataModel).environment(brushUpTimer)
}
