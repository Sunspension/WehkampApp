//
//  ServerApiService.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Moya

enum ServerApiService {
    
    case login(login: String, password: String)
}

extension ServerApiService {
    
    var parameters: [String : Any] {
        
        switch self {
            
        case .login(let login, let password):
            return ["username" : login, "password" : password]
        }
    }
}

extension ServerApiService: AccessTokenAuthorizable {
    
    var authorizationType: AuthorizationType {
        
        switch self {
            
        case .login:
            return .none
            
        default:
            return .bearer
        }
    }
}

extension ServerApiService: TargetType {
    
    var baseURL: URL {
        
        return URL(string: "https://app.wehkamp.nl")!
    }
    
    var path: String {
        
        switch self {
            
        case .login:
            return "/authentication/api"
        }
    }
    
    var method: Moya.Method {
        
        switch self {
            
        case .login:
            return .post
        }
    }
    
    var sampleData: Data {
        
        return Data()
    }
    
    var task: Task {
        
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        
        return nil
    }
}
