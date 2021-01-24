//
//  EduLink_Personal.swift
//  Centralis
//
//  Created by AW on 04/12/2020.
//

import Foundation

/// The model for handling Personal
public class EduLink_Personal {
    /// Retrieve the user personal info, `Personal`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
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
    
    class fileprivate func scrapeTime(_ personal: [String : Any]) {
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

/// A container for personal
public struct Personal {
    /// The ID for the user
    public var id: String!
    /// The forename for the user
    public var forename: String!
    /// The surname for the user
    public var surname: String!
    /// The gender of the user
    public var gender: String!
    /// The admission number of the user
    public var admission_number: String!
    /// The unique pupil number of the user
    public var unique_pupil_number: String!
    /// The unique learner number of the user
    public var unique_learner_number: String!
    /// The date of birth of the user
    public var date_of_birth: String!
    /// The admission date of the user
    public var admission_date: String!
    /// The email of the user
    public var email: String!
    /// The phone number registered for the user
    public var phone: String!
    /// The adress registered for the user
    public var address: String!
    /// The users form group
    public var form: String!
    /// The form room for the user
    public var room_code: String!
    /// The users form teacher
    public var form_teacher: String!
    /// The ethnicity of the user
    public var ethnicity: String!
    /// The national student ID of the user
    public var national_id: String!
    /// An array of langauges the user is fluent in
    public var languages = [String]()
    /// A personal note for the user
    public var note: String!
    /// The year the user is part of
    public var year: String!
    /// The house group of the user
    public var house_group: String!
}
