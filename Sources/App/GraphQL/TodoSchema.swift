//
//  TodoSchema.swift
//  
//
//  Created by Дмитрий Болоников on 19.05.2020.
//

import Graphiti
import Vapor

class TodoSchema {
    static func create() -> Schema<TodoGraphQLController, Request> {
        let type: SchemaComponent<TodoGraphQLController, Request> = Type(TodoGraphQL.self, fields: [
            Field(.id, at: \.id),
            Field(.title, at: \.title),
            Field(.status, at: \.status),
            Field(.date, at: \.date),
        ])

        let query: SchemaComponent<TodoGraphQLController, Request> = Query([
            Field(.todos, at: TodoGraphQLController.getAllTodos)
        ])
        
        let mutation: SchemaComponent<TodoGraphQLController, Request> = Mutation([
            Field(.createTodo, at: TodoGraphQLController.createTodo)
                .argument(.title, at: \.title)
                .argument(.status, at: \.status)
                .argument(.date, at: \.date),
            Field(.deleteTodo, at: TodoGraphQLController.deleteTodo)
                .argument(.id, at: \.id),
            Field(.updateTodo, at: TodoGraphQLController.updateTodo)
                .argument(.id, at: \.id)
                .argument(.title, at: \.title)
                .argument(.status, at: \.status)
                .argument(.date, at: \.date)
        ])
        
        return Schema<TodoGraphQLController, Request>([
            // Todo type with it's fields
            type,
            query,
            mutation
        ])
    }
}
