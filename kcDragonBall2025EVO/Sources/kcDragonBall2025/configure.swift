import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    //app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    app.databases.use(.sqlite(.file("db2.sqlite")), as: .sqlite)
    

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
