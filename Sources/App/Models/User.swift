//
//  User.swift
//  
//
//  Created by Дмитрий Болоников on 14.05.2020.
//

import Fluent
import Vapor

final class User: APIModel {
    
    struct Input: Content {
        let name: String
        let email: String
        let password: String
        let confirmPassword: String
    }
    
    struct Output: Content {
        let id: String
        let name: String
        let email: String
    }
    
    static var schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Children(for: \.$author)
    var todos: [Todo]
    
    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
    
    init(_ input: Input) throws {
        self.name = input.name
        self.email = input.email
        self.passwordHash = input.password
    }
    
    var output: Output {
        .init(id: self.id!.uuidString, name: self.name, email: self.email)
    }
    
    func update(_ input: Input) throws {
        self.name = input.name
        self.email = input.email
        self.passwordHash = input.password
    }
}

extension User.Input: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User {
    func generatePayload() -> TokenPayload {
        
        return TokenPayload(userID: id!.uuidString)
    }
}
