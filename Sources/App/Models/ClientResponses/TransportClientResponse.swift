//
//  File.swift
//  
//
//  Created by Kirill on 17.02.2022.
//

import Foundation
import Vapor

struct TransportClientResponse: Content, Codable {
    let lattitude: Double
    let longitude: Double
    
    let name: String
    let id: String
    let routeId: String
    let number: String
}
