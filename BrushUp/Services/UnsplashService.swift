//
//  UnsplashService.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/20/26.
//
import Foundation
import SwiftData
struct UnsplashService: UnsplashServiceProtocol {

    private let fetchService: FetchService
    private let firebaseService: FirebaseService
    
    init(fetchService: FetchService, firebaseService: FirebaseService) {
        self.fetchService = fetchService
        self.firebaseService = firebaseService
    }
    
    private func getApiKey() async throws -> String {
        //impl to test if apikey works
        let apikey_fb = (try? await firebaseService.getUnsplashApiKey()) ?? ""
        
        guard apikey_fb.isEmpty else {
            return apikey_fb
        }
        
//        guard !Secrets.apiKey.isEmpty else {
//            
//            return apikey_fb
//        }
        
        return Secrets.apiKey
    }
    
    
    
    func fetchRandomPhoto() async throws -> [PhotoRecord] {
        let config: ModelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container:ModelContainer = try! ModelContainer(for: PhotoCategory.self, configurations: config)
        let context = ModelContext(container)

        let photoCategories: [PhotoCategory]
        do {
            photoCategories = try context.fetch(FetchDescriptor<PhotoCategory>(sortBy: [SortDescriptor(\PhotoCategory.name)]))
        } catch {
            print(error)
            photoCategories = []
        }
        
        let photoCategory = photoCategories.isEmpty ? "" : photoCategories.randomElement()!.name;
        
        let apikey = try await getApiKey()
        let endpoint = UnsplashAPI.apiEndpoint(with: photoCategory, apiKey: apikey, count: 1)

        let result = try? await self.fetchService.loadData(endpoint: endpoint, type: PhotoRecord.self)
        
        return result ?? [PhotoRecord]()
    }
    
    func fetchPhotos() async throws -> [PhotoRecord] {
        
        let apikey = try await getApiKey()
        let endpoint = UnsplashAPI.apiEndpoint(apiKey: apikey, count: 50)
        
        let result = try? await fetchService.loadData(endpoint: endpoint, type: PhotoRecord.self)
        
        return result ?? [PhotoRecord]()
    }
}
