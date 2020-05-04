import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {

    let todoController = TodoController()
    todoController.setup(routes: app.routes, on: "todos")

    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
}
