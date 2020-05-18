//
//  JWTUserAuthenticator.swift
//  
//
//  Created by Дмитрий Болоников on 16.05.2020.
//

import Vapor


struct JWTUserAuthenticator: RequestAuthenticator {
    func authenticate(request: Request) -> EventLoopFuture<Void> {
        do {
            guard let cookie = request.session.id else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
            let jwt = try request.jwt.verify(cookie.string, as: TokenPayload.self)
            return User.find(UUID(uuidString: jwt.userID), on: request.db)
                .map { (user) in
                    if let user = user {
                        request.auth.login(user)
                    }
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
