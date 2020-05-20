//
//  TodoSocketController.swift
//  
//
//  Created by Дмитрий Болоников on 19.05.2020.
//

import Vapor

struct TodoSocketController {
        
    struct Action: Codable {
        let type: ActionType
        let json: String
        let id: UUID?
        
        var data: Data? {
            json.data(using: .utf8)
        }
    }
    
    enum ActionType: String, Codable {
        case post
        case delete
        case put
        case get
    }
    
    @discardableResult
    func setup(routes: RoutesBuilder, on endpoint: String) -> RoutesBuilder {
        routes.webSocket(PathComponent(stringLiteral: endpoint)) { (request, ws) in
            guard let user = request.auth.get(User.self) else { return }
            
            ws.onText { (ws, text) in
                guard let data = text.data(using: .utf8) else { return }
                let action: Action
                do {
                    action = try JSONDecoder().decode(Action.self, from: data)
                } catch {
                    print(error)
                    return
                }
                
                switch action.type {
                case .post: self.postHandler(request: request, webSocket: ws, action: action, user: user)
                case .delete: self.deleteHandler(request: request, webSocket: ws, action: action, user: user)
                case .put: self.putHandler(request: request, webSocket: ws, action: action, user: user)
                case .get: self.sendTodos(request: request, webSocket: ws, user: user)
                }
            }
        
            self.sendTodos(request: request, webSocket: ws, user: user)
        }

        return routes
    }
    
    func postHandler(request: Request, webSocket: WebSocket, action: Action, user: User) {
        do {
            guard let data = action.data else { return }
            var input = try JSONDecoder().decode(Todo.Input.self, from: data)
            input.authorID = user.id
            let todo = try Todo(input)
            let _ = todo.save(on: request.db)
                .flatMap({ _ in Todo.query(on: request.db).all() })
                .always { (result) in
                    let encoder = JSONEncoder()
                    guard let output = try? encoder.encode(todo.output),
                        let json = String(data: output, encoding: .utf8) else { return }
                    let action = Action(type: .post, json: json, id: nil)
                    guard let data = try? encoder.encode(action),
                        let jsonAction = String(data: data, encoding: .utf8) else { return }
                    webSocket.send(jsonAction)
            }
        } catch {
            print(error)
            return
        }
    }
    
    func deleteHandler(request: Request, webSocket: WebSocket, action: Action, user: User) {
        guard let id = action.id else { return }
        let _ = Todo.find(id, on: request.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: request.db) }
            .always { (_) in
                let encoder = JSONEncoder()
                let action = Action(type: .delete, json: "", id: id)
                guard let data = try? encoder.encode(action),
                    let jsonAction = String(data: data, encoding: .utf8) else { return }
                webSocket.send(jsonAction)
        }
    }
    
    func putHandler(request: Request, webSocket: WebSocket, action: Action, user: User) {
        do {
            guard let data = action.data, let id = action.id else { return }
            let input = try JSONDecoder().decode(Todo.Input.self, from: data)
            let _ = Todo.find(id, on: request.db)
                .unwrap(or: Abort(.notFound))
                .flatMapThrowing { (todo) in
                    try todo.update(input)
                    return todo
            }
            .flatMap { (todo: Todo) in
                return todo.save(on: request.db)
                    .map { todo.output }
            }.always { (result) in
                guard case let(.success(todo)) = result else { return }
                let encoder = JSONEncoder()
                guard let output = try? encoder.encode(todo),
                    let json = String(data: output, encoding: .utf8) else { return }
                let action = Action(type: .put, json: json, id: id)
                guard let data = try? encoder.encode(action),
                    let jsonAction = String(data: data, encoding: .utf8) else { return }
                webSocket.send(jsonAction)
            }
        } catch {
            print(error)
            return
        }
    }
    
    func sendTodos(request: Request, webSocket: WebSocket, user: User) {
        let _ = user.$todos.query(on: request.db)
            .all()
            .map { $0.map { $0.output } }
            .always { (result) in
                let encoder = JSONEncoder()
                guard case let (.success(todos)) = result,
                    let output = try? encoder.encode(todos),
                    let jsonString = String(data: output, encoding: .utf8) else { return }
                let action = Action(type: .get, json: jsonString, id: nil)
                guard let data = try? encoder.encode(action),
                    let jsonAction = String(data: data, encoding: .utf8) else { return }
                webSocket.send(jsonAction)
        }
    }
}
