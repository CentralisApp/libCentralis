//
//  EduLink_Attendance.swift
//  Centralis
//
//  Created by [redacted] on 19/12/2020.
//

import UIKit

public class EduLink_Attendance {
    class public func attendance(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Attendance")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Attendance\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\",\"format\":\"3\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            EduLinkAPI.shared.attendance.show_lesson = result["show_lesson"] as? Bool ?? false
            EduLinkAPI.shared.attendance.show_statutory = result["show_statutory"] as? Bool ?? false
            if let lesson = result["lesson"] as? [[String : Any]] {
                EduLinkAPI.shared.attendance.lessons.removeAll()
                for lesson in lesson {
                    var l = AttendanceLesson()
                    l.subject = lesson["subject"] as? String ?? "Not Given"
                    if let values = lesson["values"] as? [String : Any] {
                        var av = AttendanceValue()
                        av.present = values["present"] as? Int ?? 0
                        av.late = values["late"] as? Int ?? 0
                        av.unauthorised = values["unauthorised"] as? Int ?? 0
                        av.absent = values["absent"] as? Int ?? 0
                        l.values = av
                    }
                    if let exceptions = lesson["exceptions"] as? [[String : Any]] {
                        for exception in exceptions {
                            var e = AttendanceException()
                            e.date = exception["date"] as? String ?? "Not Given"
                            e.description = exception["description"] as? String ?? "Not Given"
                            e.type = exception["type"] as? String ?? "Not Given"
                            e.period = exception["period"] as? String ?? "Not Given"
                            l.exceptions.append(e)
                        }
                    }
                    EduLinkAPI.shared.attendance.lessons.append(l)
                }
            }
            if let statutory = result["statutory"] as? [[String : Any]] {
                EduLinkAPI.shared.attendance.statutory.removeAll()
                for statutory in statutory {
                    var s = AttendanceStatutory()
                    s.month = statutory["month"] as? String ?? "Not Given"
                    if let values = statutory["values"] as? [String : Any] {
                        var av = AttendanceValue()
                        av.present = values["present"] as? Int ?? 0
                        av.late = values["late"] as? Int ?? 0
                        av.unauthorised = values["unauthorised"] as? Int ?? 0
                        av.absent = values["absent"] as? Int ?? 0
                        s.values = av
                        EduLinkAPI.shared.attendance.statutoryyear.values.present += av.present
                        EduLinkAPI.shared.attendance.statutoryyear.values.absent += av.absent
                        EduLinkAPI.shared.attendance.statutoryyear.values.late += av.late
                        EduLinkAPI.shared.attendance.statutoryyear.values.unauthorised += av.unauthorised
                    }
                    if let exceptions = statutory["exceptions"] as? [[String : Any]] {
                        for exception in exceptions {
                            var e = AttendanceException()
                            e.date = exception["date"] as? String ?? "Not Given"
                            e.description = exception["description"] as? String ?? "Not Given"
                            e.type = exception["type"] as? String ?? "Not Given"
                            e.period = exception["period"] as? String ?? "Not Given"
                            s.exceptions.append(e)
                            EduLinkAPI.shared.attendance.statutoryyear.exceptions.append(e)
                        }
                    }
                    EduLinkAPI.shared.attendance.statutory.append(s)
                }
            }
            EduLinkAPI.shared.attendance.lessons = EduLinkAPI.shared.attendance.lessons.sorted(by: { $0.subject < $1.subject })
            EduLinkAPI.shared.attendance.statutory = EduLinkAPI.shared.attendance.statutory.sorted(by: { $0.month > $1.month })
            rootCompletion(true, nil)
        })
    }
}

public struct AttendanceValue {
    public var present: Int!
    public var unauthorised: Int!
    public var absent: Int!
    public var late: Int!
    
    init() {
        self.present = 0
        self.unauthorised = 0
        self.absent = 0
        self.late = 0
    }
}

public struct AttendanceColours {
    public var present: UIColor!
    public var unauthorised: UIColor!
    public var absent: UIColor!
    public var late: UIColor!
    
    public init() {
        let c = ColourConverter()
        self.present = c.colourFromString("Present")
        self.unauthorised = c.colourFromString("Unauthorised")
        self.late = c.colourFromString("Late")
        self.absent = c.colourFromString("Absent")
    }
}

public struct StatutoryYear {
    public var values = AttendanceValue()
    public var exceptions = [AttendanceException]()
}

public struct AttendanceException {
    public var date: String!
    public var description: String!
    public var type: String!
    public var period: String!
}

public struct AttendanceLesson {
    public var subject: String!
    public var values = AttendanceValue()
    public var exceptions = [AttendanceException]()
}

public struct AttendanceStatutory {
    public var month: String!
    public var values = AttendanceValue()
    public var exceptions = [AttendanceException]()
}

public struct Attendance {
    public var attendance_colours = AttendanceColours()
    public var lessons = [AttendanceLesson]()
    public var statutory = [AttendanceStatutory]()
    public var statutoryyear = StatutoryYear()
    public var show_statutory = false
    public var show_lesson = false
}
