//
//  WAError.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

struct ServerError: Decodable {
    
    let key: String
    
    let message: String
}

extension ServerError: CustomStringConvertible {
    
    var description: String {
        
        return "Server Error - reason: " + key + "\nmessage: " + message + "\n"
    }
}

enum WAError: Error {
    
    case serverError(error: ServerError),
    any(message: String)
}

extension WAError: LocalizedError {

    var errorDescription: String? {
        
        switch self {
            
        case .any(let message):
            return message
            
        case .serverError(let error):
            return error.message
        }
    }
}
