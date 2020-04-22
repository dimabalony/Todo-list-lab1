import Fluent
import Vapor
import Leaf
import FluentPostgresDriver

extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
}

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    try app.databases.use(.postgres(url: Application.databaseUrl), as: .psql)
    
//    app.databases.use(.postgres(
//        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
//        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
//        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
//    ), as: .psql)

    app.migrations.add(CreateTodo())

    // register routes
    try routes(app)
}
