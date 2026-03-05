//
//  HistoryRecord.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//
import Foundation
import FirebaseFirestore
struct HistoryRecord: Codable, FirestoreConvertible {
    let addDt: Date
    let url : String
    
    init(url: String) {
        self.url = url
        self.addDt = Date()
    }
    
    var dictionary: [String: Any]{
        return [
            "addDt": FieldValue.serverTimestamp(),
            "url": url
        ]
    }
//    @ServerTimestamp var addDt: Date?
//    let url: String
//
}
