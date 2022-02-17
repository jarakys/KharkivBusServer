//
//  File.swift
//  
//
//  Created by Kirill on 17.02.2022.
//

import Foundation
import Vapor

enum CategoryType: Codable {
    case bus
    case tram
    case trol
    
    var name: String {
        switch self {
        case .bus:
            return "Автобусы"
        case .tram:
            return "Трамваи"
        case .trol:
            return "Тролейбусы"
        }
    }
    
    var id: String {
        switch self {
        case .bus:
            return "1"
        case .tram:
            return "2"
        case .trol:
            return "3"
        }
    }
}

struct CategoryClientResponse: Content, Codable {
    let type: CategoryType
    let routes: [RouteClientResponse]
    var categoryName: String {
        type.name
    }
    var categoryId: String {
        type.id
    }
}
