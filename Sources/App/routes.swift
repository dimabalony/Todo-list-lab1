import Fluent
import Vapor
import Leaf
import GraphQLKit
import GraphiQLVapor

func routes(_ app: Application) throws {

    let todoController = TodoSocketController()
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
    
    app
        .grouped(JWTUserAuthenticator())
        .register(graphQLSchema: TodoSchema.create(), withResolver: TodoGraphQLController())
    
    if !app.environment.isRelease {
        app.enableGraphiQL()
    }
}
