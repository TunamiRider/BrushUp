//
//  FirebaseService.swift
//  Model
//
//  Created by Yuki Suzuki on 7/17/25.
//
import FirebaseFirestore
import FirebaseCore
@MainActor
@Observable public final class FirebaseService {
    struct HistoryData : Codable, Hashable {
        var addDt : Date
        var url : String
    }
    // FirebaseApp.configure();
    var historyDataList = [HistoryData]()
    // private let db = Firestore.firestore()

    // Write history data

    //Save history Data
    func saveHistoryData(picrureInfo : [UnsplashImage.ImageInfo]) async throws -> Bool {
        
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(deviceID).collection("history").addDocument(data: [
                "addDt": FieldValue.serverTimestamp(),
                "url" : picrureInfo.first?.urls.regular ?? "undefined"
            ])
            
        } catch {
          print("Error adding document: \(error)")
        }
        return true;
    }
    

    //Read history data
    func readHistoryData() async throws /*-> [HistoryData]*/ {

        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let db = Firestore.firestore()
        let historyDataArray: [HistoryData] = []
        
        let hisotryRef = db.collection("users").document(deviceID).collection("history")
        do {
            let querySnapshot = try await hisotryRef.order(by: "addDt").getDocuments()
            
            let historyDataArray = querySnapshot.documents.map { document in
                let data = document.data()

                // Safely get Timestamp and convert to Date
                let timestamp = data["addDt"] as? Timestamp
                let date = timestamp?.dateValue() ?? Date()  // fallback to current date or handle default

                // Safely get url string
                let url = data["url"] as? String ?? ""

                return HistoryData(addDt: date, url: url)
            }
            
            historyDataList = historyDataArray ?? [HistoryData]()
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
            // Test
            

        } catch {
            print("Error getting document: \(error)")
        }
        
        print("successs")
        // return  historyDataArray
    }
    

}

