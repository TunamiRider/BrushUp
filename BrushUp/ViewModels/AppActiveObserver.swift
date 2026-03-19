//
//  AppActiveObserver.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/18/26.
//

import UIKit
import Combine

@MainActor
@Observable
final class AppActiveObserver { //ObservableObject
    
    static let shared = AppActiveObserver()
    var isActive: Bool = true
    
    init(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIScene.willDeactivateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIScene.didActivateNotification,
            object: nil
        )
    }
    
    @objc private func willResignActive(){
        isActive = false
    }
    @objc private func didBecomeActive(){
        isActive = true
    }
    
}
