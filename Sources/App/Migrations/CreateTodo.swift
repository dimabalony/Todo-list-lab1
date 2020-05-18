import Fluent

extension Todo {
    struct Migration: Fluent.Migration {
        var name: String { "CreateTodo" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("todos")
                .id()
                .field("title", .string, .required)
                .field("status", .string, .required)
                .field("date", .date)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("todos").delete()
        }
    }
    
    struct AuthorMigration: Fluent.Migration {
        var name: String { "CreateAuthor" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("todos")
                .field("author_id", .uuid, .required)
                .foreignKey("author_id", references: User.schema, .id, onDelete: .cascade, onUpdate: .noAction)
                .update()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("todos")
                .deleteField("author_id")
                .update()
        }
    }
}
