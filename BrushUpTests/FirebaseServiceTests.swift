//
//  FirebaseServiceTests.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 5/5/26.
//

import Testing
import BrushUp

import Foundation
import SwiftUI
struct FirebaseServiceTests {
    @Test @MainActor func testSaveInvalidHistoryData() async throws {
        
    }
//    @Test @MainActor func testReadHistoryData() async throws {
//        let firebaseService : FirebaseService = FirebaseService()
//
//        // let result: [UnsplashImage.ImageInfo] = firebaseService.readHistoryData()
//    }
    @Test @MainActor func testReadInvalidHistoryData() async throws {
        
    }
    
    @Test @MainActor func testFetchRandomPhotoFromFirebase() async throws {
        let firebaseService = FirebaseService()
        
        let photoRecord = try await firebaseService.getRandomPhotoData()
        
        
        if let photoRecord {
            print("✅ Got photo: \(photoRecord)")
        } else {
            print("❌ photoRecord is nil")
        }
        
        #expect(photoRecord != nil)
        
    }
}

