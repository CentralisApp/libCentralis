//
//  EduLink_TimeTable.swift
//  Centralis
//
//  Created by AW on 08/12/2020.
//

import Foundation

/// The model for getting timetable info
public class EduLink_Timetable {
    /// Retrieve timetable data for the currently logged in user
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func timetable(_ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : EduLinkAPI.shared.authorisedUser.id,
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken,
            "date" : "\(date())"
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Timetable", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            EduLinkAPI.shared.weeks.removeAll()
            if let weeks = self.scrapeResult(result) {
                EduLinkAPI.shared.weeks = weeks
            }
            rootCompletion(true, nil)
        })
    }
    
    public typealias botTimetableCompletion = (_ success: Bool, _ error: String?, _ weeks: [Week]?) -> ()
    class public func botTimetable(auth: String, server: String, id: String, completionHandler: @escaping botTimetableCompletion) {
        let params: [String : String] = [
            "learner_id" : id,
            "authtoken" : auth,
            "date" : "\(date())"
        ]
        NetworkManager.requestWithDict(url: server, requestMethod: "EduLink.Timetable", params: params, completion: { (success, dict) -> Void in
            if !success { return completionHandler(false, "Network Error", nil) }
            guard let result = dict["result"] as? [String : Any] else { return completionHandler(false, "Unknown Error", nil) }
            if !(result["success"] as? Bool ?? false) { return completionHandler(false, (result["error"] as? String ?? "Unknown Error"), nil) }
            completionHandler(true, nil, self.scrapeResult(result))
        })
    }
    
    class private func date() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter.string(from: Date())
    }
    
    class private func scrapeResult(_ result: [String : Any]) -> [Week]? {
        guard let weeks = result["weeks"] as? [[String : Any]] else { return nil }
        var owo = [Week]()
        for week in weeks {
            var we = Week()
            we.is_current = week["is_current"] as? Bool ?? false
            we.name = week["name"] as? String ?? "Not Given"
            guard let days = week["days"] as? [[String : Any]] else { return nil }
            for day in days {
                var de = Day()
                de.date = day["date"] as? String ?? "Not Given"
                de.isCurrent = day["is_current"] as? Bool ?? false
                de.name = day["name"] as? String ?? "Not Given"
                guard let lessons = day["lessons"] as? [[String : Any]], let periods = day["periods"] as? [[String : Any]] else {
                    return nil
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
            owo.append(we)
        }
        return owo
    }
}

/// A container for a Timetable Week
public struct Week {
    /// An array of days for that week, for more documentation see `Day`
    public var days = [Day]()
    /// If the week is the current or not
    public var is_current: Bool!
    /// The name of the week
    public var name: String!
}

/// A container for a Timetable Day
public struct Day {
    /// The date of the day
    public var date: String!
    /// If the day is the current or not
    public var isCurrent: Bool!
    /// The name of the day
    public var name: String!
    /// An array of periods for that week, for more documentation see `Period`
    public var periods = [Period]()
}

/// A container for a Timetable Lesson
public struct Lesson {
    /// The ID of the belonging period, for more documentation see `Period`
    public var period_id: String!
    /// The room for the lesson
    public var room_name: String!
    /// If the Lesson has had a room change
    public var moved: Bool!
    /// The teacher for the lesson
    public var teacher: String!
    /// The teaching group for the lesson
    public var group: String!
    /// The subject for the lesson
    public var subject: String!
}

/// A container for a Timetable Period
public struct Period {
    /// If the period is a free period
    public var empty: Bool!
    /// What time the period starts
    public var start_time: String!
    /// What time the period ends
    public var end_time: String!
    /// The ID of the period
    public var id: String!
    /// The name of the period
    public var name: String!
    /// The lesson for that period, nil if is free period. For more documentation see `Lesson`
    public var lesson: Lesson!
}
