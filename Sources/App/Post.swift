//
//  Post.swift
//  App
//
//  Created by Cory Steers on 1/6/19.
//

import Foundation
import FluentSQLite
import Validation
import Vapor
import Validation

extension Post: Validatable {
    static func validations() throws -> Validations<Post> {
        var validations = Validations(Post.self)
        try validations.add(\.username, .count(1...) && .alphanumeric)
        try validations.add(\.message, .count(2...))
        try validations.add(\.parent, .range(0...))
        return validations
    }
}

struct Post: Content, SQLiteModel, Migration {
    var id: Int?
    var username: String
    var message: String
    var parent: Int
    var date: Date
}
