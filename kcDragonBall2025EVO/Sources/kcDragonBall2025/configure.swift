import NIOSSL
import Fluent
//import FluentSQLiteDriver
import FluentPostgresDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    //app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    //app.databases.use(.sqlite(.file("db2.sqlite")), as: .sqlite)
   
    //Control environment vars
    var host = Environment.get("DATABASE_HOST") ?? ""
    
    if host == "" {
        NSLog("🔴📂 Environment file not found❗")
        throw Abort(.notFound)
    }
    
    
   
    //PostgreSQL
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ??  5432,
        username: Environment.get("DATABASE_USERNAME") ?? "",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "",
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .psql)
    
    

    app.migrations.add(Bootcamps_v1())
    app.migrations.add(Developers_v1())
    app.migrations.add(CreateUsersApp_v1())
    app.migrations.add(Heros_v1())
    app.migrations.add(HerosLocations_v1())
    app.migrations.add(DevelopersHeros_v1())
    app.migrations.add(HerosTransformations_v1())

    
    app.migrations.add(Create_Data_v1())
    app.migrations.add(Create_Data_Heros_v1()) 
    
    app.passwords.use(.bcrypt)
    let keyJwt = "973624HGJ23K4H87213YHGE71283GE123"
    app.jwt.signers.use(.hs256(key: keyJwt))
    
    try await app.autoMigrate()
    
    
    // register routes
    try routes(app)
}
