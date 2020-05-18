import Fluent
import Vapor

final class Todo: APIModel {
    
    struct Input: Content {
        let title: String
        let status: Status
        let date: String?
        var authorID: UUID?
    }
    
    struct Output: Content {
        let id: String
        let title: String
        let status: Status
        let date: String?
    }
    
    static let schema = "todos"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    enum Status: String, Codable {
        case todo = "To do"
        case done = "Done"
    }
    
    @Field(key: "status")
    var status: Status
    
    @Field(key: "date")
    var date: Date?
    
    @Parent(key: "author_id")
    var author: User

    init() { }

    init(id: UUID? = nil, title: String, status: Status, date: Date, authorID: UUID) {
        self.id = id
        self.title = title
        self.status = status
        self.date = date
        self.$author.id = authorID
    }
    
    init(_ input: Input) throws {
        self.title = input.title
        self.status = input.status
        if let date = input.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.date = formatter.date(from: date)
        } else {
            self.date = nil
        }
        self.$author.id = input.authorID!
    }
    
    func update(_ input: Input) throws {
        self.title = input.title
        self.status = input.status
        if let date = input.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            self.date = formatter.date(from: date)
        } else {
            self.date = nil
        }
    }
    
    var output: Output {
        let dateFormatted: String?
        if let date = self.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            dateFormatted = formatter.string(from: date)
        } else {
            dateFormatted = nil
        }
        return .init(id: self.id!.uuidString, title: self.title, status: self.status, date: dateFormatted)
    }
}
