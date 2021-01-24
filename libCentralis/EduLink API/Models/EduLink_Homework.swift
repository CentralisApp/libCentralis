//
//  EduLink_Homework.swift
//  Centralis
//
//  Created by AW on 05/12/2020.
//

import Foundation

public class EduLink_Homework {
    
    class public func homework(_ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Homework", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let homework = result["homework"] as? [String : Any] {
                if let current = homework["current"] as? [[String : Any]] {
                    self.scrapeLeWork(.current, dict: current)
                }
                if let past = homework["past"] as? [[String : Any]] {
                    self.scrapeLeWork(.past, dict: past)
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class public func homeworkDetails(_ index: Int!, _ homework: Homework!, _ context: HomeworkContext, _ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken,
            "source" : homework.source,
            "homework_id" : homework.id
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.HomeworkDetails", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let ab = result["homework"] as? [String : Any] {
                var hw = homework
                hw?.description = ab["description"] as? String ?? "Not Given"
                switch context {
                case .current: EduLinkAPI.shared.homework.current[index] = hw!
                case .past: EduLinkAPI.shared.homework.past[index] = hw!
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    class public func completeHomework(_ completed: Bool, _ index: Int, _ context: HomeworkContext, _ rootCompletion: @escaping completionHandler) {
        let homework: Homework!
        switch context{
        case .current: homework = EduLinkAPI.shared.homework.current[index]
        case .past: homework = EduLinkAPI.shared.homework.past[index]
        }
        let params: [String : String] = [
            "learner_id" : EduLinkAPI.shared.authorisedUser.id,
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken,
            "completed" : completed ? "true" : "false",
            "homework_id" : homework.id,
            "source" : homework.source
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.HomeworkCompleted", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            switch context {
            case .current: EduLinkAPI.shared.homework.current[index].completed = completed
            case .past: EduLinkAPI.shared.homework.past[index].completed = completed
            }
            rootCompletion(true, nil)
        })
    }
    
    class public func scrapeLeWork(_ context: HomeworkContext, dict: [[String : Any]]) {
        switch context {
        case .current: EduLinkAPI.shared.homework.current.removeAll()
        case .past: EduLinkAPI.shared.homework.past.removeAll()
        }
        for h in dict {
            var homework = Homework()
            homework.id = "\(h["id"] ?? "Not Given")"
            homework.activity = h["activity"] as? String ?? "Not Given"
            homework.subject = h["subject"] as? String ?? "Not Given"
            homework.due_date = h["due_date"] as? String ?? "Not Given"
            homework.available_date = h["available_date"] as? String ?? "Not Given"
            homework.completed = h["completed"] as? Bool ?? false
            homework.set_by = h["set_by"] as? String ?? "Not Given"
            homework.due_text = h["due_text"] as? String ?? "Not Given"
            homework.available_text = h["available_text"] as? String ?? "Not Given"
            homework.status = h["status"] as? String ?? "Not Given"
            homework.source = h["source"] as? String ?? "Not Given"
            homework.description = h["description"] as? String ?? ""
            switch context {
            case .current: EduLinkAPI.shared.homework.current.append(homework)
            case .past: EduLinkAPI.shared.homework.past.append(homework)
            }
        }
        
        if context == .past { EduLinkAPI.shared.homework.past.reverse() }
    }
    
}

public struct Homeworks {
    public var current = [Homework]()
    public var past = [Homework]()
}

public struct Homework {
    public var id: String!
    public var activity: String!
    public var subject: String!
    public var due_date: String!
    public var available_date: String!
    public var completed: Bool!
    public var set_by: String!
    public var due_text: String!
    public var available_text: String!
    public var status: String!
    public var description: String!
    public var source: String!
}

public enum HomeworkContext {
    case current
    case past
}
