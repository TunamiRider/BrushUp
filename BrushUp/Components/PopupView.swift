//
//  PopupView.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/5/26.
//

import SwiftUI
import UIKit
struct PopupView : View {
    @Binding var isNextImage: Bool
    @Binding var isKeptImage: Bool
    var body: some View {
        
        VStack (){
            Text("Proceed to next?")
            
            Button("Goto Next"){
                isNextImage = true
            }
            
            Button("Continue working on this reference"){
                isKeptImage = true;
            }
        }
        .frame(width: 300, height: 200, alignment: .center)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.white)
        )
    }
}

#Preview {
    @Previewable @State var pop = true;
    let url = URL(string: "https://images.unsplash.com/photo-1494256997604-768d1f608cac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjQ3MDh8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTMyNDYxODZ8&ixlib=rb-4.1.0&q=80&w=1080")!
    ZStack(){
        AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea(.all)

        } placeholder: {
            ProgressView()
                .scaleEffect(x: 2.0, y: 2.0, anchor: .center)
        }
        
        if pop {
            PopupView(isNextImage: .constant(false), isKeptImage: .constant(true))
        }
        
    }
    
}
