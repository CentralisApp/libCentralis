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
    
    /// The currently logged in username
    public var username: String!
    /// The currently logged in password
    public var password: String!
    /// The currently logged in school code
    public var schoolCode: String!
    
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
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Login", params: params, completion: { (success, dict) -> Void in
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
    
    /// The method that should be used for finding school from code.
    /// - Parameters:
    ///   - schoolCode: The schoolCode currently being requested
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    public func schoolProvisioning(schoolCode: String!, _ rootCompletion: @escaping completionHandler) {
        self.schoolCode = schoolCode
        if self.schoolCode == "DemoSchool" {
            EduLinkAPI.shared.authorisedSchool.server = "https://demo.centralis.app/api/uwu"
            EduLinkAPI.shared.authorisedSchool.school_id = "1"
            self.schoolInfoz({ (success, error) -> Void in
                return rootCompletion(success, error)
            })
            return
        }
        
        let params: [String : String] = [
            "code" : self.schoolCode
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
            guard let school = result["school"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            EduLinkAPI.shared.authorisedSchool.server = school["server"] as? String
            EduLinkAPI.shared.authorisedSchool.school_id = "\(school["school_id"] ?? "Not Given")"
            self.schoolInfoz({ (success, error) -> Void in
                return rootCompletion(success, error)
            })
        })
    }
    
    private func schoolInfoz(_ zCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "establishment_id" : "2",
            "from_app" : "false"
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.SchoolDetails", params: params, completion: { (success, dict) -> Void in
            if !success { return zCompletion(false, "Network Connection Error") }
            guard let result = dict["result"] as? [String : Any] else { return zCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) { return zCompletion(false, "Unknown Error Ocurred") }
            guard let establishment = result["establishment"] as? [String : Any] else { return zCompletion(false, "Unknown Error Ocurred") }
            let imageData = establishment["logo"] as? String ?? ""
            EduLinkAPI.shared.authorisedUser.school = establishment["name"] as? String ?? "Not Given"
            if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                EduLinkAPI.shared.authorisedSchool.schoolLogo = decodedData
            }
            return zCompletion(true, nil)
        })
    }
    
    /// For attempting to login, should only be called if the school URL has already been set
    /// - Parameters:
    ///   - username: The username being used to login
    ///   - password: The password being used to login
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    public func loginz(username: String, password: String, _ rootCompletion: @escaping completionHandler) {
        self.username = username
        self.password = password
        let params: [String : String] = [
            "fcm_token_old" : "none",
            "username" : self.username,
            "password" : self.password,
            "establishment_id" : "2"
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Login", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Connection Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) {
                if (result["error"] as! String) == "The username or password is incorrect. Please try typing your password again" {
                    return rootCompletion(false, "Incorrect Username/Password")
                } else {
                    return rootCompletion(false, "Unknown Error Ocurred")
                }
            }
            EduLinkAPI.shared.authorisedUser.authToken =  result["authtoken"] as? String
            guard let user = result["user"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            EduLinkAPI.shared.authorisedUser.id = "\(user["id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.gender = user["gender"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedUser.forename = user["forename"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedUser.surname = user["surname"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedUser.community_group_id = "\(user["community_group_id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.form_group_id = "\(user["form_group_id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.year_group_id = "\(user["year_group_id"] ?? "Not Given")"
            EduLinkAPI.shared.authorisedUser.types = user["types"] as? [String] ?? [String]()
            if let avatar = user["avatar"] as? [String : Any] {
                let imageData = avatar["photo"] as? String ?? ""
                if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                    EduLinkAPI.shared.authorisedUser.avatar = decodedData
                }
            }
            self.personalMenu(result)
            self.schoolScraping(result)
            EduLink_Register.registerCodes({(success, error) -> Void in })
            return rootCompletion(true, nil)
        })
    }
    
    
    /// For logging in a user that is already saved, usually faster as schoolCode is already cached
    /// - Parameters:
    ///   - savedLogin: The user being logged in, for more documentation see `SavedLogin`
    ///   - zCompletion: The completion handler, for more documentation see `completionHandler`
    public func quickLogin(_ savedLogin: SavedLogin, _ zCompletion: @escaping completionHandler) {
        EduLinkAPI.shared.clear()
        self.schoolCode = savedLogin.schoolCode
        guard let pdata = KeyChainManager.load(key: savedLogin.username) else { return zCompletion(false, "Error loading saved login") }
        let pstr = String(decoding: pdata, as: UTF8.self)
        EduLinkAPI.shared.authorisedSchool.school_id = savedLogin.schoolID
        EduLinkAPI.shared.authorisedSchool.server = savedLogin.schoolServer
        LoginManager.shared.loginz(username: savedLogin.username, password: pstr, { (success, error) -> Void in
            return zCompletion(success, error)
        })
    }
    
    /// Save the login of the user currently signed in. Logins are saved to the UserDefault `LoginCache`
    public func saveLogin() {
        if self.schoolCode.isEmpty || self.username.isEmpty || self.password.isEmpty { return }
        guard let schoolLogo = EduLinkAPI.shared.authorisedSchool.schoolLogo else { return }
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        var l = UserDefaults.standard.object(forKey: "LoginCache") as? [Data] ?? [Data]()
        var logins = [SavedLogin]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                if a.username == self.username && a.schoolCode == self.schoolCode { return }
                logins.append(a)
            }
        }
        let a = SavedLogin(username: self.username, schoolServer: EduLinkAPI.shared.authorisedSchool.server, image: schoolLogo, schoolName: EduLinkAPI.shared.authorisedUser.school, forename: EduLinkAPI.shared.authorisedUser.forename, surname: EduLinkAPI.shared.authorisedUser.surname, schoolID: EduLinkAPI.shared.authorisedSchool.school_id, schoolCode: self.schoolCode)
        if let encoded = try? encoder.encode(a) {
            l.append(encoded)
        }
        KeyChainManager.save(key: self.username, data: Data(password.utf8))
        UserDefaults.standard.setValue(l, forKey: "LoginCache")
    }
    
    /// Remove a saved login
    /// - Parameter login: The login being removed, for more documentation see `SavedLogin`
    public func removeLogin(login: SavedLogin) {
        let decoder = JSONDecoder()
        var l = UserDefaults.standard.object(forKey: "LoginCache") as? [Data] ?? [Data]()
        var logins = [SavedLogin]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                logins.append(a)
            }
        }
        for (index, login) in logins.enumerated() where ((login.schoolCode == login.schoolCode) && (login.username == login.username)) {
            l.remove(at: index)
        }
        KeyChainManager.delete(key: login.username)
        UserDefaults.standard.setValue(l, forKey: "LoginCache")
    }

    private func personalMenu(_ dict: [String : Any]) {
        if let personal_menu = dict["personal_menu"] as? [[String : String]] {
            for menu in personal_menu {
                var personalMenu = SimpleStore()
                personalMenu.id = "\(menu["id"] ?? "Not Given")"
                personalMenu.name = menu["name"] ?? "Not Given"
                EduLinkAPI.shared.authorisedUser.personalMenus.append(personalMenu)
            }
        }
    }
    
    private func schoolScraping(_ dict: [String : Any]) {
        if let establishment = dict["establishment"] as? [String : Any] {
            //MARK: - Rooms
            if let rooms = establishment["rooms"] as? [[String : String]] {
                for room in rooms {
                    var roomMemory = Room()
                    roomMemory.id = "\(room["id"] ?? "Not Given")"
                    roomMemory.code = room["code"] ?? "Not Given"
                    roomMemory.name = room["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.rooms.append(roomMemory)
                }
            }
            
            //MARK: - Year Groups
            if let year_groups = establishment["year_groups"] as? [[String : String]] {
                for yearGroup in year_groups {
                    var yg = SimpleStore()
                    yg.id = "\(yearGroup["id"] ?? "Not Given")"
                    yg.name = yearGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.yearGroups.append(yg)
                }
            }
            
            //MARK: - Community Groups
            if let community_groups = establishment["community_groups"] as? [[String : String]] {
                for communityGroup in community_groups {
                    var cg = SimpleStore()
                    cg.id = "\(communityGroup["id"] ?? "Not Given")"
                    cg.name = communityGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.communityGroups.append(cg)
                }
            }
            
            //MARK: - Admission Groups
            if let admission_groups = establishment["applicant_admission_groups"] as? [[String : String]] {
                for admissionGroup in admission_groups {
                    var ag = SimpleStore()
                    ag.id = "\(admissionGroup["id"] ?? "Not Given")"
                    ag.name = admissionGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.admissionGroups.append(ag)
                }
            }
            
            //MARK: - Intake Groups
            if let intake_groups = establishment["applicant_intake_groups"] as? [[String : String]] {
                for intakeGroup in intake_groups {
                    var ig = SimpleStore()
                    ig.id = "\(intakeGroup["id"] ?? "Not Given")"
                    ig.name = intakeGroup["name"] ?? "Not Given"
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.intakeGroups.append(ig)
                }
            }
            
            //MARK: - Form Groups
            if let form_groups = establishment["form_groups"] as? [[String : Any]] {
                for formGroup in form_groups {
                    var fg = FormGroup()
                    fg.id = "\(formGroup["id"] ?? "Not Given")"
                    fg.employee_id = Int((formGroup["employee_id"] as? String ?? ""))
                    fg.room_id = Int((formGroup["room_id"] as? String)!)
                    fg.name = formGroup["name"] as? String
                    let ygid = formGroup["year_group_ids"] as? [String]
                    for yg in ygid! {
                        fg.year_group_ids.append(Int(yg)!)
                    }
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.formGroups.append(fg)
                }
            }
            
            //MARK: - Teaching Groups
            if let teaching_groups = establishment["teaching_groups"] as? [[String : Any]] {
                for teachingGroup in teaching_groups {
                    var tg = TeachingGroup()
                    tg.id = "\(teachingGroup["id"] ?? "Not Given")"
                    tg.employee_id = Int((teachingGroup["employee_id"] as? String ?? ""))
                    tg.name = teachingGroup["name"] as? String
                    let tgid = teachingGroup["year_group_ids"] as? [String]
                    for tgida in tgid! {
                        tg.year_group_ids.append(Int(tgida)!)
                    }
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.teachingGroups.append(tg)
                }
            }
            
            //MARK: - Subjects
            if let subjects = establishment["subjects"] as? [[String : Any]] {
                for subject in subjects {
                    var s = Subject()
                    s.id = "\(subject["id"] ?? "Not Given")"
                    s.name = subject["name"] as? String
                    s.active = subject["active"] as? Bool
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.subjects.append(s)
                }
            }
            
            //MARK: - Report Card Target Types
            if let report_card = establishment["report_card_target_types"] as? [[String : Any]] {
                for reportCard in report_card {
                    var rc = ReportCardTargetType()
                    rc.id = "\(reportCard["id"] ?? "Not Given")"
                    rc.code = reportCard["name"] as? String
                    rc.description = reportCard["description"] as? String
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.reportCardTargetTypes.append(rc)
                }
            }
        }
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
    /// Container for SchoolInfo, for more documentation see `SchoolInfo`
    public var schoolInfo = SchoolInfo()
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

/// Container for Report Card Target Type
public struct ReportCardTargetType {
    /// The ID of the report card
    public var id: String!
    /// The code belonging to the card
    public var code: String!
    /// The description of the report card
    public var description: String!
}

/// A container for info about the logged in school. All info here is stored after a succesful login.
public struct SchoolInfo {
    /// An array of classrooms at the school, for more documentation see `Room`
    public var rooms = [Room]()
    /// An array of year groups at the school, for more documentation see `SimpleStore`
    public var yearGroups = [SimpleStore]()
    /// An array of community groups at the school, for more documentation see `SimpleStore`
    public var communityGroups = [SimpleStore]()
    /// An array of admission groups at the school,  for more documentation see `SimpleStore`
    public var admissionGroups = [SimpleStore]()
    /// An array of intake groups at the school, for more documentation see `SimpleStore`
    public var intakeGroups = [SimpleStore]()
    /// An array of form groups  at the school, for more documentation see `FormGroup`
    public var formGroups = [FormGroup]()
    /// An array of teaching groups at the school, for more documentation see `TeachingGroup`
    public var teachingGroups = [TeachingGroup]()
    /// An array of subjects at the school, for more documentation see `Subject`
    public var subjects = [Subject]()
    /// An array of report card target types at the school, for more documentation see `ReportCardTargetType`
    public var reportCardTargetTypes = [ReportCardTargetType]()
    /// An array of employees at the school, for more documentation see `Employee`
    public var employees = [Employee]()
    /// An array of lesson codes at the school, for more documentation see `RegisterCode`
    public var lesson_codes = [RegisterCode]()
    /// An array of statutory codes at the school, for more documentation see `RegisterCode`
    public var statutory_codes = [RegisterCode]()
}
