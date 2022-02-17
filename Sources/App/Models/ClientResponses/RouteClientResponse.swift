//
//  File.swift
//  
//
//  Created by Kirill on 17.02.2022.
//

import Foundation
import Vapor

struct RouteClientResponse: Content, Codable {
    let id: String
    let name: String
    let categoryId: String
    let transports: [TransportClientResponse]
}
