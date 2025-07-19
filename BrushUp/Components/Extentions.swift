//
//  Extentions.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 11/1/25.
//
import SwiftUI

struct Popup<T: View>: ViewModifier {
  let isPresented: Bool
  let popup: T

  init(isPresented: Bool, @ViewBuilder content: () -> T) {
    self.isPresented = isPresented
    self.popup = content()
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if isPresented {
          popup
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.4)) // optional dimming
        }
      }
  }
}

extension View {
  func popup<T: View>(isPresented: Bool, @ViewBuilder content: () -> T) -> some View {
    modifier(Popup(isPresented: isPresented, content: content))
  }
}



struct Extentions_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var showingPopup = false
        var body: some View {
            Button("Show Popup") {
              showingPopup = true
            }
            .popup(isPresented: showingPopup) {
              Text("This is a popup")
                .frame(width: 200, height: 200)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
