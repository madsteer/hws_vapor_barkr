import Routing
import Vapor
import Fluent
import FluentSQLite

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let oneDayInSeconds = Double(86400)

    router.post(User.self, at: "create") { req, user -> Future<User> in
        return User.find(user.id!, on: req).flatMap(to: User.self) { existing in
            guard existing == nil else {
                throw Abort(.badRequest)
            }

            return user.create(on: req).map(to: User.self) { user in
                return user
            }
        }
    }

    router.post("login") { req -> Future<Token> in
        // pull out the two fields we need
        let username: String = try req.content.syncGet(at: "id")
        let password: String = try req.content.syncGet(at: "password")

        // ensure they have meaningful content
        guard username.count > 0, password.count > 0 else {
            throw Abort(.badRequest)
        }

        // find the user that matched the login request
        return User.find(username, on: req).flatMap(to: Token.self) { user in
            // delete any expired tokens
            _ = Token.query(on: req).filter(\.expiry < Date()).delete()

            // if there isn't one, bail out
            guard let user = user else {
                throw Abort(.notFound)
            }

            // check the password is correct
            guard user.password == password else {
                throw Abort(.unauthorized)
            }

            // generate a new token and send it back
            let newToken = Token(id: nil, username: username, expiry: Date().addingTimeInterval(oneDayInSeconds))
            return newToken.create(on: req).map(to: Token.self) { newToken in
                return newToken
            }
        }
    }

    router.get(String.parameter, "posts") { req -> Future<[Post]> in
        let username = try req.parameters.next(String.self)
        return Post.query(on: req).filter(\Post.username == username).all()
    }

    router.get("search") { req -> Future<[Post]> in
        let query = try req.query.get(String.self, at: ["query"])
        return Post.query(on: req).filter(\.message ~~ query).all()
    }

    router.post("post") { req -> Future<Post> in
        // pull out the two fields we need
        let token: UUID = try req.content.syncGet(at: "token")
        let message: String = try req.content.syncGet(at: "message")

        // ensure we have meaningful content
        guard message.count > 0 else {
            throw Abort(.badRequest)
        }

        // use the reply ID if we have one, or default to zero
        let reply: Int = (try? req.content.syncGet(at: "reply")) ?? 0

        // find the authentication token we were given
        return Token.find(token, on: req).flatMap(to: Post.self) { token in
            // if we can't find one, bail out
            guard let token = token else {
                throw Abort(.unauthorized)
            }

            // create a new post and save it to the database
            let post = Post(id: nil, username: token.username, message: message, parent: reply, date: Date())
            try post.validate()
            return post.create(on: req).map(to: Post.self) { post in
                return post
            }
        }
    }
}
