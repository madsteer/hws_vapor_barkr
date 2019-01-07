import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
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
}
