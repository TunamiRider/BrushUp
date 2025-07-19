//
//  Layout.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 10/29/25.
//
import SwiftUI


struct Layout : View {
    
    var body: some View {
        Image("yourImage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 4)
            )
        Image("yourImageName")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .clipShape(Triangle())
            .overlay(
                Triangle()
                    .stroke(Color.blue, lineWidth: 5)
            )
        
        ZStack {
            Triangle()
                .fill(Color.red)
                .frame(width: 100, height: 100)
            Triangle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(90))
            Triangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(180))
            Triangle()
                .fill(Color.yellow)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(270))
        }
        
        ZStack {
            Image(systemName: "calendar")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Triangle())
            
            Image(systemName: "calendar")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Triangle())
                .rotationEffect(.degrees(90))
            
            Image(systemName: "calendar")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Triangle())
                .rotationEffect(.degrees(180))
            
            Image(systemName: "calendar")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Triangle())
                .rotationEffect(.degrees(270))
        }
        .frame(width: 200, height: 200) // adjust to fit all triangles correctly
        .clipped()
        
    }
    
    
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start at bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Draw to top center
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        // Draw to bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Close the path (back to bottom left)
        path.closeSubpath()
        return path
    }
}

#Preview {
    Layout()
}
