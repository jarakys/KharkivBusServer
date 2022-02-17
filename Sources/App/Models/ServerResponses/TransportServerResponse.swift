//
//  File.swift
//  
//
//  Created by Kirill on 17.02.2022.
//

import Foundation

struct TransportServerResponse: Codable {
    let type, number, welcomeDescription: String
    let length: Double
    let bortNumber: Int
    let handicapped: Bool
    let gpsID: Int
    let lng, lat: Double
    let speed, timestamp, bearing, odometr: Int

    enum CodingKeys: String, CodingKey {
        case type, number
        case welcomeDescription = "description"
        case length
        case bortNumber = "bort_number"
        case handicapped
        case gpsID = "gps_id"
        case lng, lat, speed, timestamp, bearing, odometr
    }
}
