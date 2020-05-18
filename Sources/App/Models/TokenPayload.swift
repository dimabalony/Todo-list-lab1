//
//  TokenPayload.swift
//  
//
//  Created by Дмитрий Болоников on 15.05.2020.
//

import JWT

struct TokenPayload: JWTPayload {
    var sub: SubjectClaim
    var userID: String
    var exp: ExpirationClaim
    
    init(sub: String = "Todo List App", userID: String, exp: Date = .distantFuture) {
        self.sub = SubjectClaim(value: sub)
        self.userID = userID
        self.exp = ExpirationClaim(value: exp)
    }
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
