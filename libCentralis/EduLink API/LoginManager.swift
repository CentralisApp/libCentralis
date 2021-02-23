//
//  LoginManager.swift
//  Centralis
//
//  Created by AW on 30/11/2020.
//

import Foundation

/// The class responsible for logging in the user
public class LoginManager {
    
    /// The shared interface, should always be used
    public static let shared = LoginManager()
    
    
    public func botProvisioning(schoolCode: String, _ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "code" : schoolCode
        ]
        NetworkManager.requestWithDict(url: "https://provisioning.edulinkone.com/", requestMethod: "School.FromCode", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Connection Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) {
                if (result["error"] as! String).contains("Unknown SCHOOL ID") {
                    return rootCompletion(false, "Invalid School Code")
                } else {
                    return rootCompletion(false, "Unknown Error Ocurred")
                }
            }
            guard let school = result["school"] as? [String : Any],
                  let server = school["server"] as? String else { return rootCompletion(false, "Unknown Error Ocurred") }
            rootCompletion(true, server)
        })
    }
    
    public typealias botLoginCompletion = (_ success: Bool, _ authToken: String?, _  id: String?) -> ()
    public func botLogin(username: String, password: String, server: String, _ rootCompletion: @escaping botLoginCompletion) {
        let params: [String : String] = [
            "fcm_token_old" : "none",
            "username" : username,
            "password" : password,
            "establishment_id" : "2"
        ]
        NetworkManager.requestWithDict(url: server, requestMethod: "EduLink.Login", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Connection Error", nil) }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred", nil) }
            if !(result["success"] as? Bool ?? false) {
                if (result["error"] as! String) == "The username or password is incorrect. Please try typing your password again" {
                    return rootCompletion(false, "Incorrect Username/Password", nil)
                } else {
                    return rootCompletion(false, "Unknown Error Ocurred", nil)
                }
            }
            guard let user = result["user"] as? [String : Any],
                  let id = user["id"] as? String,
                  let auth = result["authtoken"] as? String else { return rootCompletion(false, "Unknown Error Ocurred", nil) }
            rootCompletion(true, auth, id)
        })
    }
    

    

}

/// A container for a saved login. Is saved to the UserDefault `LoginCache`
public struct SavedLogin: Codable {
    /// The saved username
    public var username: String!
    /// The saved school code
    public var schoolCode: String!
    /// The saved school server URL
    public var schoolServer: String!
    /// The saved school name
    public var schoolName: String!
    /// The saved school ID
    public var schoolID: String!
    /// The saved user profile picture
    public var image: Data!
    /// The saved user forename
    public var forename: String!
    /// The saved user surname
    public var surname: String!
    
    /// The method for creating a SavedLogin
    /// - Parameters:
    ///   - username: The username to tbe saved
    ///   - schoolServer: The school server to be saved
    ///   - image: The user profile picture to be saved
    ///   - schoolName: The school name to be saved
    ///   - forename: The user forename to be saved
    ///   - surname: The user surname to be saved
    ///   - schoolID: The school ID to be saved
    ///   - schoolCode: The school code to be saved
    init(username: String!, schoolServer: String!, image: Data!, schoolName: String!, forename: String!, surname: String!, schoolID: String!, schoolCode: String!) {
        self.username = username
        self.schoolServer = schoolServer
        self.image = image
        self.schoolName = schoolName
        self.forename = forename
        self.surname = surname
        self.schoolID = schoolID
        self.schoolCode = schoolCode
    }
}

/// Container for the user currently logged in
public struct AuthorisedUser {
    /// The authtoken, this is used for almost every network request. It will expire after a time given in `EduLink.Status`
    public var authToken: String!
    /// The users school name
    public var school: String!
    /// The users forename
    public var forename: String!
    /// The users surname
    public var surname: String!
    /// The users gender
    public var gender: String!
    /// The users learner_id
    public var id: String!
    /// The users form group ID
    public var form_group_id: String!
    /// The users year group ID
    public var year_group_id: String!
    /// The users community group ID
    public var community_group_id: String!
    /// The users profile picture
    public var avatar: Data!
    /// The type of user, will either be ```learner```, ```parent``` or ```employee```
    public var types: [String]!
    /// The menus that the user has access to, usually shown on the main page of the app
    public var personalMenus = [SimpleStore]()
}

/// Container for the school of the currently logged in user
public struct AuthorisedSchool {
    /// The server for the school. Most API requests are pointed here
    public var server: String!
    /// The school's ID
    public var school_id: String!
    /// The logo for the school
    public var schoolLogo: Data!
}

/// A container for classrooms
public struct Room {
    /// The ID of the room
    public var id: String!
    /// The name of the room
    public var name: String!
    /// The shortened room code
    public var code: String!
}

/// A container for form groups
public struct FormGroup {
    /// The ID of the group
    public var id: String!
    /// The name of the group
    public var name: String!
    /// The ID of the year group it belongs to
    public var year_group_ids = [Int]()
    /// The ID of the form tutor, for more documentation see `Employee`
    public var employee_id: Int!
    /// The ID of the form room, for more documentation see `Room`
    public var room_id: Int!
}

/// A container for teaching group, or class
public struct TeachingGroup {
    /// The ID of the group
    public var id: String!
    /// The name of the group
    public var name: String!
    /// The ID of the year group it belongs to
    public var year_group_ids = [Int]()
    /// The ID of the teacher, for more documentation see `Employee`
    public var employee_id: Int!
}

/// A container for subjects offered at the school
public struct Subject {
    /// The ID of the subject
    public var id: String!
    /// The name of the subject
    public var name: String!
    /// If the subject is actively being offered at the school
    public var active: Bool!
}

