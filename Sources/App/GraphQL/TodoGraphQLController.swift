//
//  TodoGraphQLController.swift
//  
//
//  Created by Дмитрий Болоников on 19.05.2020.
//

import Vapor
import Graphiti

final class TodoGraphQLController {
    func getAllTodos(request: Request, _: NoArguments, _ notNeeded: EventLoopGroup) throws -> EventLoopFuture<[TodoGraphQL]> {
        Todo.query(on: request.db).all().map { $0.map { TodoGraphQL($0) } }
    }
}

extension TodoGraphQLController {
    struct CreateTodoArguments: Codable {
        let title: String
        let status: String
        let date: String?
    }
    
    func createTodo(request: Request, arguments: CreateTodoArguments, _ notNeeded: EventLoopGroup) throws -> EventLoopFuture<TodoGraphQL> {
        guard let user = request.auth.get(User.self), let userID = user.id else {
            throw Abort(.unauthorized)
        }
        let todo = try Todo(.init(title: arguments.title, status: arguments.status, date: arguments.date, authorID: userID))
        return todo
            .save(on: request.db)
            .map({ TodoGraphQL(todo) })
    }
}

extension TodoGraphQLController {
    struct DeleteTodoArguments: Codable {
        let id: String
    }
    
    func deleteTodo(request: Request, arguments: DeleteTodoArguments, _ notNeeded: EventLoopGroup) throws -> EventLoopFuture<Bool> {
        guard let id = UUID(uuidString: arguments.id) else { return request.eventLoop.makeFailedFuture(Abort(.badRequest)) }
        return Todo.find(id, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: request.db) }
            .transform(to: true)
    }
}

extension TodoGraphQLController {
    struct UpdateTodoArguements: Codable {
        let id: String
        let title: String
        let status: String
        let date: String?
    }
    
    func updateTodo(request: Request, arguments: UpdateTodoArguements, _ notNeeded: EventLoopGroup) throws -> EventLoopFuture<TodoGraphQL> {
        guard let id = UUID(uuidString: arguments.id) else { return request.eventLoop.makeFailedFuture(Abort(.badRequest)) }
        let input = Todo.Input(title: arguments.title, status: arguments.status, date: arguments.date, authorID: id)
        return Todo.find(id, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { todo in
                try todo.update(input)
                return todo
        }
        .flatMap { (todo: Todo) in
            return todo.save(on: request.db)
                .map { TodoGraphQL(todo) }
        }
    }
}

extension TodoGraphQLController: FieldKeyProvider {
    typealias FieldKey = FieldKeys
    
    enum FieldKeys: String {
        // Field names for the arguments
        case title // Argument to create a new todo
        case status
        case date
        case id // Argument to delete a todo
        
        // Names for the GraphQL schema endpoints
        case todos // Get all todos
        case createTodo // Create a new todo
        case deleteTodo // Delete a todo
        case updateTodo
    }
}
