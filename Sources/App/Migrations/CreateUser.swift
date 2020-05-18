//
//  CreateUser.swift
//  
//
//  Created by Дмитрий Болоников on 15.05.2020.
//

import Fluent

extension User {
    struct Migration: Fluent.Migration {
        var name: String { "CreateUser" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users")
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password_hash", .string, .required)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("users").delete()
        }
    }
}
