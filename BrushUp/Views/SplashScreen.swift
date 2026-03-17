//
//  SplashScreen.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/15/26.
//
import SwiftUI
struct SplashScreen: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.splashBackground)
            
            Image("Mascot")
        }
        .ignoresSafeArea()
    }
}

struct CustomSplashTransaction: Transition {
    var isRoot: Bool
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .offset(y: phase.isIdentity ? 0 : isRoot ? screenSize.height : -screenSize.height)
    }
    
    var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        
        return .zero
    }
}
