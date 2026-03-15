//
//  CalendarUtils.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/20/26.
//

import SwiftUI
enum WeekdayAbbreviation: String, CaseIterable, CustomStringConvertible {
    case sun = "Sun"
    case mon = "Mon"
    case tue = "Tue"
    case wed = "Wed"
    case thu = "Thu"
    case fri = "Fri"
    case sat = "Sat"
    
    // Human-readable description
    var description: String { rawValue }
}

enum CalenderUtils {
    
    static func daysOfCurrentWeek() -> [Date] {
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
    
    static func color(for day: WeekdayAbbreviation) -> [String : Color] {
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
}
