//
//  ShineCometLine.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/12/26.
//
import SwiftUI
struct ShineCometLine: View {
    let lineWidth: CGFloat?
    
    init(lineWidth: CGFloat? = nil) {
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            let actualWidth = lineWidth ?? geometry.size.width
            
            ShineCometLineContent(lineWidth: actualWidth)
        }
        .frame(height: 1)
    }
}

private struct ShineCometLineContent: View {
    let lineWidth: CGFloat
    @State private var cometOffset: CGFloat = -40
    @State private var shineOffset: CGFloat = -50
    @State private var isVisible: Bool = true
    var body: some View {
        ZStack {
            // Base dashed line
            Rectangle()
                .stroke(Color.white.opacity(0.2),
                        style: StrokeStyle(lineWidth: 1, dash: [1, 1]))
                .frame(width: lineWidth, height: 1)
            
            // Shine + Comet (disappear after animation)
            Group {
                // 1. Moving shine sweep
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.6), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: lineWidth, height: 1)
                .mask(
                    Rectangle()
                        .offset(x: shineOffset)
                        .frame(width: 40, height: 1)
                )
                
                // 2. Comet circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color.yellow.opacity(0.4),
                                Color.orange.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 6
                        )
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .blur(radius: 4)
                            .frame(width: 10, height: 10)
                    )
                    .frame(width: 7, height: 7)
                    .offset(x: cometOffset)
            }
            .opacity(isVisible ? 1 : 0)  // Single opacity control
            
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                cometOffset = lineWidth / 2 - 3.5
                shineOffset = lineWidth / 2 - 20
            }
            // Hide after animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isVisible = false
                }
            }
        }
    }
}
