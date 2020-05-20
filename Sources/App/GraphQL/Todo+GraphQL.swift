//
//  File.swift
//  
//
//  Created by Дмитрий Болоников on 19.05.2020.
//

import Graphiti
import Vapor

extension TodoGraphQL: FieldKeyProvider {
    typealias FieldKey = FieldKeys
    
    enum FieldKeys: String {
        case id
        case title
        case status
        case date
    }
}
