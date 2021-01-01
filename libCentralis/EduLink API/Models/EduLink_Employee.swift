//
//  EduLink_Employee.swift
//  Centralis
//
//  Created by [redacted] on 03/12/2020.
//

import Foundation

public class EduLink_Employee {
    class public func handle(_ employees: [[String : Any]]) {
        for employee in employees {
            var a = Employee()
            a.id = "\(employee["id"] ?? "Not Given")"
            let isFound = EduLinkAPI.shared.authorisedSchool.schoolInfo.employees.contains(where: {$0.id == a.id} )
            if isFound { return }
            a.forename = employee["forename"] as? String ?? "Not Given"
            a.title = employee["title"] as? String ?? "Not Given"
            a.surname = employee["surname"] as? String ?? "Not Given"
            EduLinkAPI.shared.authorisedSchool.schoolInfo.employees.append(a)
        }
    }
}
