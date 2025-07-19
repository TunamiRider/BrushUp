//
//  ZoomView2.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 7/22/25.
//

import SwiftUI

struct ZoomableAsyncImageView2: UIViewRepresentable {
    let imageURL: URL
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        
        // Configure scrollView zoom
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.zoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // UIImageView setup
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        context.coordinator.scrollView = scrollView
        
        // Constraints: imageView fills scrollView's content area
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
        ])
        
        // Add double tap gesture recognizer for zoom toggle
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        // Load the image async
        context.coordinator.loadImage(from: imageURL)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // No updates needed here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        weak var scrollView: UIScrollView?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = imageView else { return }
            let scrollViewSize = scrollView.bounds.size
            let imageViewSize = imageView.frame.size
            
            let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
            let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
            
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        }
        
        func loadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil, let img = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self?.imageView?.image = img
                }
            }.resume()
        }
        
        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            guard let scrollView = scrollView else { return }
            
            if scrollView.zoomScale != scrollView.minimumZoomScale {
                // Reset zoom to 1x (original)
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                // Zoom in to 3x at tap location
                let location = sender.location(in: imageView)
                zoom(to: location, scale: 3.0)
            }
        }
        
        private func zoom(to point: CGPoint, scale: CGFloat) {
            guard let scrollView = scrollView, let imageView = imageView else { return }
            
            // Calculate zoom rect so the zoom centers on tap location
            let scrollViewSize = scrollView.bounds.size
            
            let width = scrollViewSize.width / scale
            let height = scrollViewSize.height / scale
            
            let x = point.x - (width / 2)
            let y = point.y - (height / 2)
            
            let zoomRect = CGRect(x: x, y: y, width: width, height: height)
            
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}


struct ContentView4: View {
    let url = URL(string: "https://images.unsplash.com/photo-1494256997604-768d1f608cac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2MjQ3MDh8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTMyNDYxODZ8&ixlib=rb-4.1.0&q=80&w=1080")!
    
    //@State private var showFullScreen = false
    
    var body: some View {
        ZoomableAsyncImageView2(imageURL: url)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        
//        VStack {
//            Button(action: {
//                showFullScreen = true
//            }) {
//                Image(systemName: "swift")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 200, height: 200) // Thumbnail size
//            }
//        }
//        .fullScreenCover(isPresented: $showFullScreen) {
//            ZStack(alignment: .topTrailing) {
//                Color.black.edgesIgnoringSafeArea(.all)
//                Image(systemName: "swift")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.black)
//                Button(action: {
//                    showFullScreen = false
//                }) {
//                    Image(systemName: "swift")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.white)
//                        .padding()
//                }
//            }
//        }
    }
}

#Preview {
    ContentView4()
}
