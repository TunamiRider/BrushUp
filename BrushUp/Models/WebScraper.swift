//
//  WebScraper.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 10/26/25.
//

import Foundation
import SwiftUI
import WebKit

@Observable public final class WebScraper {
    
    
    
}

//public class WebScraper: ObservableObject {
//    
//    @Published var html: String?
//    
//    public init() {
//        
//    public func scrape(url: URL) {
//    }
//    
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            
//        }}
//}


//
//struct WebView: UIViewRepresentable {
//    let url: URL
//    
//
//    func makeUIView(context: Context) -> WKWebView {
//        WKWebView()
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        let request = URLRequest(url: url)
//        webView.load(request)
//        // https://www.artnews.com/list/art-news/artists/
//    }
//    
//    func webView2(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { html, error in
//            if let htmlString = html as? String {
//                print("HTML content: \(htmlString)")
//                // Use the HTML string here
//            }
//            if let error = error {
//                print("Error getting HTML: \(error.localizedDescription)")
//            }
//        }
//    }
//}

struct WebScraperView: View {
    let vc = ViewController()
    var body: some View {
//        WebView(url: URL(string: "https://www.artnews.com/c/art-news/artists/")!)
//            .edgesIgnoringSafeArea(.all)
        Text("re")
        
        WebViewContainer()
            .ignoresSafeArea()
            .onDisappear {
                print("WebViewContainer disappeared")
                print("\(vc.urlLins) te")
            }
        
        
        List(vc.urlLins, id: \.self){ url in
                Text(url)
        }
    }
}


#Preview {
    WebScraperView()
}



class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    @State var urlLins: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        if let url = URL(string: "https://www.artnews.com/c/art-news/artists/") {
            let request = URLRequest(url: url)
            webView.load(request)
        
            viewWillDisappear(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Called when view is about to disappear
        print("View will disappear, clean up here if needed")
        print(urlLins)
        webView.stopLoading()
        webView.removeFromSuperview()
        webView = nil
    }
    
    func getAllMatches(html: String) -> [String] {
        let pattern = #"<a\s+href="(https://www.artnews.com/art-news/artists[^"]+)""#
        
        var urls : [String] = []
        if let regex = try? NSRegularExpression(pattern: pattern){
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            
            //Get all matches
            let matches = regex.matches(in: html, options: [], range: range)
            
            // Extract all ULRs
            urls = matches.compactMap{ match -> String? in
                guard let range = Range(match.range(at: 1), in: html) else {return nil}
                return String(html[range])
            }
            
            //確認用 print
            print("ALL ")
            urls.forEach{ print($0) }
            
        }
        
        return urls
    }
    
    func getFirstMatche(html: String) {
        let pattern = #"<a\s+href="(https://www.artnews.com/art-news/artists[^"]+)""#

        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsrange = NSRange(html.startIndex..<html.endIndex, in: html)
            
            if let match = regex.firstMatch(in: html, options: [], range: nsrange),
               let range = Range(match.range(at: 1), in: html) {
                let href = String(html[range])
                // print(match)
                // print("Extracted href: \(href)")
            }
        }
        
    }

    // WKNavigationDelegate method called when web content finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // JavaScript to get the full HTML content
        let js = "document.documentElement.outerHTML.toString()"
        
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("Error fetching HTML: \(error.localizedDescription)")
                return
            }
            
            if let html = result as? String {
                // print("HTML content: \(html)")
                // Here you can process or store the retrieved HTML as needed
                self.urlLins = self.getAllMatches(html: html)
                print(self.urlLins)
                print("***")
            }
            
            // The web view finished loading; remove it from the view hierarchy
//            webView.removeFromSuperview()
//            self.webView = nil
//            print("WebView loaded and removed from view")
            
            
        }
    }
    

}


struct WebViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ViewController {
        // Your existing WKWebView-based ViewController
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Optional: handle updates like changing URLs if needed
    }
}




