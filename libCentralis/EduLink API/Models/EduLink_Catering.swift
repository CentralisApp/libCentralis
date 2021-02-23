//
//  EduLink_Catering.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

/// A model for working with Catering
public class EduLink_Catering {
    /// Retrieve the balance and transactions of a user. For more documentation see `Catering`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func catering(_ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Catering", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            EduLinkAPI.shared.catering.balance = result["balance"] as? Double ?? 0.0
            EduLinkAPI.shared.catering.transactions.removeAll()
            if let transactions = result["transactions"] as? [[String : Any]] {
                for transaction in transactions {
                    var cateringTransaction = CateringTransaction()
                    cateringTransaction.id = "\(transaction["id"] ?? "Not Given")"
                    cateringTransaction.date = transaction["date"] as? String ?? "Not Given"
                    let items = transaction["items"] as? [[String : Any]] ?? [[String : Any]]()
                    for item in items {
                        var cateringItem = CateringItem()
                        cateringItem.item = item["item"] as? String ?? "Not Given"
                        cateringItem.price = item["price"] as? Double ?? 0.0
                        cateringTransaction.items.append(cateringItem)
                    }
                    EduLinkAPI.shared.catering.transactions.append(cateringTransaction)
                }
            }
            return rootCompletion(true, nil)
        })
    }
    
    class public func botCatering(_ auth: String, _ server: String, _ completionHandler: @escaping completionHandler) {
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: server, requestMethod: "EduLink.Catering", params: params, completion: { (success, dict) -> Void in
            if !success { return completionHandler(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return completionHandler(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return completionHandler(false, (result["error"] as? String ?? "Unknown Error")) }
            let balance = result["balance"] as? Double ?? 0.0
            let numstring = String(format: "%03.2f", balance)
            completionHandler(true, "£\(numstring)")
        })
    }

}

/// A container for a CateringTransaction
public struct CateringTransaction {
    /// The ID of the transaction
    public var id: String!
    /// The date of the transaction
    public var date: String!
    /// The items that were purchased, for more documentation see `CateringItem`
    public var items = [CateringItem]()
}

/// A container for a CateringItem
public struct CateringItem {
    /// The item that was purchased
    public var item: String!
    /// The price of the item
    public var price: Double!
}

/// The container for Catering
public struct Catering {
    /// The balance of the user
    public var balance: Double!
    /// An array of transactions by the user, for more documentation see `CateringTransaction`
    public var transactions = [CateringTransaction]()
}
