//
//  StringExtension.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//
import UIKit
extension String {
    func getSize() -> CGFloat{
        let font = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }
    var isValidMMddyyyy: Bool {
        count == 8 && allSatisfy({ $0.isNumber }) && mmddyyyyDate != nil
    }
    var mmddyyyyDate: Date? {
        guard !isEmpty, !trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMddyyyy"
        return DateFormatter.mmddyyyyFormatter.date(from: self)
    }

    func dateCountParts() -> (date: String, count: String) {
        let parts = components(separatedBy: ":").prefix(2)
        return (parts.first ?? "", String(parts.dropFirst().first?.prefix(1) ?? "0"))
    }
}
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Calendar {
    func currentWeekDays() -> [Date] {
        var mondayCalendar = self
        mondayCalendar.firstWeekday = 2
        let today = Date()
        
        // Get start of current week (Monday or Sunday based on locale)
        guard let weekStart = mondayCalendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }
        
        // Generate 7 days from week start
        return (0..<7).compactMap { offset in
            mondayCalendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
    //let aprilDate = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15))!
    // let decemberDate = Calendar.current.date(from: DateComponents(year: 2026, month: 12, day: 1))!
    //let novemberDate = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 1))!
    func isJanuaryToMarch(for date: Date = .now) -> Bool {
        isInMonths(1...3, for: date)
    }
    func isAprilToOctober(for date: Date = .now) -> Bool {
        isInMonths(4...10, for: date)
    }
    func isNovemberToDecember(for date: Date = .now) -> Bool {
        isInMonths(11...12, for: date)
    }
    
    private func isInMonths(_ range: ClosedRange<Int>, for date: Date) -> Bool {
        let month = self.component(.month, from: date)
        return range.contains(month)
    }
    
    
}

extension HistoryRecord {
    var dateOnly: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.year, .month, .day], from: addDt)
        
        return calendar.date(from: components)!
    }
}

extension DateFormatter {
    static var mmddyyyyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyyy"
        return formatter
    }
    // Formatter for weekday name
    static let dayNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // Full weekday name, e.g. Monday
        return formatter
    }()
    
    // Formatter for date (e.g. "7/31")
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"   // Month/Day format
        return formatter
    }()
    
    static let longMonthDayYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
}

extension Date {
    static var mmddyyyyString: String {
        return DateFormatter.mmddyyyyFormatter.string(from: Date())
    }

    static var yesterdayMMDDYYYYString: String {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        return DateFormatter.mmddyyyyFormatter.string(from: yesterday)
    }
    
}


