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
    
    case basket
    
    case updateItemsCount(id: String, count: Int)
    
    case delete(id: String)
    
    case addItem(productNumber: String, sizeCode: Int, count: Int)
}

extension ServerApiService {
    
    var parameters: [String : Any] {
        
        var params = [String : Any]()
        
        switch self {
            
        case .login(let login, let password):
            
            params["username"] = login
            params["password"] = password
            break
            
        case .updateItemsCount(_, let count):
            
            params["number_of_items"] = count
            break
            
        case .addItem(let productNumber, let sizeCode, let count):
            
            params["product_number"] = productNumber
            params["size_code"] = sizeCode
            params["number_of_products"] = count
            break
            
        default:
            break
        }
        
        return params
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
            
        case .basket:
            return "/service/basket/basket"
            
        case .updateItemsCount(let id, _):
            return "/service/basket/basket/items/\(id)"
            
        case .delete(let id):
            return "service/basket/basket/items/\(id)"
            
        case .addItem:
            return "/service/basket/basket/items"
        }
    }
    
    var method: Moya.Method {
        
        switch self {
            
        case .login, .addItem:
            return .post
            
        case .updateItemsCount:
            return .put
            
        case .basket:
            return .get
            
        case .delete:
            return .delete
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
