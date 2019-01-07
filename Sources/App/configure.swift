import Vapor
import FluentSQLite


/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)

    try services.register(FluentSQLiteProvider())

    var databaseConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)tooter.db"))
    databaseConfig.add(database: db, as: .sqlite)
    services.register(databaseConfig)

    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: User.self, database: .sqlite)
    migrationConfig.add(model: Token.self, database: .sqlite)
    services.register(migrationConfig)
}
