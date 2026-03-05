//
//  FetchService.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/19/26.
//
import Foundation

struct FetchService {
    
    public init(){}

    public func loadData<T: Decodable>(endpoint url:String, type: T.Type) async throws -> [T] {
        
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return [T]()
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let responseData = try decoder.decode([T].self, from: data)
        
        return responseData
    }
    
    private func fetchImagesSyncronosly<T: Decodable>(endpoint: String, type: T.Type) async throws -> [T] {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return [T]()
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Decode error: \(error)")
            return [T]()
        }
    }
    
    public func fetchMultipleImages<T: Decodable>(endpoint: String, type: T.Type) async throws -> [T] {
        
        guard let url = URL(string: endpoint) else {
            print("Invalid URL")
            return [T]()
        }
        
       let (data, _) = try await URLSession.shared.data(from: url)

       let decodedData = try JSONDecoder().decode([T].self, from: data)
        
       return decodedData
   }
}
