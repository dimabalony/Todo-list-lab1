//
//  File.swift
//  
//
//  Created by Дмитрий Болоников on 20.05.2020.
//

import Vapor

struct TodoGraphQL: Content {
    var id: String?
    var title: String
    var status: String
    var date: String?
    
    init(id: String, title: String, status: String, date: String) {
        self.id = id
        self.title = title
        self.status = status
        self.date = date
    }
    
    init(_ todo: Todo) {
        self.id = todo.id?.uuidString
        self.title = todo.title
        self.status = todo.status.rawValue
        if let date = todo.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.date = formatter.string(from: date)
        } else {
            self.date = nil
        }
    }
}
