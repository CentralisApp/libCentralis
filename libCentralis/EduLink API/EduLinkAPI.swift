//
//  EduLinkAPI.swift
//  Centralis
//
//  Created by AW on 29/11/2020.
//

import Foundation

/// The main interface for libCentralis. This will contain any data that is recieved from the API.
public class EduLinkAPI {
    /// The shared instance, which should always be used
    public static let shared = EduLinkAPI()
    
    /// The user that is currently logged in, for more documentation see `AuthorisedUser`
    public var authorisedUser = AuthorisedUser()
    /// The school the current user is apart of, for more documentation see `AuthorisedSchool`
    public var authorisedSchool = AuthorisedSchool()
    /// The contained catering, for more documentation see `Catering`
    public var catering = Catering()

    public var weeks = [Week]()

    /// Will remove all contained data. This should be called when logging out
    public func clear() {
        self.authorisedUser = AuthorisedUser()
        self.authorisedSchool = AuthorisedSchool()
        self.catering = Catering()
        self.weeks = [Week]()
    }
}
