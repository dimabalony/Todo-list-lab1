//
//  File.swift
//  
//
//  Created by Дмитрий Болоников on 15.05.2020.
//

import Vapor

struct AuthController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let signInRoute = routes.grouped([
            UserCredentialsAuthenticator()
        ])
        
        let loginRouter = routes.grouped([
            JWTUserAuthenticator()
        ])

        routes.post("sign-up", use: signUpHandler)
        signInRoute.post("sign-in", use: signInHandler)
        loginRouter.post("logout", use: logoutHandler)
    }
    
    func signUpHandler(_ req: Request) throws -> EventLoopFuture<User.Output> {
        try User.Input.validate(req)
        let input = try req.content.decode(User.Input.self)
        guard input.password == input.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(name: input.name, email: input.email, passwordHash: Bcrypt.hash(input.password))
        return user.save(on: req.db)
            .map { (_) -> User in user }
            .always({ (result) in
                switch result {
                case let .success(user):
                    do {
                        let payload = user.generatePayload()
                        let tokenValue = try req.jwt.sign(payload)
                        
                        req.session.id = SessionID(string: tokenValue)
                    } catch { }
                case .failure: break
                }
            })
            .map { $0.output }
    }
    
    func signInHandler(_ req: Request) throws -> EventLoopFuture<User.Output> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        
        let payload = user.generatePayload()
        let tokenValue = try req.jwt.sign(payload)
        
        req.session.id = SessionID(string: tokenValue)
        
        return req.eventLoop.makeSucceededFuture(user.output)
    }
    
    func logoutHandler(_ req: Request) -> HTTPStatus {
        req.session.destroy()
        return .ok
    }
}
