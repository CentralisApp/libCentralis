//
//  EduLink-Status.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

public class EduLink_Status {
    class public func status(rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Status", params: params, completion: { (success, dict) -> Void in
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
                    EduLinkAPI.shared.status.current = self.generateLesson(current)
                }
                if let next = lessons["next"] as? [String : Any] {
                    EduLinkAPI.shared.status.upcoming = self.generateLesson(next)
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class private func generateLesson(_ lesson: [String : Any]) -> MiniLesson {
        var ml = MiniLesson()
        if let room = lesson["room"] as? [String : Any] { ml.room = room["name"] as? String ?? "Not Given" }
        if let tg = lesson["teaching_group"] as? [String : Any] { ml.subject = tg["subject"] as? String ?? "Not Given" }
        if let start_time = lesson["start_time"] as? String { ml.startDate = self.dateFromTime(start_time) }
        if let end_time = lesson["end_time"] as? String { ml.endDate = self.dateFromTime(end_time) }
        return ml
    }
    
    class private func dateFromTime(_ time: String) -> Date? {
        let calendar = NSCalendar.current
        var components = calendar.dateComponents([.day,.month,.year], from: Date())
        let hour = time.components(separatedBy: ":")[0]
        let minute = time.components(separatedBy: ":")[1]
        components.hour = Int(hour) ?? 0
        components.minute = Int(minute) ?? 0
        return calendar.date(from: components)
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
    public var startDate: Date?
    public var endDate: Date?
    public var room: String!
    public var subject: String!
}
