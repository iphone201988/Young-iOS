//// Email:
//// Password:
//// Subscription Group ID:
//// Apple ID (An automatically generated ID assigned to your in-app purchase.): 6742645085
//// Group Reference Name:
//// App-Specific Shared Secret:
//// Bundle identifier:
//// Product Identifier:  - for one time
//// Product Identifier:  - for per month
////iossandbox2025@gmail.com
////Techwinlabs123$
//
//

/*
import UIKit
import Foundation
import StoreKit

enum TransactionStates {
    case disabled
    case restored
    case purchased
    case failed
    case noReceiptFound
    case purchasing
    case unspecific
    case noProductsFound
    case removedTransactions
    case restoreFailed
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .failed: return "Transactions failed"
        case .noReceiptFound: return "No receipt found"
        case .purchasing: return "Purchasing..."
        case .unspecific: return "Unspecific"
        case .noProductsFound: return "No products found"
        case .removedTransactions: return "Removed transactions"
        case .restoreFailed: return "Restore failed"
        }
    }
}

public indirect enum ReceiptServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case invalidURL
    case other(Error)
    case errorMessage(errorDesc: String?, statusCode: Int64? = nil)
}

class IAPHandler: NSObject {
    typealias ProductIdentifier = String
    typealias ResponseHandler<T: Decodable> = (Result<T, ReceiptServiceError>) -> Void
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    var transactionState: ((TransactionStates) -> Void)?
    static let shared = IAPHandler()
    fileprivate var productID = ""
    fileprivate var subscriptionAccountSecretKey = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    var originalTransactionID: String = ""
    var transactionID: String = ""
    var subscriptionExpiry: String = ""
    var purchasedProductID: String = ""
    var subscriptionPurchaseDate: String = ""
    
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(val: String) {
        if iapProducts.count == 0 {
            transactionState?(.noProductsFound)
            return
        }
        if canMakePurchases() {
            let filtered = iapProducts.filter{ $0.productIdentifier == val }
            if let product = filtered.first {
                LogHandler.debugLog("product name \(product)")
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                LogHandler.debugLog("PRODUCT TO PURCHASE: \(product.productIdentifier)")
                productID = product.productIdentifier
            }
        } else {
            transactionState?(.disabled)
        }
    }
    
    // MARK: - RESTORE PURCHASE
    func restorePurchase() {
        /// `Start/Show Loading Indicator`
        LoaderUtil.shared.showLoading()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts() {
        // Put here your IAP Products ID's
        productsRequest = SKProductsRequest(productIdentifiers: Products.productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                LogHandler.debugLog(product.localizedDescription + "\nfor just \(price1Str!)")
            }
        } else {
            LogHandler.debugLog("response for invalid indentifier \(response.invalidProductIdentifiers)")
        }
    }
    
    func invalidProductAlert(title: String?,
                             message: String?,
                             actionTitles: [String?],
                             vc: UIViewController,
                             actions: [((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            if index == 0 {
                action.setValue(UIColor.red, forKey: "titleTextColor")
            }
            alert.addAction(action)
        }
        vc.present(alert, animated: true, completion: nil)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        transactionState?(.restored)
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    LogHandler.debugLog("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    transactionState?(.purchased)
                    break
                case .failed:
                    LogHandler.debugLog("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    transactionState?(.failed)
                    break
                case .restored:
                    LogHandler.debugLog("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    transactionState?(.restored)
                    break
                case .purchasing:
                    LogHandler.debugLog("purchasing")
                    transactionState?(.purchasing)
                default:
                    LogHandler.debugLog("something")
                    transactionState?(.unspecific)
                }}}
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        LogHandler.debugLog("removedTransactions")
        transactionState?(.removedTransactions)
    }
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        LogHandler.debugLog("restoreCompletedTransactionsFailedWithError")
        transactionState?(.restoreFailed)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
    }
}

//MARK: Handle In-App Purchase's Receipt's Module
extension IAPHandler {
    
    @MainActor
    func performActionOnPurchasedEvent(completion: @escaping (_ state: TransactionStates) -> Void) {
        transactionState = { state in
            /// `Start/Show Loading Indicator`
            LoaderUtil.shared.showLoading()
            if state == .purchased {
                LogHandler.debugLog("purchased")
                /// `Stop/Hide Loading Indicator`
                LoaderUtil.shared.hideLoading()
            } else {
                if state == .purchasing {
                    /// `Start/Show Loading Indicator`
                    LoaderUtil.shared.showLoading()
                } else {
                    /// `Stop/Hide Loading Indicator`
                    LoaderUtil.shared.hideLoading()
                }
                completion(state)
            }
        }
    }
}

public struct Products {
    public static let standardPlan = "Doqta_Monthly_Premium_Subscription"
    public static let paidFeedPlan = "Doqta_Yearly_Premium_Subscription"
    public static let premiumPlan = "com.YoungApp.Young.Premium"
    public static let productIdentifiers:Set<String> = [standardPlan, paidFeedPlan]
}
*/


//
///*
// sandboxiphone201988@gmail.com
// Techwinlabs123$
// */


import Foundation
import StoreKit
import UIKit

enum TransactionStates {
    case disabled
    case restored
    case purchased
    case failed
    case noReceiptFound
    case purchasing
    case unspecific
    case noProductsFound
    case removedTransactions
    case restoreFailed
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .failed: return "Transaction failed"
        case .noReceiptFound: return "No receipt found"
        case .purchasing: return "Purchasing..."
        case .unspecific: return "Unspecific"
        case .noProductsFound: return "No products found"
        case .removedTransactions: return "Removed transactions"
        case .restoreFailed: return "Restore failed"
        }
    }
}

public indirect enum ReceiptServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case invalidURL
    case other(Error)
    case errorMessage(errorDesc: String?, statusCode: Int64? = nil)
}

public struct Products {
    public static let standardPlan = "Doqta_Monthly_Premium_Subscription"
    public static let paidFeedPlan = "Doqta_Yearly_Premium_Subscription"
    public static let premiumPlan = "com.YoungApp.Young.Premium"
    public static let productIdentifiers: Set<String> = [premiumPlan]
}
 
@MainActor
class IAPHandler {
    static let shared = IAPHandler()
    private init() {}
    
    private(set) var availableProducts: [Product] = []
    var transactionState: ((TransactionStates) -> Void)?
    
    var originalTransactionID: String = ""
    var transactionID: String = ""
    var subscriptionExpiry: String = ""
    var purchasedProductID: String = ""
    var subscriptionPurchaseDate: String = ""
    
    // MARK: - Fetch Products
    func fetchAvailableProducts() async {
        do {
            //LoaderUtil.shared.showLoading()
            let products = try await Product.products(for: Products.productIdentifiers)
            availableProducts = products
            if products.isEmpty {
                transactionState?(.noProductsFound)
                LogHandler.debugLog("No products found")
            } else {
                for product in products {
                    let priceFormatter = NumberFormatter()
                    priceFormatter.numberStyle = .currency
                    priceFormatter.locale = product.priceFormatStyle.locale
                    let priceString = product.displayPrice
                    LogHandler.debugLog("\(product.displayName): \(product.description) - \(priceString)")
                }
            }
        } catch {
            LogHandler.debugLog("Failed to fetch products: \(error)")
            transactionState?(.noProductsFound)
        }
        LoaderUtil.shared.hideLoading()
    }
    
    // MARK: - Purchase
    func purchase(productID: String, presentingIn viewController: UIViewController) async {
        guard let product = availableProducts.first(where: { $0.id == productID }) else {
            transactionState?(.noProductsFound)
            return
        }
        
        LoaderUtil.shared.showLoading()
        transactionState?(.purchasing)
        
        do {
            let result = try await product.purchase(confirmIn: viewController)
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                    purchasedProductID = transaction.productID
                    transactionID = transaction.id.description
                    originalTransactionID = transaction.originalID.description
                    subscriptionPurchaseDate = transaction.purchaseDate.ISO8601Format()
                    if let renewalDate = transaction.expirationDate {
                        subscriptionExpiry = renewalDate.ISO8601Format()
                    }
                    transactionState?(.purchased)
                case .unverified(_, let error):
                    LogHandler.debugLog("Purchase verification failed: \(error)")
                    transactionState?(.failed)
                }
            case .pending:
                transactionState?(.purchasing)
            case .userCancelled:
                transactionState?(.failed)
            @unknown default:
                transactionState?(.unspecific)
            }
        } catch {
            LogHandler.debugLog("Purchase failed: \(error)")
            transactionState?(.failed)
        }
        
        LoaderUtil.shared.hideLoading()
    }
    
    // MARK: - Observe Transactions
    func observeTransactions() {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                await self?.handleTransactionUpdate(update)
            }
        }
    }
    
    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await transaction.finish()
            transactionState?(.purchased)
        case .unverified(_, let error):
            LogHandler.debugLog("Transaction update verification failed: \(error)")
            transactionState?(.failed)
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        LoaderUtil.shared.showLoading()
        var restoredAny = false
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                restoredAny = true
                transactionState?(.restored)
                LogHandler.debugLog("Restored: \(transaction.productID)")
            case .unverified(_, let error):
                LogHandler.debugLog("Unverified restore: \(error)")
            }
        }
        
        if !restoredAny {
            transactionState?(.restoreFailed)
        }
        
        LoaderUtil.shared.hideLoading()
    }
    
    // MARK: - Set Completion Handler
    func performActionOnPurchasedEvent(completion: @escaping (_ state: TransactionStates) -> Void) {
        transactionState = { state in
            if state == .purchasing {
                LoaderUtil.shared.showLoading()
            } else {
                LoaderUtil.shared.hideLoading()
            }
            completion(state)
        }
    }
}
