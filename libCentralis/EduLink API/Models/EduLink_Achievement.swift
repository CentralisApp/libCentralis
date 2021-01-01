//
//  EduLink_Achievement.swift
//  Centralis
//
//  Created by [redacted] on 03/12/2020.
//

import UIKit

public class EduLink_Achievement {
    
    class public func achievementBehaviourLookups(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.AchievementBehaviourLookups")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.AchievementBehaviourLookups\",\"params\":{\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            EduLink_Achievement.scrapeAllNeededData(result)
            rootCompletion(true, nil)
        })
    }
    
    class public func achievement(_ zCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Achievement")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Achievement\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error") }
            if let employees = result["employees"] as? [[String : Any]] {
                EduLink_Employee.handle(employees)
            }
            if let achievement = result["achievement"] as? [[String : Any]] {
                EduLinkAPI.shared.achievementBehaviourLookups.achievements.removeAll()
                for achievement in achievement {
                    var a = Achievement()
                    a.id = "\(achievement["id"] ?? "Not Given")"
                    a.type_ids = achievement["type_ids"] as? [Int] ?? [Int]()
                    a.activity_id = "\(achievement["activity_id"] ?? "Not Given")"
                    a.date = achievement["date"] as? String ?? "Not Given"
                    let recorded = achievement["recorded"] as? [String : String]
                    a.employee_id = "\(recorded?["employee_id"] ?? "Not Given")"
                    a.comments = achievement["comments"] as? String ?? "Not Given"
                    a.points = achievement["points"] as? Int ?? 0
                    a.lesson_information = achievement["lesson_information"] as? String ?? "Not Given"
                    a.live = achievement["live"] as? Bool ?? false
                    EduLinkAPI.shared.achievementBehaviourLookups.achievements.append(a)
                }
            }
            if EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.isEmpty {
                self.achievementBehaviourLookups({ (success, error) -> Void in
                    zCompletion(success, error)
                })
            } else {
                zCompletion(true, nil)
            }
        })
    }
    
    class public func behaviour(_ zCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Behaviour")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Behaviour\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\",\"format\":\"2\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error") }
            if let employees = result["employees"] as? [[String : Any]] {
                EduLink_Employee.handle(employees)
            }
            if let behaviours = result["behaviour"] as? [[String : Any]] {
                EduLinkAPI.shared.achievementBehaviourLookups.behaviours.removeAll()
                for behaviour in behaviours {
                    var b = Behaviour()
                    b.id = "\(behaviour["id"] ?? "Not Given")"
                    b.type_ids = behaviour["type_ids"] as? [Int] ?? [Int]()
                    b.activity_id = "\(behaviour["activity_id"] ?? "Not Given")"
                    b.time_id = "\(behaviour["time_id"] ?? "Not Given")"
                    b.status_id = "\(behaviour["status_id"] ?? "Not Given")"
                    b.bullying_type_id = "\(behaviour["bullying_type_id"] ?? "Not Given")"
                    b.location_id = "\(behaviour["location_id"] ?? "Not Given")"
                    let action = behaviour["action_taken"] as? [String : Any]
                    b.action_id = "\(action?["id"] ?? "Not Given")"
                    b.action_date = "\(action?["date"] ?? "Not Given")"
                    b.date = behaviour["date"] as? String ?? "Not Given"
                    let recorded = behaviour["recorded"] as? [String : String]
                    b.recorded_id = "\(recorded?["employee_id"] ?? "Not Given")"
                    b.comments = behaviour["comments"] as? String ?? "Not Given"
                    b.points = behaviour["points"] as? Int ?? 0
                    b.lesson_information = behaviour["lesson_information"] as? String ?? "Not Given"
                    EduLinkAPI.shared.achievementBehaviourLookups.behaviours.append(b)
                }
            }
            if let b4l = result["b4l"] as? [[String : Any]] {
                EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons.removeAll()
                for b4l in b4l {
                    var b = BehaviourForLesson()
                    b.subject = "\(b4l["subject"] ?? "Not Given")"
                    let values = b4l["values"] as? [String : Any] ?? [String : Any]()
                    for value in values {
                        var v = B4LValue()
                        v.name = value.key
                        v.count = value.value as? Int ?? 0
                        b.values.append(v)
                    }
                    b.values = b.values.sorted { $0.count > $1.count }
                    EduLinkAPI.shared.achievementBehaviourLookups.behaviourForLessons.append(b)
                }
            }
            if let detentions = result["detentions"] as? [[String : Any]] {
                EduLinkAPI.shared.achievementBehaviourLookups.detentions.removeAll()
                for detention in detentions {
                    var d = Detention()
                    d.attended = detention["attended"] as? String ?? ""
                    d.non_attendance_reason = detention["non_attendance_reason"] as? String ?? ""
                    d.id = "\(detention["id"] ?? "Not Given")"
                    d.description = detention["description"] as? String ?? "Not Given"
                    d.start_time = detention["start_time"] as? String ?? "Not Given"
                    d.end_time = detention["end_time"] as? String ?? "Not Given"
                    d.location = detention["location"] as? String ?? "Not Given"
                    d.date = detention["date"] as? String ?? "Not Given"
                    EduLinkAPI.shared.achievementBehaviourLookups.detentions.append(d)
                }
            }
            if EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.isEmpty {
                self.achievementBehaviourLookups({ (success, error) -> Void in
                    zCompletion(success, error)
                })
            } else {
                zCompletion(true, nil)
            }
        })
    }
    
    class public func scrapeAllNeededData(_ result: [String : Any]) {
        if let achievement_types = result["achievement_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.removeAll()
            for achievement_type in achievement_types {
                var achievementType = AchievementType()
                achievementType.id = "\(achievement_type["id"] ?? "Not Given")"
                achievementType.active = achievement_type["active"] as? Bool
                achievementType.code = achievement_type["code"] as? String
                achievementType.description = achievement_type["description"] as? String
                achievementType.position = achievement_type["position"] as? Int
                achievementType.points = achievement_type["points"] as? Int
                achievementType.system = achievement_type["system"] as? Bool
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_types.append(achievementType)
            }
        }
        
        if let achievement_activity_types = result["achievement_activity_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.achievement_activity_types.removeAll()
            for achievement_activity_type in achievement_activity_types {
                var aat = AchievementActivityType()
                aat.id = "\(achievement_activity_type["id"] ?? "Not Given")"
                aat.active = achievement_activity_type["active"] as? Bool
                aat.code = achievement_activity_type["code"] as? String
                aat.description = achievement_activity_type["description"] as? String
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_activity_types.append(aat)
            }
        }
        
        if let achievement_award_types = result["achievement_award_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.achievement_award_types.removeAll()
            for achievement_award_type in achievement_award_types {
                var aat = SimpleStore()
                aat.id = "\(achievement_award_type["id"] ?? "Not Given")"
                aat.name = achievement_award_type["name"] as? String
                EduLinkAPI.shared.achievementBehaviourLookups.achievement_award_types.append(aat)
            }
        }
        
        if let behaviour_types = result["behaviour_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.removeAll()
            for behaviour_type in behaviour_types {
                var bt = BehaviourType()
                bt.id = "\(behaviour_type["id"] ?? "Not Given")"
                bt.active = behaviour_type["active"] as? Bool
                bt.code = behaviour_type["code"] as? String
                bt.description = behaviour_type["description"] as? String
                bt.position = behaviour_type["position"] as? Int
                bt.points = behaviour_type["points"] as? Int
                bt.system = behaviour_type["system"] as? Bool
                bt.include_in_register = behaviour_type["include_in_register"] as? Bool
                bt.is_bullying_type = behaviour_type["is_bullying_type"] as? Bool
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_types.append(bt)
            }
        }
        
        if let behaviour_activity_types = result["behaviour_activity_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_activity_types.removeAll()
            for behaviour_activity_type in behaviour_activity_types {
                var bat = BehaviourActivityType()
                bat.id = "\(behaviour_activity_type["id"] ?? "Not Given")"
                bat.description = "\(behaviour_activity_type["description"] ?? "Not Given")"
                bat.code = "\(behaviour_activity_type["code"] ?? "Not Given")"
                bat.active = behaviour_activity_type["active"] as? Bool ?? false
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_activity_types.append(bat)
            }
        }
        
        if let behaviour_actions_taken = result["behaviour_actions_taken"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_actions_taken.removeAll()
            for behaviour_actions_taken in behaviour_actions_taken {
                var bat = SimpleStore()
                bat.id = "\(behaviour_actions_taken["id"] ?? "Not Given")"
                bat.name = "\(behaviour_actions_taken["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_actions_taken.append(bat)
            }
        }
        
        if let behaviour_bullying_types = result["behaviour_bullying_types"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_bullying_types.removeAll()
            for behaviour_bullying_type in behaviour_bullying_types {
                var bbt = SimpleStore()
                bbt.id = "\(behaviour_bullying_type["id"] ?? "Not Given")"
                bbt.name = "\(behaviour_bullying_type["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_bullying_types.append(bbt)
            }
        }
        
        if let behaviour_locations = result["behaviour_locations"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_locations.removeAll()
            for behaviour_location in behaviour_locations {
                var bl = SimpleStore()
                bl.id = "\(behaviour_location["id"] ?? "Not Given")"
                bl.name = "\(behaviour_location["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_locations.append(bl)
            }
        }
        
        if let behaviour_statuses = result["behaviour_statuses"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_statuses.removeAll()
            for behaviour_status in behaviour_statuses {
                var bs = SimpleStore()
                bs.id = "\(behaviour_status["id"] ?? "Not Given")"
                bs.name = "\(behaviour_status["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_statuses.append(bs)
            }
        }
        
        if let behaviour_times = result["behaviour_times"] as? [[String : Any]] {
            EduLinkAPI.shared.achievementBehaviourLookups.behaviour_times.removeAll()
            for behaviour_time in behaviour_times {
                var bt = SimpleStore()
                bt.id = "\(behaviour_time["id"] ?? "Not Given")"
                bt.name = "\(behaviour_time["name"] ?? "Not Given")"
                EduLinkAPI.shared.achievementBehaviourLookups.behaviour_times.append(bt)
            }
        }
    }
}


public struct Detention {
    public var attended: String!
    public var non_attendance_reason: String!
    public var id: String!
    public var description: String!
    public var start_time: String!
    public var end_time: String!
    public var location: String!
    public var date: String!
}

public struct B4LValue {
    public var name: String!
    public var count: Int!
}

public struct BehaviourForLesson {
    public var subject: String!
    public var values = [B4LValue]()
}

public struct Achievement {
    public var id: String!
    public var type_ids: [Int]!
    public var activity_id: String!
    public var date: String!
    public var employee_id: String!
    public var comments: String!
    public var points: Int!
    public var lesson_information: String!
    public var live: Bool!
}

public struct Behaviour {
    public var id: String!
    public var type_ids: [Int]!
    public var activity_id: String!
    public var date: String!
    public var time_id: String!
    public var status_id: String!
    public var bullying_type_id: String!
    public var location_id: String!
    public var action_id: String!
    public var action_date: String!
    public var recorded_id: String!
    public var lesson_information: String!
    public var comments: String!
    public var points: Int!
}

public struct AchievementType {
    public var id: String!
    public var active: Bool!
    public var code: String!
    public var description: String!
    public var position: Int!
    public var points: Int!
    public var system: Bool!
}

public struct AchievementActivityType {
    public var id: String!
    public var code: String!
    public var description: String!
    public var active: Bool!
}

public struct BehaviourType {
    public var id: String!
    public var active: Bool!
    public var code: String!
    public var description: String!
    public var position: Int!
    public var points: Int!
    public var system: Bool!
    public var include_in_register: Bool!
    public var is_bullying_type: Bool!
}

public struct BehaviourActivityType {
    public var id: String!
    public var code: String!
    public var description: String!
    public var active: Bool!
}

public struct AchievementBehaviourLookup {
    public var achievements = [Achievement]()
    public var behaviours = [Behaviour]()
    public var behaviourForLessons = [BehaviourForLesson]()
    public var detentions = [Detention]()
    
    public var achievement_types = [AchievementType]()
    public var achievement_activity_types = [AchievementActivityType]()
    public var achievement_award_types = [SimpleStore]()
    
    public var achievement_points_editable: Bool!
    public var detentionmanagement_enabled: Bool!
    
    public var behaviour_types = [BehaviourType]()
    public var behaviour_activity_types = [BehaviourActivityType]()
    public var behaviour_actions_taken = [SimpleStore]()
    public var behaviour_bullying_types = [SimpleStore]()
    public var behaviour_locations = [SimpleStore]()
    public var behaviour_statuses = [SimpleStore]()
    public var behaviour_times = [SimpleStore]()
}

