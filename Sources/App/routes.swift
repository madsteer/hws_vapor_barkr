import Routing
import Vapor
import FluentSQLite

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let oneDayInSeconds = Double(86400)

    router.get("hello") { req in
        return "Hello, world!"
    }

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
}
