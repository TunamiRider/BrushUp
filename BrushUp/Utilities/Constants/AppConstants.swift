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
    
    static let maximumDrawingGoal = 10
}

enum Frequency: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}
