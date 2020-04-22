import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {
//    app.get { req in
//        req.view.render("index")
//    }
//
//    app.get("hello") { req -> String in
//        return "Hello, world!"
//    }

    let todoController = TodoController()
    todoController.setup(routes: app.routes, on: "todos")
//    app.post("todos", use: todoController.create)
//    app.get("todos", use: todoController.readAll)
//    app.get("todos", ":id", use: todoController.read)
//    app.post("todos", "id", use: todoController.update)
//    app.delete("todos", ":id", use: todoController.delete)
//
    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
}
