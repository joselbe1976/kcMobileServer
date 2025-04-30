//
//  File.swift
//
//
//  Created by JOSE LUIS BUSTOS ESTEBAN on 9/5/21.
//
import Fluent
import Vapor
import JWT


struct DevelopersController : RouteCollection {
    func boot(routes: any RoutesBuilder) throws {

        let tokenAppjwt = routes.grouped("api","data")
        tokenAppjwt.get("developers", use: Developers)
        tokenAppjwt.post("herolike", use: developerLike)
        tokenAppjwt.get("connected", use: DeveloperConnected)
        

    }
    
    
    @Sendable
    func DeveloperConnected(_ req:Request) async throws -> Developers {
        let payload = try req.jwt.verify(as: PayloadApp.self)
  
        let idDeveloper =  payload.identify;
        
        return try await kcDragonBall2025.Developers
            .query(on: req.db)
            .filter(\.$id == idDeveloper)//filtro por Id developer
            .with(\.$bootcamp) //sacamos en el JSON los bootcamp
            .with(\.$heros)
            .first()
            .unwrap(or: Abort(.notFound))
            .get()
    }
    
    
    
    @Sendable
    func Developers(_ req:Request) async throws -> [Developers] {
        let _ = try req.jwt.verify(as: PayloadApp.self)
  
        return try await kcDragonBall2025.Developers
            .query(on: req.db)
            .with(\.$bootcamp)
            .with(\.$heros)
            .all()
            .get()
    }

    
    @Sendable
    func developerLike(_ req:Request) async throws -> HTTPStatus{
        let payload = try req.jwt.verify(as: PayloadApp.self)

        let requestDeveloper = try req.content.decode(DeveloperLike.self)
        let idHero = requestDeveloper.hero
        let idDeveloper =  payload.identify;

        return try await Heros
            .find(idHero, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ hero in
                
                return kcDragonBall2025.Developers
                    .find(idDeveloper, on: req.db)
                    .unwrap(or: Abort(.notFound))
                    .flatMap{ developer in
                        
                        return DevelopersHeros.query(on: req.db)
                           .group(.and){ group in
                               group
                                .filter(\.$developer.$id == idDeveloper)
                                .filter(\.$hero.$id == idHero)
                           }
                           .first()
                           .flatMap{ exist in
                               if exist == nil {
                                   return developer
                                       .$heros
                                       .attach(hero, on: req.db)
                                       .transform(to: .created)
                               } else {
                                //Desempaqueto
                                if let data = exist {
                                    // ya existe lo quito de la tabla
                                    return data
                                        .delete(on: req.db)
                                        .transform(to: .created)
                                }
                                else{
                                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                                }
                                
                               }
                           }
                    }
            }
            .get()
    }
    
}


