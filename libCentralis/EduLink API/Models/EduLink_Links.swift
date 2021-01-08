//
//  EduLink_Links.swift
//  Centralis
//
//  Created by AW on 11/12/2020.
//

import UIKit

public class EduLink_Links {
    class public func links(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.ExternalLinks")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.ExternalLinks\",\"params\":{\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let links = result["links"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error" )}
            EduLinkAPI.shared.links.removeAll()
            for link in links {
                var l = Link()
                l.name = link["name"] as? String ?? "Not Found"
                l.link = link["url"] as? String ?? "Not Found"
                if var imageData = link["icon"] as? String {
                    imageData = imageData.replacingOccurrences(of: "data:image/png;base64,", with: "")
                    if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                        l.image = UIImage(data: decodedData)
                    } else {
                        l.image = UIImage(systemName: "link.circle.fill")
                    }
                } else {
                    l.image = UIImage(systemName: "link.circle.fill")
                }
                EduLinkAPI.shared.links.append(l)
            }
            rootCompletion(true, nil)
        })
    }
}

public struct Link {
    public var name: String!
    public var link: String!
    public var image: UIImage!
}
