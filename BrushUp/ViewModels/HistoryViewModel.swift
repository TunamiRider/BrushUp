//
//  HistoryViewModel.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/19/26.
//
import Foundation
@MainActor
@Observable public final class HistoryViewModel {
    private let firebaseService: FirebaseService
     var historyDataList: [HistoryRecord] = []
    
    private var isLaoding = false
    private var fetchedHistoryDataMap: [String: [URL]] = [:] // Dictionary(HashMap)
    private var sortedList: [(key: String, value: [URL])] = [] // Array of Tuple
    private var weekdayActivityMap : [String:Int] = [:]
    
    // Today's count (same calendar day)
    var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return historyDataList.filter {
            Calendar.current.isDate($0.addDt, inSameDayAs: today)
        }.count
    }

    // This week's count (last 7 days)
    var weekCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return historyDataList.filter { $0.addDt >= weekAgo }.count
        
//        let today = Date()
//        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: today)?.start!
//        return historyDataList.filter { $0.addDt >= weekStart }.count
    }

    // This month's count (same calendar month)
    var monthCount: Int {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        //let monthStart = Calendar.current.date(from: components)!
        return historyDataList.filter {
            Calendar.current.component(.year, from: $0.addDt) == components.year &&
            Calendar.current.component(.month, from: $0.addDt) == components.month
        }.count
    }
    
    init(firebaseService: FirebaseService){
        self.firebaseService = firebaseService
    }
    
    func getDisplayHistoryList() -> [(key: String, value: [URL])] {
        return sortedList
    }
    func getweekdayActivityMap() -> [String:Int] {
        return weekdayActivityMap
    }
    
    func countActivity(frequency: Frequency) -> Int {
        switch frequency {
        case .day:
            return todayCount
        case .week:
            return weekCount
        case .month:
            return monthCount
        default:
            return historyDataList.count
        }
    }
    
    
    func loadHistory() async {
        isLaoding = true
        
        // always set to false when the function exits
        defer { isLaoding = false }
        
        do {
            historyDataList = try await firebaseService.fetchHistoryRecord()
        }catch {
            print("Failed to load history: \(error)")
            historyDataList = []
        }
        
        retrieveHistoryList()
        getDailyActivityHistoryList()
        
        //readWeekdayActivityMap()
    }
    
    private func readWeekdayActivityMap(){
        let calendar = Calendar(identifier: .iso8601)
        let today = Date()
        weekdayActivityMap = Dictionary(uniqueKeysWithValues: WeekdayAbbreviation.allCases.map{ ($0.rawValue, 0) })
        
        // Get the start date of the current week
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { fatalError() }
        // Calculate the end of the week by adding 6 days to start
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        if( !self.historyDataList.isEmpty ){
            // Filter the array to include only items within current week
            let currentWeekData = self.historyDataList.filter { item in
                //let weekday = calendar.component(.weekday, from: item.addDt)
                
                return item.addDt >= startOfWeek && item.addDt <= endOfWeek
            }
            
            for data in currentWeekData {
                let day = data.addDt.formatted(.dateTime.weekday(.abbreviated));
                //check if the map contains the key.
                let hasKey = weekdayActivityMap.contains{ $0.key == day }
                
                if(hasKey){
                    weekdayActivityMap[day] = weekdayActivityMap[day]! + 1
                } else {
                    weekdayActivityMap[day]  = 1
                }
            }
        }
    }
    
    private func retrieveHistoryList(){
        
        let dataHistoryList = self.historyDataList
        
        for data in dataHistoryList {
            let dateKey = data.addDt.formatted(.dateTime.month(.wide).day().year())
            // print(dateKey)
            if var urls = fetchedHistoryDataMap[dateKey] {
                let newUrl = URL(string: data.url) ?? AppConstants.imageURL
                urls.append(newUrl)
                fetchedHistoryDataMap[dateKey] = urls  // Assign mutated array back
            } else {
                let newUrl = URL(string: data.url) ?? AppConstants.imageURL
                
                fetchedHistoryDataMap[dateKey] = [newUrl]  // Create new array for key
            }
        }
    }
    func getDailyActivityHistoryList() {
        sortedList = Array(fetchedHistoryDataMap).sorted{ entry1, entry2 in
            let date1 = CalenderUtils.longMonthDayYearFormatter.date(from: entry1.key) ?? Date.distantPast
                 let date2 = CalenderUtils.longMonthDayYearFormatter.date(from: entry2.key) ?? Date.distantPast
                 return date1 > date2
             }
    }
    func getMonthlyActivityHistoryList() {
        var monthDict: [String: [URL]] = [:]
        for (dateString, urls) in fetchedHistoryDataMap {
            guard let date = CalenderUtils.longMonthDayYearFormatter.date(from: dateString) else { continue }
            
            let monthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: date)-1]
            
            monthDict[monthName, default: []].append(contentsOf: urls)
        }
        sortedList = Array(monthDict);
    }
}
