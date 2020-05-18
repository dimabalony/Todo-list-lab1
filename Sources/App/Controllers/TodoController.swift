import Fluent
import Vapor

struct TodoController {
    
    let idKey = "id"
    
    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db).all()
    }

    /*
         curl -i -X POST "http:127.0.0.1:8080/todos" \
         -H "Content-Type: application/json" \
         -d '{"title": "Hello World!", "status": "To do", "date": "0-0-0"}'
     */
    func create(req: Request) throws -> EventLoopFuture<Todo.Output> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        var input = try req.content.decode(Todo.Input.self)
        input.authorID = user.id
        let todo = try Todo(input)
        return todo.save(on: req.db)
            .map { todo.output }
    }

    /*
       curl -i -X GET "http:127.0.0.1:8080/todos?page=2&per=2" \
        -H "Content-Type: application/json"
    */
    func readAll(req: Request) throws -> EventLoopFuture<[Todo.Output]> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return user.$todos.query(on: req.db)
            .all()
            .map { $0.map { $0.output } }
    }

    /*
        curl -i -X GET "http://127.0.0.1:8080/todos/<id>" \
            -H "Content-Type: application/json"
     */
    func read(req: Request) throws -> EventLoopFuture<Todo.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { $0.output }
    }

    /*
        curl -i -X POST "http://127.0.0.1:8080/todos/<id>" \
            -H "Content-Type: application/json" \
            -d '{"title": "Write Vapor 4 book"}'
     */
    func update(req: Request) throws -> EventLoopFuture<Todo.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let input = try req.content.decode(Todo.Input.self)
        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { todo in
                try todo.update(input)
                return todo
        }
        .flatMap { (todo: Todo) in
            return todo.save(on: req.db)
                .map { todo.output }
        }
    }

    /*
        curl -i -X DELETE "https:127.0.0.1:8080/todos/1819B732-400C-443B-ABF6-C3B5625CF09D"
     */
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return Todo.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
    @discardableResult
    func setup(routes: RoutesBuilder, on endpoint: String) -> RoutesBuilder {
        let base = routes.grouped(PathComponent(stringLiteral: endpoint))
        let idPathComponent = PathComponent(stringLiteral: ":\(self.idKey)")
        
        base.post(use: self.create)
        base.get(use: self.readAll)
        base.get(idPathComponent, use: self.read)
        base.put(idPathComponent, use: self.update)
        base.delete(idPathComponent, use: self.delete)
        
        return base
    }
}
