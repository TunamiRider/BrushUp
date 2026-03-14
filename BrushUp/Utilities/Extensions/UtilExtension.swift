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
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyyy"
        return formatter.date(from: self)
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
}

extension HistoryRecord {
    var dateOnly: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.year, .month, .day], from: addDt)
        
        return calendar.date(from: components)!
    }
}

extension Date {
    static var mmddyyyyString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyyy"
        return formatter.string(from: Date())
    }
}
