//
//  File.swift
//  
//
//  Created by Kirill on 17.02.2022.
//

import Vapor
import AsyncHTTPClient
import Foundation
import NIO
import NIOFoundationCompat

class DataController: RouteCollection {
    
    private var state: [CategoryClientResponse] = []

    private let queue = DispatchQueue(label: "com.kharkivBus.updater", attributes: .concurrent)
    
    private var data: [CategoryClientResponse] {
        set {
            queue.async(flags: .barrier) {
                self.state = newValue
            }
        }
        get {
            queue.sync {
                return state
            }
        }
    }
    
    func boot(routes: RoutesBuilder) throws {
        let data = routes.grouped("data")
        data.get("getCategories", use: getCategories)
        data.get("getRoutes", use: getRoutes)
        data.get("getTransports", use: getTransports)
        
        Jobs.add(interval: .seconds(2), action: {
            
        })
        
        Jobs.add(interval: .seconds(2)) {
            
            Task {
                let client = HTTPClient(eventLoopGroupProvider: .createNew)
                defer { try! client.syncShutdown() }
                do {
                    
                    var tramRequest = HTTPClientRequest(url: "http://194.28.84.113/tram/tram.json")
                    tramRequest.method = .GET
                    var busRequest = HTTPClientRequest(url: "http://194.28.84.113/bus/bus.json")
                    busRequest.method = .GET
                    var trolRequest = HTTPClientRequest(url: "http://194.28.84.113/troll/trol.json")
                    trolRequest.method = .GET
                    
                    let tramResponse = try await client.execute(tramRequest, timeout: .seconds(20), logger: nil)
                    let busResponse = try await client.execute(busRequest, timeout: .seconds(20), logger: nil)
                    let trolResponse = try await client.execute(trolRequest, timeout: .seconds(20), logger: nil)
                    
                    let tramBytes = try await tramResponse.body.collect(upTo: 100000)
                    let trams = try JSONDecoder().decode(KharkivServerResponse.self, from: tramBytes)
                    
                    let busBytes = try await busResponse.body.collect(upTo: 100000)
                    let buses = try JSONDecoder().decode(KharkivServerResponse.self, from: busBytes)
                    
                    let trolBytes = try await trolResponse.body.collect(upTo: 100000)
                    let trols = try JSONDecoder().decode(KharkivServerResponse.self, from: trolBytes)
                    
                    let tramTransport = trams.positions.map({ TransportClientResponse(lattitude: $0.lat, longitude: $0.lng, name: $0.bortNumber.description, id: $0.gpsID.description, routeId: $0.number, number: $0.bortNumber.description) })
                    
                    let busTransport = buses.positions.map({ TransportClientResponse(lattitude: $0.lat, longitude: $0.lng, name: $0.bortNumber.description, id: $0.gpsID.description, routeId: $0.number, number: $0.bortNumber.description) })
                    
                    let trolTransport = trols.positions.map({ TransportClientResponse(lattitude: $0.lat, longitude: $0.lng, name: $0.bortNumber.description, id: $0.gpsID.description, routeId: $0.number, number: $0.bortNumber.description) })
                    
                    let routesTramString = Set(trams.positions.map({ $0.number }))
                    let routesTram = routesTramString.map({ routeString in
                        RouteClientResponse(id: routeString, name: routeString, categoryId: "2", transports: tramTransport.filter({ item in
                        item.routeId == routeString
                    })) })
                    
                    
                    let routesBusString = Set(buses.positions.map({ $0.number }))
                    let routesBus = routesBusString.map({ routeString in
                        RouteClientResponse(id: routeString, name: routeString, categoryId: "1", transports: busTransport.filter({ item in
                        item.routeId == routeString
                    })) })
                    
                    let routesTrolString = Set(buses.positions.map({ $0.number }))
                    let routesTrol = routesTrolString.map({ routeString in
                        RouteClientResponse(id: routeString, name: routeString, categoryId: "3", transports: trolTransport.filter({ item in
                        item.routeId == routeString
                    })) })
                    
                    let tramCategory = CategoryClientResponse(type: .tram, routes: routesTram)
                    let busCategory = CategoryClientResponse(type: .bus, routes: routesBus)
                    let trolCategory = CategoryClientResponse(type: .trol, routes: routesTrol)
                    
                    self.data = [tramCategory, busCategory, trolCategory]
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getTransports(req: Request) throws -> [TransportClientResponse] {
        guard let categoryId = try? req.query.get(String.self, at: "categoryId"),
        let routeId = try? req.query.get(String.self, at: "routeId") else {
            return []
        }
        return data.first(where: { $0.categoryId == categoryId })?.routes.first(where: { $0.id == routeId })?.transports ?? []
    }
    
    func getRoutes(req: Request) throws  -> [RouteClientResponse] {
        let includeTransport = (try? req.query.get(Bool.self, at: "includeTransport")) ?? false
        guard let categoryId = try? req.query.get(String.self, at: "categoryId") else {
            return []
        }
        guard includeTransport == false else {
            return data.first(where: { $0.categoryId == categoryId })?.routes ?? []
        }
        return data.first(where: { $0.categoryId == categoryId })?.routes.map({
            RouteClientResponse(id: $0.id, name: $0.name, categoryId: $0.categoryId, transports: [])
        }) ?? []
    }
    
    func getCategories(req: Request) throws -> [CategoryClientResponse] {
        let includeTransport = (try? req.query.get(Bool.self, at: "includeTransport")) ?? false
        guard includeTransport == false else {
            return data
        }
        
        return data.map({item in
            return CategoryClientResponse(type: item.type, routes: item.routes.map({
                RouteClientResponse(id: $0.id, name: $0.name, categoryId: $0.categoryId, transports: [])
            }))
        })
    }
}
