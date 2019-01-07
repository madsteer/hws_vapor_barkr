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

struct Post: Content, SQLiteModel, Migration {
    var id: Int?
    var username: String
    var message: String
    var parent: Int
    var date: Date
}
