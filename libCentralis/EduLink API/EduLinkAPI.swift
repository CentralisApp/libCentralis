//
//  EduLinkAPI.swift
//  Centralis
//
//  Created by AW on 29/11/2020.
//

import UIKit

public class EduLinkAPI {
    public static let shared = EduLinkAPI()
    
    public var authorisedUser = AuthorisedUser()
    public var authorisedSchool = AuthorisedSchool()
    public var status = Status()
    public var catering = Catering()
    public var achievementBehaviourLookups = AchievementBehaviourLookup()
    public var personal = Personal()
    public var homework = Homeworks()
    public var weeks = [Week]()
    public var links = [Link]()
    public var documents = [Document]()
    public var attendance = Attendance()

    public func clear() {
        self.authorisedUser = AuthorisedUser()
        self.authorisedSchool = AuthorisedSchool()
        self.status = Status()
        self.catering = Catering()
        self.achievementBehaviourLookups = AchievementBehaviourLookup()
        self.homework = Homeworks()
        self.weeks = [Week]()
        self.links = [Link]()
        self.documents = [Document]()
        self.attendance = Attendance()
    }
}
