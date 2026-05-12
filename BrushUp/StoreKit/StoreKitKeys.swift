//
//  StoreKitKeys.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 4/15/26.
//
import Foundation
enum StoreKitKeys {
    static var subscriptionGroupID: String {
        return Bundle.main.object(forInfoDictionaryKey: "SUBSCRIPTION_GROUP_ID") as? String ?? ""
    }
    static var subscribedProductIDs: [String] {
        let delimited = Bundle.main.object(forInfoDictionaryKey: "SUBSCRIBED_PRODUCT_IDS") as? String ?? ""
        return delimited
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    static var inapppurchaseProductID: String {
        return Bundle.main.object(forInfoDictionaryKey: "INAPPPURCHASE_PRODUCT_ID") as? String ?? ""
    }
}
