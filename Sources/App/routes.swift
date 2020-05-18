import Fluent
import Vapor
import Leaf

func routes(_ app: Application) throws {

    let todoController = TodoController()
    let todo = app.routes.grouped([
        JWTUserAuthenticator(),
        User.guardMiddleware()
    ])
    todoController.setup(routes: todo, on: "todos")

    let authController = AuthController()
    try app.register(collection: authController)
    
//    let websiteController = WebsiteController()
//    try app.register(collection: websiteController)
//
}
