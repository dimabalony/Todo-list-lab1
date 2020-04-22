//
//  APIModel.swift
//  
//
//  Created by Дмитрий Болоников on 21.04.2020.
//

import Vapor
import FluentPostgresDriver

protocol APIModel: Model {
    associatedtype Input: Content
    associatedtype Output: Content
    
    init(_: Input) throws
    var output: Output { get }
    func update(_: Input) throws
}
