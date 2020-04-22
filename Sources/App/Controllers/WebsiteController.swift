//
//  WebsiteController.swift
//  
//
//  Created by Дмитрий Болоников on 21.04.2020.
//

import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get(":id", use: todoHandler)
        routes.post(use: appendTodoHandler)
        routes.post(":id", "delete", use: deleteTodoHandler)
        routes.post(":id", "update", use: updateTodoHandler)
    }
    
    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        struct Context: Codable {
            let index: Index
            let home: Home
        }
        
        return Todo.query(on: req.db).all().flatMap { (todos) in
            let todosOutput = todos.map { $0.output }
            let context = Context(index: .init(title: "TODO LIST", description: "Page with your TODOS"),
                                  home: .init(todos: todosOutput))
            return req.view.render("home", context)
        }
    }
    
    func todoHandler(_ req: Request) throws -> EventLoopFuture<View> {
        struct Context: Codable {
            let index: Index
            let todo: Todo.Output
        }
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (todo) in
                let context = Context(index: .init(title: "TODO", description: "Page with your TODO"), todo: todo.output)
                
                return req.view.render("todo", context)
        }
    }
    
    func appendTodoHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let request = try req.content.decode(Todo.Input.self)
        let model = try Todo(request)

        return model.save(on: req.db)
            .transform(to: req.redirect(to: "/"))
    }
    
    func deleteTodoHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: req.redirect(to: "/"))
    }
    
    func updateTodoHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let input = try req.content.decode(Todo.Input.self)
        
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing({ (todo) -> EventLoopFuture<Void> in
                try todo.update(input)
                return todo.save(on: req.db)
            })
            .transform(to: req.redirect(to: "/\(id)"))
    }
    
    struct Index: Codable {
        let title: String
        let description: String
    }
    
    struct Home: Codable {
        let todos: [Todo.Output]
    }
}
