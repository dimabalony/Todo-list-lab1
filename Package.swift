// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "lab1",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0-rc"),
        
        // 🌐 GraphQL
        .package(name: "GraphQLKit", url: "https://github.com/maximkrouk/graphql-kit.git", .branch("improvements")), // Vapor Utilities
        .package(name: "GraphiQLVapor", url: "https://github.com/alexsteinerde/graphiql-vapor.git", from: "2.0.0-beta.1") // Web Query Page
        
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Leaf", package: "leaf"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "JWT", package: "jwt"),
            .byName(name: "GraphQLKit"),
            .byName(name: "GraphiQLVapor")
//            .product(name: "GraphQL", package: "GraphQLKit"),
//            .product(name: "GraphiQLVapor", package: "GraphiQLVapor"),
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
