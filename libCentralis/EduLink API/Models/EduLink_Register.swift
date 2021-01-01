//
//  Edulink_Register.swift
//  Centralis
//
//  Created by [redacted] on 18/12/2020.
//

import UIKit

public class EduLink_Register {
    class public func registerCodes(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.RegisterCodes")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.RegisterCodes\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            let c = ColourConverter()
            if let lesson_codes = result["lesson_codes"] as? [[String : Any]] {
                EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.removeAll()
                for lesson_code in lesson_codes {
                    var lc = RegisterCode()
                    lc.code = lesson_code["code"] as? String ?? "Not Given"
                    lc.active = lesson_code["active"] as? Bool ?? false
                    lc.name = lesson_code["name"] as? String ?? "Not Given"
                    lc.is_authorised_absence = lesson_code["is_authorised_absence"] as? Bool ?? false
                    lc.is_statistical = lesson_code["is_statistical"] as? Bool ?? false
                    lc.is_late = lesson_code["is_late"] as? Bool ?? false
                    lc.present = lesson_code["present"] as? Bool ?? false
                    lc.colour = c.colourFromString(lc.name)
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.append(lc)
                }
            }
            if let statutory_codes = result["statutory_codes"] as? [[String : Any]] {
                EduLinkAPI.shared.authorisedSchool.schoolInfo.statutory_codes.removeAll()
                for statuory_code in statutory_codes {
                    var st = RegisterCode()
                    st.code = statuory_code["code"] as? String ?? "Not Given"
                    st.active = statuory_code["active"] as? Bool ?? false
                    st.name = statuory_code["name"] as? String ?? "Not Given"
                    st.is_authorised_absence = statuory_code["is_authorised_absence"] as? Bool ?? false
                    st.is_statistical = statuory_code["is_statistical"] as? Bool ?? false
                    st.is_late = statuory_code["is_late"] as? Bool ?? false
                    st.present = statuory_code["present"] as? Bool ?? false
                    st.colour = c.colourFromString(st.name)
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.statutory_codes.append(st)
                }
            }
            rootCompletion(true, nil)
        })
    }
}

public struct RegisterCode {
    public var code: String!
    public var active: Bool!
    public var name: String!
    public var type: String!
    public var is_authorised_absence: Bool!
    public var is_statistical: Bool!
    public var is_late: Bool!
    public var present: Bool!
    public var colour: UIColor!
}
