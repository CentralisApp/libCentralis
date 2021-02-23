//
//  StructModels.swift
//  Centralis
//
//  Created by AW on 30/11/2020.
//

import Foundation

/// A container for the Employee dictionary returned from EduLink
public struct Employee {
    /// The Employee ID
    public var id: String!
    /// The Employee's Title
    public var title: String!
    /// The forename of the Employee
    public var forename: String!
    /// The surname of the Employee
    public var surname: String!
}

/// A simple container for lots of dictionaries returned from EduLink
public struct SimpleStore {
    /// The belonging ID
    public var id: String!
    /// The belonging Name
    public var name: String!
    
    static func generate(_ a: [[String : Any]]) -> [SimpleStore] {
        var b = [SimpleStore]()
        for c in a {
            var d = SimpleStore()
            d.id = "\(c["id"] ?? "Not Given")"
            d.name = "\(c["name"] ?? "Not Given")"
            b.append(d)
        }
        return b
    }
}
