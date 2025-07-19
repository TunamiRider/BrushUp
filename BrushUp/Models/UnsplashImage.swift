//
//  UnsplashImage.swift
//  ModelView
//
//  Created by Yuki Suzuki on 5/13/25.
//

import Foundation
import SwiftData
import FirebaseFirestore

@MainActor
@Observable public final class UnsplashImage {
    public struct ImageInfo: Codable {
        let urls: Urls
        let width: Int
        let height: Int
    }
    struct Urls: Codable {
        let regular: String
        var regularUrl: URL { return URL(string: regular)!}
    }
    public enum Orientation {
        case portrait, landscape, square
    }
      
    private let apiEndpoint = "https://api.unsplash.com/photos/random?query=[tag]&count=1"
    private let apiKey = "&client_id=sLxSdZB-s_jOnw_mPtaxMZADNpE_aoHQh-oWsoqrWrg"
    var picrureInfo = [ImageInfo]()
    
    //API Servie
    let fetchService:FetchService = FetchService()
    private let firebaseService : FirebaseService = FirebaseService()
    
    private var orientation: Orientation = .square
    
    public func fetchImages() async throws -> Bool {
        
        let result = try? await fetchService.loadData(endpoint: apiEndpoint + apiKey)
        
        picrureInfo = result ?? [ImageInfo]()
        
        return !picrureInfo.isEmpty;
    }
    
    public func fetchImage() async throws /*-> Bool*/ {
        let config: ModelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container:ModelContainer = try! ModelContainer(for: Tag.self, configurations: config)
        let context = ModelContext(container)

        let tags: [Tag]
        do {
            let start = Date()
            tags = try context.fetch(FetchDescriptor<Tag>(sortBy: [SortDescriptor(\Tag.name)]))
            // print("Main thread fetch takes \(Date().timeIntervalSince(start))")
        } catch {
            print(error)
            tags = []
        }
        
        let tag = tags.isEmpty ? "" : tags.randomElement()!.name;
        var apiEndpointWithTag: String = ""
        
        if let range = apiEndpoint.range(of: "[tag]") {
            apiEndpointWithTag = apiEndpoint.replacingCharacters(in: range, with: tag)
        }
        
        let result = try? await fetchService.loadData(endpoint: apiEndpointWithTag + apiKey)
        
        picrureInfo = result ?? [ImageInfo]()
        
//        let db = Firestore.firestore()
//        let deviceID = UIDevice.current.identifierForVendor!.uuidString
//        
//        do {
//            try await db.collection("users").document(deviceID).collection("history").addDocument(data: [
//                "addedAt": FieldValue.serverTimestamp(),
//                "url" : picrureInfo.first?.urls.regular ?? "undefined"
//            ])
//            
//        } catch {
//          print("Error adding document: \(error)")
//        }
        let success = try? await firebaseService.saveHistoryData(picrureInfo: picrureInfo);
        print("Saved data to firestore : \(String(describing: success?.description)) ")
        
        // print(" Hsitorry data from firestore")
        // let success2 = try? await firebaseService.readHistoryData();
        // print(" Hsitorry data from firestore END")
        

    }
    
    public func getImageURL() -> URL? {
        
        return self.picrureInfo.first?.urls.regularUrl
    }
    public func getOrientation() -> Orientation {
        let width = self.picrureInfo.first?.width ?? 0
        let height = self.picrureInfo.first?.height ?? 0
        
        if width > height {
            return .landscape
        } else if height > width {
            return .portrait
        }
        
        return .square
    }
    
    //Fetch History data from Firestore
    public func fetchHistoryData() -> [UnsplashImage.ImageInfo] {
        let pictureInfo = [UnsplashImage.ImageInfo]()
        
        return pictureInfo;
    }
    
}
//@MainActor
//public protocol ImageFetching {
//    func loadData(endpoint url:String) async throws -> [UnsplashImage.ImageInfo]
//}
@MainActor
public final class FetchService {
    
    public init(){}

    public func loadData(endpoint url:String) async throws -> [UnsplashImage.ImageInfo] {
        
        let pictureInfo = [UnsplashImage.ImageInfo]()
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return pictureInfo
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let responseData = try decoder.decode([UnsplashImage.ImageInfo].self, from: data)
        // print("Fetch successful : \(responseData.first!.urls.regularUrl) ")
        
        return responseData
    }
    
    private func fetchImagesSyncronosly(endpoint: String){
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            var picrureInfo = [UnsplashImage.ImageInfo]()
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([UnsplashImage.ImageInfo].self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        picrureInfo = decodedResponse
                    }
                    // everything is good, so we can exit
                    return
                }
            }
            // if we're still here it means there was a problem
        }.resume()
    }
    
    public func fetchMultipleImages(endpoint: String) async throws {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return
        }
       // let url = URL(string: "https://api.unsplash.com/photos/?client_id=\(apiKey)&order_by=ORDER&per_page=30")!
        
       var picrureInfo = [UnsplashImage.ImageInfo]()
        
       let (data, _) = try await URLSession.shared.data(from: url)

       let decoded = try JSONDecoder().decode([UnsplashImage.ImageInfo].self, from: data)

       picrureInfo.append(contentsOf: decoded)
   }
    
    
}

//Reference
// https://mark-wang.medium.com/fetch-images-from-unsplash-api-cache-swift-5-1cc65fb7bdd5

//https://www.hackingwithswift.com/forums/swiftui/a-problem-with-urlsession-and-json-fetch/8395

//https://github.com/unsplash/unsplash-imageview-ios/blob/master/UnsplashImageView.swift#L38

//https://dev.to/maxixo/how-to-fetch-images-with-unsplash-api-with-javascript-5gf0




//Core Data Reference
// https://bugfender.com/blog/ios-core-data/
// https://medium.com/@dikidwid0/implement-swiftdata-in-swiftui-using-mvvm-architecture-pattern-aa3a9973c87c

// 7/6/25
//https://stackoverflow.com/questions/73358999/how-to-make-a-custom-disclosuregroup-drop-down-in-swiftui/73368328

//https://medium.com/geekculture/tags-view-in-swiftui-e47dc6ce52e8
//https://medium.com/geekculture/side-menu-in-ios-swiftui-9fe1b69fc487

// SwiftData
//https://medium.com/@samhastingsis/use-swiftdata-like-a-boss-92c05cba73bf


//https://www.createwithswift.com/morphing-glass-effect-elements-into-one-another-with-glasseffectid/

//homepage design
// https://sarunw.com/posts/swiftui-tabview-color/

