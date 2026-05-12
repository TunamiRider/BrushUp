//
//  MainEntry.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 5/6/26.
//
import SwiftUI
struct MainEntry: View {
    @Environment(StoreManager.self) var store
    
    var body: some View {
        Group {
            if store.isSubscribed {
                LoginWrapper()
            } else {
                SubscriptionPaywallView()
            }
        }
        .onChange(of: store.isSubscribed) { oldValue, newValue in
            print("Subscription changed: \(oldValue) -> \(newValue)")  // Debug
        }
    }
}
