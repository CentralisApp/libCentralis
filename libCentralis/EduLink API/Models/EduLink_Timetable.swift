//
//  EduLink_TimeTable.swift
//  Centralis
//
//  Created by [redacted] on 08/12/2020.
//

import Foundation

public class EduLink_Timetable {
    class public func timetable(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Timetable")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Timetable\",\"params\":{\"date\":\"\(date())\",\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            self.scrapeResult(result)
            rootCompletion(true, nil)
        })
    }
    
    class public func date() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter.string(from: Date())
    }
    
    class public func scrapeResult(_ result: [String : Any]) {
        guard let weeks = result["weeks"] as? [[String : Any]] else { return }
        EduLinkAPI.shared.weeks.removeAll()
        for week in weeks {
            var we = Week()
            we.is_current = week["is_current"] as? Bool ?? false
            we.name = week["name"] as? String ?? "Not Given"
            guard let days = week["days"] as? [[String : Any]] else { return }
            for day in days {
                var de = Day()
                de.date = day["date"] as? String ?? "Not Given"
                de.isCurrent = day["is_current"] as? Bool ?? false
                de.name = day["name"] as? String ?? "Not Given"
                guard let lessons = day["lessons"] as? [[String : Any]], let periods = day["periods"] as? [[String : Any]] else {
                    return
                }
                
                var memLesson = [Lesson]()
                
                for lesson in lessons {
                    var l = Lesson()
                    l.period_id = "\(lesson["period_id"] ?? "Not Given")"
                    if let room = lesson["room"] as? [String : Any] {
                        l.room_name = room["name"] as? String ?? "Not Given"
                        l.moved = room["moved"] as? Bool ?? false
                    }
                    l.teacher = lesson["teachers"] as? String ?? "Not Given"
                    if let teaching_group = lesson["teaching_group"] as? [String : Any] {
                        l.group = teaching_group["name"] as? String ?? "Not Given"
                        l.subject = teaching_group["subject"] as? String ?? "Not Given"
                    }
                    memLesson.append(l)
                }
                
                for period in periods {
                    var p = Period()
                    p.empty = period["empty"] as? Bool ?? false
                    p.end_time = period["end_time"] as? String ?? "Not Given"
                    p.start_time = period["start_time"] as? String ?? "Not Given"
                    p.id = "\(period["id"] ?? "Not Given")"
                    p.name = period["name"] as? String ?? "Not Given"
                    for lesson in memLesson where lesson.period_id == p.id {
                        p.lesson = lesson
                    }
                    de.periods.append(p)
                }
                we.days.append(de)
            }
            EduLinkAPI.shared.weeks.append(we)
        }
    }
}

public struct Week {
    public var days = [Day]()
    public var is_current: Bool!
    public var name: String!
}

public struct Day {
    public var date: String!
    public var isCurrent: Bool!
    public var name: String!
    public var periods = [Period]()
}

public struct Lesson {
    public var period_id: String!
    public var room_name: String!
    public var moved: Bool!
    public var teacher: String!
    public var group: String!
    public var subject: String!
}

public struct Period {
    public var empty: Bool!
    public var start_time: String!
    public var end_time: String!
    public var id: String!
    public var name: String!
    public var lesson: Lesson!
}
