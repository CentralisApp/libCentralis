//
//  EduLink_Personal.swift
//  Centralis
//
//  Created by AW on 04/12/2020.
//

import Foundation

public class EduLink_Personal {
    
    class public func personal(_ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : EduLinkAPI.shared.authorisedUser.id,
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Personal", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            if let personal = result["personal"] as? [String : Any] {
                self.scrapeTime(personal)
            }
            rootCompletion(true, nil)
        })
    }
    
    class public func scrapeTime(_ personal: [String : Any]) {
        EduLinkAPI.shared.personal.id = "\(personal["id"] ?? "Not Given")"
        EduLinkAPI.shared.personal.forename = personal["forename"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.surname = personal["surname"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.gender = personal["gender"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.admission_number = "\(personal["admission_number"] ?? "Not Given")"
        EduLinkAPI.shared.personal.unique_pupil_number = personal["unique_pupil_number"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.unique_learner_number = "\(personal["unique_learner_number"] ?? "Not Given")"
        EduLinkAPI.shared.personal.date_of_birth = personal["date_of_birth"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.admission_date = personal["admission_date"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.email = personal["email"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.phone = personal["phone"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.address = personal["address"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.ethnicity = personal["ethnicity"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.national_id = personal["national_identity"] as? String ?? "Not Given"
        EduLinkAPI.shared.personal.languages.removeAll()
        if let languages = personal["languages"] as? [String: String] {
            for language in languages.values {
                EduLinkAPI.shared.personal.languages.append(language)
            }
        } else {
            EduLinkAPI.shared.personal.languages.append("Not Given")
        }
        
        if let form_group = personal["form_group"] as? [String : Any] {
            EduLinkAPI.shared.personal.form = form_group["name"] as? String ?? "Not Given"
            if let room = form_group["room"] as? [String : String] {
                EduLinkAPI.shared.personal.room_code = room["code"] ?? "Not Given"
            }
            if let employee = form_group["employee"] as? [String : String] {
                EduLinkAPI.shared.personal.form_teacher = "\(employee["title"] ?? "Not Given") \(employee["forename"] ?? "Not Given") \(employee["surname"] ?? "Not Given")"
            }
        }
        EduLinkAPI.shared.personal.year = (personal["year_group"] as? [String : String] ?? [String : String]())["name"] ?? "Not Given"
        EduLinkAPI.shared.personal.house_group = (personal["house_group"] as? [String : String] ?? [String : String]())["name"] ?? "Not Given"
    }
    
}

public struct Personal {
    public var id: String!
    public var forename: String!
    public var surname: String!
    public var gender: String!
    public var admission_number: String!
    public var unique_pupil_number: String!
    public var unique_learner_number: String!
    public var date_of_birth: String!
    public var admission_date: String!
    public var email: String!
    public var phone: String!
    public var address: String!
    public var form: String!
    public var room_code: String!
    public var form_teacher: String!
    public var ethnicity: String!
    public var national_id: String!
    public var languages = [String]()
    public var note: String!
    public var year: String!
    public var house_group: String!
}
