//
//  AppConstants.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//

import Foundation
import SwiftUI
struct AppConstants {
    static let imageURL = URL(string: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4")!
    
    
    static let perlwhilte = Color(.sRGB, red: 1.0, green: 0.98, blue: 0.94, opacity: 0.8)

    
    static let spaceblack = Color.black.opacity(0.8)
    static let lightgray = Color(.sRGB, red: 0.45, green: 0.4, blue: 0.37, opacity: 1.0)
    static let dustypink = Color(.sRGB, red: 0.72, green: 0.36, blue: 0.50)
    
    
    static let UIPerlWhilte = UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 0.8)
    static let UILightGray = UIColor(red: 0.45, green: 0.4, blue: 0.37, alpha: 1.0)
    static let UISpaceGray = UIColor.black.withAlphaComponent(0.8)
    static let UISpaceBlack = UIColor.black.withAlphaComponent(0.8)
    
    
    static let minutesList = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    static let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    static let maximumDrawingGoal = 10
    static var mediumRoundedFont: Font {
        .system(size: 20, weight: .medium, design: .rounded)
    }
    static var boldRoundedFont: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    static var smallRoundedFont: Font {
        .system(size: 16, weight: .medium, design: .rounded)
    }
    
    @MainActor
    static let isiOS: Bool = {
        #if os(iOS)
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.windows.first }
            .first?.windowScene?.traitCollection.horizontalSizeClass == .regular
        #else
        return false
        #endif
    }()
    
    @MainActor
    static let isiPad: Bool = {
            UIDevice.current.userInterfaceIdiom == .pad
    }()
    
    @MainActor
    static let deviceScreenHeightScalingForBarChart: CGFloat = {
        isiPad ? UIScreen.main.bounds.size.height / 6 : UIScreen.main.bounds.size.height / 8
    }()
    
}

enum Frequency: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}

//enum Tab: String, CaseIterable {
//    case home, history, settings
//    
//    var title: String { rawValue.capitalized }
//    var image: String {
//        switch self {
//        case .home: return "house"
//        case .history: return "clock.arrow.circlepath"
//        case .settings: return "gear"
//        }
//    }
//}


enum Tab: Int, CaseIterable, Identifiable {
    case home = 0
    case history = 1
    case settings = 2
    
    var image: String {
        switch self {
        case .home: return "house"
        case .history: return "clock.fill"
        case .settings: return "gear"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
    
    var id: Int { rawValue }
}
