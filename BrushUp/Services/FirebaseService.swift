//
//  FirebaseService.swift
//  Model
//
//  Created by Yuki Suzuki on 7/17/25.
//
import FirebaseFirestore
import FirebaseCore

actor FirebaseService {
    private let deviceID: String
    
    init(uuidString: String){
        self.deviceID = uuidString
    }
    
    private func save<T: FirestoreConvertible>(_ object: T,to collectionPath: String) async -> Bool {
        let db = Firestore.firestore()
        
        return await withCheckedContinuation { continuation in
            db.collection(collectionPath)
                .addDocument(data: object.dictionary) { error in
                    continuation.resume(returning: error == nil)
                }
        }
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

