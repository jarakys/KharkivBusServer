//
//  File.swift
//  
//
//  Created by Kirill on 17.02.2022.
//

import Foundation
import Vapor

struct KharkivServerResponse: Content, Codable {
    let version: String
    let positions: [TransportServerResponse]
    let timestamp: Int64
}
