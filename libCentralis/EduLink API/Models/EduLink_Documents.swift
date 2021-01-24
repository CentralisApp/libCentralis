//
//  EduLink_Documents.swift
//  Centralis
//
//  Created by AW on 12/12/2020.
//

import Foundation

/// A model for working with Documents
public class EduLink_Documents {
    /// Retrieve a list of documents available to the user. For more documentation see `Document`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func documents(_ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : EduLinkAPI.shared.authorisedUser.id,
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Documents", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let documents = result["documents"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error") }
            EduLinkAPI.shared.documents.removeAll()
            for document in documents {
                var d = Document()
                d.id = "\(document["id"] ?? "Not Given")"
                d.summary = document["summary"] as? String ?? "Not Given"
                d.type = document["type"] as? String ?? "Not Given"
                d.last_updated = document["last_updated"] as? String ?? "Not Given"
                EduLinkAPI.shared.documents.append(d)
            }
            rootCompletion(true, nil)
        })
    }
    
    
    /// Retrieve the document date and mime type
    /// - Parameters:
    ///   - document: The document the data is being parsed, for more documentation see `Document`
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func document(_ document: Document, _ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken,
            "document_id" : document.id
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Document", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let r = result["result"] as? [String : Any], let data = r["document"] as? String, let index = EduLinkAPI.shared.documents.firstIndex(where: { $0.id == document.id }), let mime_type = r["mime_type"] as? String else { return rootCompletion(false, "Unknown Error") }
            EduLinkAPI.shared.documents[index].data = data; EduLinkAPI.shared.documents[index].mime_type = mime_type
            rootCompletion(true, nil)
        })
    }
}

public struct Document {
    public var id: String!
    public var summary: String!
    public var type: String!
    public var last_updated: String!
    public var data: String!
    public var mime_type: String!
}
