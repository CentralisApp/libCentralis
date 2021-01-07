//
//  EduLink-Status.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

public class EduLink_Status {
    class public func status(rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Status")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Status\",\"params\":{\"last_visible\":0,\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, "Unknown Error Ocurred") }
            EduLinkAPI.shared.status.new_messages = result["new_messages"] as? Int ?? 0
            EduLinkAPI.shared.status.new_forms = result["new_forms"] as? Int ?? 0
            if let session = result["session"] as? [String : Any] {
                let interval: TimeInterval = Double(session["expires"] as? Int ?? 0)
                EduLinkAPI.shared.status.expires = Date() + interval
            }
            if let lessons = result["lessons"] as? [String : Any] {
                if let current = lessons["current"] as? [String : Any] {
                    EduLinkAPI.shared.status.current = generateLesson(current)
                }
                if let upcoming = lessons["upcoming"] as? [String : Any] {
                    EduLinkAPI.shared.status.upcoming = generateLesson(upcoming)
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class private func generateLesson(_ lesson: [String : Any]) -> MiniLesson {
        var ml = MiniLesson()
        if let room = lesson["room"] as? [String : Any] { ml.room = room["name"] as? String ?? "Not Given" } else { ml.room = "Not Given" }
        if let tg = lesson["teaching_group"] as? [String : Any] { ml.subject = tg["subject"] as? String ?? "Not Given" } else { ml.subject = "Not Given" }
        return ml
    }
}

public struct Status {
    public var new_messages: Int!
    public var new_forms: Int!
    public var expires: Date?
    public var current: MiniLesson!
    public var upcoming: MiniLesson!
    
    public init() {}
    
    public func hasExpired() {
        if let expires = self.expires {
            if expires > Date() {
                NotificationCenter.default.post(name: .ReAuth, object: nil)
            }
        }
    }
}

public struct MiniLesson {
    public var date: Date?
    public var room: String!
    public var subject: String!
}
