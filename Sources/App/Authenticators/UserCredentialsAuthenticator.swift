//
//  UserCredentialsAuthenticator.swift
//  
//
//  Created by Дмитрий Болоников on 15.05.2020.
//

import Vapor

struct UserCredentialsAuthenticator: CredentialsAuthenticator {
    
    struct Credentials: Content {
        let email: String
        let password: String
    }
    
    func authenticate(credentials: Credentials, for request: Request) -> EventLoopFuture<Void> {
        User.query(on: request.db)
            .filter(\.$email, .equal, credentials.email)
            .first()
            .map {
                do {
                    if let user = $0, try user.verify(password: credentials.password) {
                        request.auth.login(user)
                    }
                }
                catch {
                    
                }
        }
    }
}
