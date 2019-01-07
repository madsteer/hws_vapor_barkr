//
//  User.swift
//  App
//
//  Created by Cory Steers on 1/6/19.
//

import Foundation
import FluentSQLite
import Vapor

struct User: Content, SQLiteStringModel, Migration {
    var id: String?
    var password: String
}
