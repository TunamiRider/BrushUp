//
//  FirebaseService.swift
//  Model
//
//  Created by Yuki Suzuki on 7/17/25.
//
import FirebaseFirestore
import FirebaseCore
import SwiftData

public actor FirebaseService {
    private var deviceID: String
    
    public init(){
        self.deviceID = UUID().uuidString
    }
    init(uuidString: String){
        self.deviceID = uuidString
    }
    
    func setDeviceID(uid: String) async -> Bool {
        deviceID = uid  // Now works inside actor
        return true
    }
    
    func getDevieID() -> String {
        return deviceID
    }
    
    private func save<T: FirestoreConvertible>(_ object: T,to collectionPath: String) async -> Bool {
        let db = Firestore.firestore()
        //print(collectionPath)
        return await withCheckedContinuation { continuation in
            db.collection(collectionPath)
                .addDocument(data: object.dictionary) { error in
                    continuation.resume(returning: error == nil)
                }
        }
    }
    func saveData<T: Codable>(_ object: T, to path: String) async throws -> Bool {
        let db = Firestore.firestore()
        let ref = db.document(path)
        
        try ref.setData(from: object)  // Now works!
        return true
    }
    private func fetch<T: Codable>(_ type: T.Type,from collectionPath: String) async throws -> [T] {
        
        let db = Firestore.firestore()
        let snapshot = try await db.collection(collectionPath).getDocuments()
        
        return snapshot.documents.compactMap {
            try? $0.data(as: T.self)
        }
    }
    
    func saveHistoryRecord(picrureInfo : [PhotoRecord]) async throws -> Bool {
        guard let firstImage = picrureInfo.first else { return false }
        let record = HistoryRecord(url: firstImage.urls.regular)
        let path = FirestorePath.history(for: deviceID)
        
        return await save(record, to: path)
        //return true
    }
    func fetchHistoryRecord() async throws -> [HistoryRecord] {
        let path = FirestorePath.history(for: deviceID)
        
        return try await fetch(HistoryRecord.self, from: path)
    }
    
    func getUnsplashApiKey() async throws -> String {
        // Store in Firestore: /config/unsplash_api_key
        let db = Firestore.firestore()
        //let doc = db.collection("config").document("unsplash_api_key")
        let doc = db.document(FirestorePath.unsplashApiKey)
        let snapshot = try await doc.getDocument()
        
        return try snapshot.data(as: Config.self).apiKey
    }
    
    func singUp(uid: String, createdAt: Date) async throws -> Bool {
        
        let db = Firestore.firestore()
        
        let user = User(uid: uid, createdAt: createdAt)
        
        //print("FirestorePath.users_path(for: uid) \(FirestorePath.users_path(for: uid))")
        return try await saveData(user, to: FirestorePath.users_path(for: uid))
    }
    
    public func getRandomPhotoData() async throws -> PhotoRecord? {
        //throw URLError(.badServerResponse)
        let db = Firestore.firestore()
        // random photo wtih category
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
        let photoCategory = photoCategories.isEmpty ? "" : photoCategories.randomElement()!.name
        
        if !photoCategory.isEmpty {
            let snapshot = try await db.collection(FirestorePath.toPhotosCollection)
                .whereField(FirestoreField.tags, arrayContains: photoCategory)
                .getDocuments()

            if let doc = snapshot.documents.randomElement(){
                let docModel = try doc.data(as: PhotoDoc.self)
                
                let photoRecord = PhotoRecord(
                    urls: Urls(regular: docModel.url),
                    width: 0,
                    height: 0
                )
                return photoRecord
            }
        }
        
        //random photo with index
        let max_index = try await db.document(FirestorePath.toPhoto_index).getDocument().data(as: Index.self).photo_index
        let randomIndex = Int.random(in: 1 ... max_index - 1)
        
        
        let snapshot = try await db.collection(FirestorePath.toPhotosCollection)
            .whereField(FirestoreField.index, isEqualTo:  randomIndex)
            .getDocuments()

        guard let doc = snapshot.documents.randomElement() else { return PhotoRecord(urls: Urls(regular: AppConstants.imageURL.absoluteString), width: 0, height: 0) }
        
        let docModel = try doc.data(as: PhotoDoc.self)
        
        let photoRecord = PhotoRecord(
            urls: Urls(regular: docModel.url),
            width: 0,
            height: 0
        )
        return photoRecord
    }

    

    // Write history data
//    func saveHistoryData2(pictureInfo: [ImageInfo]) async throws -> Bool {
//        guard let firstImage = pictureInfo.first else { return false }
//        
//        let record = HistoryRecord(url: firstImage.urls.regular)  // ✅ Typed model
//        
//        try db.collection("users")
//            .document(deviceID)
//            .collection("history")
//            .addDocument(from: record)  // ✅ Auto-encodes to Firestore
//        
//        return true
//    }

//    func saveHistoryData(picrureInfo : [ImageInfo]) async throws -> Bool {
//        
//        guard let firstImage = picrureInfo.first else { return false }
//        
//        let record = HistoryRecord(url: firstImage.urls.regular)
//        let db = Firestore.firestore()
//        return await withCheckedContinuation{ continuation in
//            db.collection("users")
//                .document(deviceID)
//                .collection("history")
//                .addDocument(data: record.dictionary){ error in
//                    continuation.resume(returning: error == nil)
////                    if let error = error {
////                        continuation.resume(throwing: error)
////                    } else {
////                        continuation.resume(returning: true)
////                    }
//                }
//                
//        }
////        do {
////            try await db.collection("users").document(deviceID).collection("history").addDocument(data: [
////                "addDt": FieldValue.serverTimestamp(),
////                "url" : picrureInfo.first?.urls.regular ?? "undefined"
////            ])
////            
////        } catch {
////          print("Error adding document: \(error)")
////            return false
////        }
////        return true
//    }
    
//    func fetchHistoryData() async throws -> [HistoryData] {
//        // let deviceID = UIDevice.current.identifierForVendor!.uuidString
//        let db = Firestore.firestore()
//        let snapshot = try await db.collection("users").document(deviceID).collection("history").getDocuments()
//        
//        return snapshot.documents.compactMap{ doc in
//            try? doc.data(as: HistoryData.self)
//        }
//    }
}

//  確認用プリント
//            print("ID: \(deviceID)")
//            for data in historyDataArray {
//                print("\(data.addDt) => \(data.url)")
//                print()
//            }

// Test
// .map expects you to return one element per closure call
// Return dictionary per closure,
//            let dataArray = querySnapshot.documents.map { document -> [String: Any] in
//                var data = document.data()
//                // Convert Firestore Timestamp 'addDt' field to Date
//                if let timestamp = data["addDt"] as? Timestamp {
//                    data["addDt"] = timestamp.dateValue()
//                }
//
//                // Access 'url' field (assumed to be String)
//                if let url = data["url"] as? String {
//                    data["url"] = url
//                }
//                return data
//            }

//            汎用マッピング変換 From Documents objs
//            let allData = querySnapshot.documents.map { $0.data() }

//            　Document Array 確認用
//            for data in dataArray {
//                print("\(data["url"] ?? "undefined")")
//                print("\(data["addDt"] ?? "undefined")")
//                print("********")
//                print()
//            }
//print(allData)

//Read history data
//    func readHistoryData() async throws /*-> [HistoryData]*/ {
//
//        let deviceID = UIDevice.current.identifierForVendor!.uuidString
//        let db = Firestore.firestore()
//        let historyDataArray: [HistoryData] = []
//
//        let hisotryRef = db.collection("users").document(deviceID).collection("history")
//        do {
//            let querySnapshot = try await hisotryRef.order(by: "addDt").getDocuments()
//
//            let historyDataArray = querySnapshot.documents.map { document in
//                let data = document.data()
//
//                // Safely get Timestamp and convert to Date
//                let timestamp = data["addDt"] as? Timestamp
//                let date = timestamp?.dateValue() ?? Date()  // fallback to current date or handle default
//
//                // Safely get url string
//                let url = data["url"] as? String ?? ""
//
//                return HistoryData(addDt: date, url: url)
//            }
//
//            historyDataList = historyDataArray ?? [HistoryData]()
//        } catch {
//            print("Error getting document: \(error)")
//        }
//    }

