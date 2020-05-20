import Fluent
import Vapor
import Leaf
import FluentPostgresDriver
import JWT

extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!
    static let frontendURL = Environment.get("FRONTEND_URL")!
}

extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}

extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
}

// configures your application
public func configure(_ app: Application) throws {
    let configuration = CORSMiddleware.Configuration(
        allowedOrigin: .whitelist([Application.frontendURL]),
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin, .allow, .acceptCharset, .accessControlAllowCredentials, .accessControlAllowHeaders, .accessControlRequestHeaders],
        allowCredentials: true
    )
    let corsMiddleware = CORSMiddleware(configuration: configuration)
    app.middleware.use(corsMiddleware)
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    

    let privateKey = try String(contentsOfFile: app.directory.workingDirectory + "jwtRS256.key")
    let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))

    let publicKey = try String(contentsOfFile: app.directory.workingDirectory + "jwtRS256.key.pub")
    let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))

    app.jwt.signers.use(privateSigner, kid: .private)
    app.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
    
    app.sessions.configuration.cookieName = "accessToken"
    app.sessions.configuration.cookieFactory = { sessionID in
        var cookie = HTTPCookies.Value(string: sessionID.string)
        cookie.isHTTPOnly = true
        return cookie
    }
    app.middleware.use(app.sessions.middleware)
    
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    
    if let environmentValue = Environment.get("DATABASE_URL"), let url = URL(string: environmentValue) {
        try app.databases.use(.postgres(url: url), as: .psql)
    } else {
        try app.databases.use(.postgres(url: Application.databaseUrl), as: .psql)
    }
    
    app.migrations.add(Todo.Migration())
    app.migrations.add(Todo.AuthorMigration())
    app.migrations.add(User.Migration())
    
    // register routes
    try routes(app)
}
