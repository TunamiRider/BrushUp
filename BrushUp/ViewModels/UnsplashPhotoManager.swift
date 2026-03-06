//
//  UnsplashViewModel.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/20/26.
//
import Foundation
@MainActor
@Observable public final class UnsplashPhotoManager {
    private let unsplashService: UnsplashService
    private let firebaseService: FirebaseService
    
    private var picrureInfo = [PhotoRecord]()
    var errorMessage: String?
    private var _isSaving = false
    
    private var playerHistoryRecord = [PhotoRecord]()
    private var currentPlayerHistoryIndex = -1
    
    var isSaving: Bool { _isSaving }
    private var orientation: Orientation {
        let width = self.picrureInfo.first?.width ?? 0
        let height = self.picrureInfo.first?.height ?? 0
        
        if width > height {
            return .landscape
        } else if height > width {
            return .portrait
        }
        return .square
    }
    var photoURL: URL? {
        //picrureInfo.first?.urls.regularUrl ?? AppConstants.imageURL
        
        if currentPlayerHistoryIndex > -1 {
            return playerHistoryRecord[safe: currentPlayerHistoryIndex]?.urls.regularUrl
        }
        return AppConstants.imageURL
    }
    
    init(unsplashService: UnsplashService, firebaseService: FirebaseService) {
        self.unsplashService = unsplashService
        self.firebaseService = firebaseService
    }
    
    func fetchRandomPhoto() async {
        
        do {
            picrureInfo = try await unsplashService.fetchRandomPhoto()
        } catch {
            picrureInfo = [PhotoRecord]()
            errorMessage = "Failed to load photo: \(error.localizedDescription)"
        }
        


        guard let nextPhoto = picrureInfo.first else { return }
        
        playerHistoryRecord.append(nextPhoto)
        currentPlayerHistoryIndex += 1

    }
    
    func savePhotoData() async {
        guard !picrureInfo.isEmpty else {
            errorMessage = "No photo to save"
            return
        }
        _isSaving = true
        errorMessage = nil
        
        do {
            let success = try await firebaseService.saveHistoryRecord(picrureInfo: picrureInfo)
            if success {
                errorMessage = "Photo saved successfully"
            } else {
                errorMessage = "No data to save photo"
            }
        }catch {
            errorMessage = "Failed to save photo: \(error.localizedDescription)"
        }
        
        _isSaving = false
    }
    
    func fetchPreviousPhoto() async {
        guard !playerHistoryRecord.isEmpty else { return }
        
        picrureInfo = [PhotoRecord]()
        picrureInfo.append(playerHistoryRecord[safe: currentPlayerHistoryIndex - 1]!)
        //print(playerHistoryRecord[safe: currentPlayerHistoryIndex - 1]!.urls.regularUrl)
        currentPlayerHistoryIndex = currentPlayerHistoryIndex - 1
        
        //print("previous fetched: \(picrureInfo)")
    }
    func isPreviousPhotoAvailable() -> Bool {
        (playerHistoryRecord[safe: currentPlayerHistoryIndex - 1] != nil)
    }
    func fetchNextPhoto() async {
        guard !playerHistoryRecord.isEmpty else { return }
        
        picrureInfo = [PhotoRecord]()
        picrureInfo.append(playerHistoryRecord[safe: currentPlayerHistoryIndex + 1]!)
        //print(playerHistoryRecord[safe: currentPlayerHistoryIndex + 1]!.urls.regularUrl)
        currentPlayerHistoryIndex = currentPlayerHistoryIndex + 1
        //print("next fetched: \(picrureInfo)")
    }
    func isNextPhotoAvailable() -> Bool {
        (playerHistoryRecord[safe: currentPlayerHistoryIndex + 1] != nil)
    }

    
    
    public func countrecord()-> Int{
        //print("array: \(playerHistoryRecord)")
        //print("index: \(currentPlayerHistoryIndex) and count : \(playerHistoryRecord.count)")
        //print("photoURL = \(photoURL?.absoluteString ?? "nil")")
        return playerHistoryRecord.count
    }
}

