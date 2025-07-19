//
//  SnowFlake.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 7/27/25.
//

import SwiftUI

struct SnowFlake: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY)) // Top center
        path.addLine(to: CGPoint(x: rect.maxX*0.75, y: rect.midY*0.8)) // Bottom left
        path.addLine(to: CGPoint(x: rect.maxX*0.95, y: rect.midY*1.1))
        path.addLine(to: CGPoint(x: rect.maxX*0.95, y: rect.midY*1.3))
        path.addLine(to: CGPoint(x: rect.maxX*0.75, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX*0.7, y: rect.midY*1.15))
        path.addLine(to: CGPoint(x: rect.maxX*0.95, y: rect.midY*1.5))
        path.addLine(to: CGPoint(x: rect.maxX*0.95, y: rect.midY*1.8))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY*1.8))
        
        

        //path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom right
        //path.addLine(to: CGPoint(x: rect.maxX*0.2, y: rect.maxY))
        //path.closeSubpath() // Connects to the starting point
        return path
    }
}
struct SnowFlake2: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Top center
        path.addLine(to: CGPoint(x: rect.midX*0.75, y: rect.midY*0.8)) // Bottom left
        path.addLine(to: CGPoint(x: rect.midX*0.95, y: rect.midY*1.1))
        path.addLine(to: CGPoint(x: rect.midX*0.95, y: rect.midY*1.3))
        path.addLine(to: CGPoint(x: rect.midX*0.7, y: rect.midY)) //
        path.addLine(to: CGPoint(x: rect.midX*0.7, y: rect.midY*1.15))
        path.addLine(to: CGPoint(x: rect.midX*0.95, y: rect.midY*1.5))
        path.addLine(to: CGPoint(x: rect.midX*0.95, y: rect.midY*1.8))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY*1.8))
        path.closeSubpath()

        
        path.move(to: CGPoint(x: rect.midX*1.005, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX*1.25, y: rect.midY*0.8))
        path.addLine(to: CGPoint(x: rect.midX*1.05, y: rect.midY*1.1))
        path.addLine(to: CGPoint(x: rect.midX*1.05, y: rect.midY*1.3))
        path.addLine(to: CGPoint(x: rect.midX*1.3, y: rect.midY)) //
        path.addLine(to: CGPoint(x: rect.midX*1.3, y: rect.midY*1.15))
        path.addLine(to: CGPoint(x: rect.midX*1.05, y: rect.midY*1.5))
        path.addLine(to: CGPoint(x: rect.midX*1.05, y: rect.midY*1.8))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY*1.8))
        path.closeSubpath() // Connects to the starting point
        return path
    }
}

struct MirroredShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Original shape example: a triangle pointing right
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        // Create a transform to mirror horizontally around center
        let centerX = rect.midX
        let transform = CGAffineTransform(translationX: centerX, y: 0)
            .scaledBy(x: -1, y: 1)                 // Mirror horizontally
            .translatedBy(x: -centerX, y: 0)
        
        // Apply mirror transform to original path
        let mirroredPath = path.applying(transform)
        return mirroredPath
        
    }
}

struct MyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Your shape drawing code here
        // Example: Right-pointing triangle
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let spacing = width * 0.05
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = width / 2 - spacing

        var path = Path()
        for i in 0..<6 {
            let angle = (CGFloat(i) * 60 - 30) * .pi / 180
            let pt = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}


struct SnowFlakeTest: View {
    var body: some View {
//        SnowFlake2()
//            .stroke(Color.blue, lineWidth: 2)
//            .fill(LinearGradient(
//                colors: [.blue, .white],
//                startPoint: .top,
//                endPoint: .bottom).opacity(0.9))
//            .frame(width: 200, height: 200) // Set a frame for the shape
//            .border(.red, width: 1)
        
        
//        Hexagon()
//            .stroke(Color.blue, lineWidth: 2)
//            .frame(width: 200, height: 200)
//            .border(.red, width: 1)
//        
//        
//        
//        MirroredShape()
//            .stroke(Color.blue, lineWidth: 2)
//            .frame(width: 200, height: 100)
//            .border(.red, width: 1)
        
        
        
//        HStack(spacing: 20) {
//            MyShape()
//                .fill(Color.blue)
//                .frame(width: 100, height: 100)
//
//            MyShape()
//                .fill(Color.red)
//                .frame(width: 100, height: 100)
//                .scaleEffect(x: -1, y: 1) // Horizontal mirror
//        }
//        .padding()
//        .border(.red, width: 1)
        
//        HStack(spacing: 0) {
//            SnowFlake()
//                .fill(LinearGradient(
//                    colors: [.blue, .white],
//                    startPoint: .top,
//                    endPoint: .bottom).opacity(0.9))
//                .frame(width: 100, height: 100)
//                //.border(.red, width: 1)
//
//            SnowFlake()
//                .fill(LinearGradient(
//                    colors: [.blue, .white],
//                    startPoint: .top,
//                    endPoint: .bottom).opacity(0.9))
//                .frame(width: 100, height: 100)
//                .scaleEffect(x: -1, y: 1) // Horizontal mirror
//                //.border(.red, width: 1)
//        }
//        .padding(0)
//        //.padding()
//        .border(.red, width: 1)
        
        ZStack{
            HStack(spacing: 0) {
                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .white],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    //.border(.red, width: 1)

                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .mint],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: -1, y: 1) // Horizontal mirror
                    //.border(.red, width: 1)
            }
            .padding(0)
            .border(.red, width: 1)
        
            HStack(spacing: 0) {
                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .mint],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    //.border(.red, width: 1)

                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .white],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: -1, y: 1) // Horizontal mirror
                    //.border(.red, width: 1)
            }
            .padding(0)
            .offset(x: 60, y: -35)
            .rotationEffect(.degrees(60))
            .border(.red, width: 1)
            
            HStack(spacing: 0) {
                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .mint],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    //.border(.red, width: 1)

                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .white],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: -1, y: 1) // Horizontal mirror
                    //.border(.red, width: 1)
            }
            .padding(0)
            .offset(x: 60, y: -105)
            .rotationEffect(.degrees(120))
            .border(.red, width: 1)
            
            HStack(spacing: 0) {
                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .white],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    //.border(.red, width: 1)

                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .mint],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: -1, y: 1) // Horizontal mirror
                    //.border(.red, width: 1)
            }
            .padding(0)
            .offset(x: 0, y: -135)
            .rotationEffect(.degrees(180))
            .border(.red, width: 1)
            
            HStack(spacing: 0) {
                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .white],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    //.border(.red, width: 1)

                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .mint],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: -1, y: 1) // Horizontal mirror
                    //.border(.red, width: 1)
            }
            .padding(0)
            .offset(x: -60, y: -105)
            .rotationEffect(.degrees(240))
            .border(.red, width: 1)

            HStack(spacing: 0) {
                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .white],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    //.border(.red, width: 1)

                SnowFlake()
                    .fill(LinearGradient(
                        colors: [.blue, .mint],
                        startPoint: .top,
                        endPoint: .bottom).opacity(0.9))
                    .frame(width: 100, height: 100)
                    .scaleEffect(x: -1, y: 1) // Horizontal mirror
                    //.border(.red, width: 1)
            }
            .padding(0)
            .offset(x: -60, y: -35)
            .rotationEffect(.degrees(300))
            .border(.red, width: 1)
            
            Button(action: {
                // Button action here
                print("Circle button tapped")
            }) {
                ZStack {
                    Circle()
                        .fill(Color.mint)
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                }
                .frame(width: 50, height: 50)
            }
            .buttonStyle(PlainButtonStyle())          // Removes default button tap rectangle effect
            .contentShape(Circle())
            .offset(x: 0, y: 68)
        }
    }
}

#Preview{
    SnowFlakeTest()
}
