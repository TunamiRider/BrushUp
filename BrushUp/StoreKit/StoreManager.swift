//
//  StoreKitTest.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 4/15/26.
//

import SwiftUI
import StoreKit

@MainActor
@Observable
final class StoreManager {
    private(set) var isSubscribed = false

    let subscriptionGroupID = StoreKitKeys.subscriptionGroupID
    let subscribedProductIDs = StoreKitKeys.subscribedProductIDs
    let lifetimeProductID = StoreKitKeys.inapppurchaseProductID
    
    
    nonisolated(unsafe) private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await refreshPurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? result.payloadValue {
                    await transaction.finish()
                    await self.refreshPurchasedProducts()
                }
            }
        }
    }

    func refreshPurchasedProducts() async {
        var subscribed = false

        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue,
               subscribedProductIDs.contains(transaction.productID) ||
                (transaction.productID == lifetimeProductID){
                subscribed = true
                break
            }
        }

        isSubscribed = subscribed
    }

    func syncPurchases() async {
        try? await AppStore.sync()
        await refreshPurchasedProducts()
    }
}

struct SubscriptionPaywallView: View {
    @Environment(StoreManager.self) var store: StoreManager
    @State var isSubscription: Bool = true
    //let allProductIDs = [StoreKitKeys.inapppurchaseProductID]
    
//    private func fetchLifetimeProduct() async -> Product? {
//        if let product = try? await Product.products(for: [StoreKitKeys.inapppurchaseProductID]).first{
//            return product
//        }
//        return nil
//    }
    let privacyPolicyURL = "https://sites.google.com/view/yuzu-works/privacy-policy"  // Your actual URL
    let termsOfUseURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula"      // Your actual URL
    
    var body: some View {
        VStack(spacing: 3) {
            
            HStack(spacing: 8) {
                // Subscription Tab
                Button {
                    isSubscription = true
                } label: {
                    Text("Subscription")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isSubscription ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            isSubscription ?
                            RoundedRectangle(cornerRadius: 10).fill(Color.blue) :
                            RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray4))
                        )
                }
                
                // Purchase Tab
                Button {
                    isSubscription = false
                } label: {
                    Text("Purchase")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(!isSubscription ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            !isSubscription ?
                            RoundedRectangle(cornerRadius: 10).fill(Color.blue) :
                            RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray4))
                        )
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            
            if isSubscription {
                SubscriptionStoreView(groupID: store.subscriptionGroupID)
                {
                    VStack(spacing: 8) {
                        Image("Icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)  // Adjust size
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        VStack(spacing: 2) {
                            Text("BrushUp Pro")  // Short title
                                .font(.title3.weight(.bold))
                            
                            Text("Unlimited access to painting references")  // Short description
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)  // Caps lines
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)  // Less padding
                    .containerBackground(.background, for: .subscriptionStoreHeader)
                }
                .subscriptionStoreControlStyle(.picker)
                .subscriptionStoreButtonLabel(.multiline)
                .storeButton(.visible, for: .restorePurchases)
            } else {
//                StoreView(ids: [store.lifetimeProductID])
//                    .productViewStyle(.compact)
//                    .storeButton(.visible, for: .restorePurchases)
                LifetimeStoreView()
                
            }

            Divider()
            
            // Required functional links
            HStack(spacing: 10) {
                Link("Terms of Use", destination: URL(string: termsOfUseURL)!)
                    .font(.caption)
                Link("Privacy Policy", destination: URL(string: privacyPolicyURL)!)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            await store.refreshPurchasedProducts()
        }

    }
}

struct RootView: View {
    @State var store: StoreManager = StoreManager()

    var body: some View {
        Group {
            if store.isSubscribed {
                EmptyView()
            } else {
                SubscriptionPaywallView()
                    .environment(store)
            }
        }
    }
}

#Preview("Paywall") {
    let store = StoreManager()
    RootView()
        .environment(store)
}




struct LifetimeStoreView: View {
    @Environment(StoreManager.self) var store: StoreManager
    @State private var isSelected = true
    @State private var product: Product? = nil

    var body: some View {
        VStack(spacing: 16) {
            // Header — matches SubscriptionStoreView header
            VStack(spacing: 8) {
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                VStack(spacing: 2) {
                    Text("BrushUp Pro")
                        .font(.title3.weight(.bold))

                    Text("Unlimited access to painting references")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // Picker card — matches the subscription picker style
            VStack(spacing: 0) {
                Button {
                    isSelected = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BrushUp Pro Lifetime")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            if let product {
                                Text(product.displayPrice)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }

                        Spacer()

                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? .blue : .secondary)
                            .font(.title3)
                    }
                    .padding()
                }

                Divider()
                    .padding(.horizontal)

                Text("Lifetime full access to BrushUp Pro")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            // Purchase button
//            Button {
//                Task {
//                    if let product {
//                        // try? await store.purchase(product)
//                    }
//                }
//            } label: {
//                Text(product != nil ? "Subscribe" : "Loading...")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundStyle(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 14))
//            }
//            .padding(.horizontal)
//            .disabled(product == nil)
            
            Button {
                Task {
                    guard let product else { return }
                    
                    do {
                        let result = try await product.purchase()
                        switch result {
                        case .success(let verification):
                            switch verification {
                            case .verified(let transaction):
                                await transaction.finish()  // Required
                                await store.refreshPurchasedProducts()
                            case .unverified:
                                // Handle unverified
                                break
                            }
                        case .userCancelled, .pending:
                            break  // User cancelled or pending
                        @unknown default:
                            break
                        }
                    } catch {
                        // Handle error (e.g., network)
                        print("Purchase failed: \(error)")
                    }
                }
            } label: {
                if let product {
                    Text("Unlock Lifetime - \(product.displayPrice)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                }
            }
            .disabled(product == nil)

            // Restore purchases
            Button("Restore Purchases") {
                Task { try? await AppStore.sync() }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .task {
            product = try? await Product.products(for: [store.lifetimeProductID]).first
        }
        .task {
            await store.refreshPurchasedProducts()
        }
    }
}


