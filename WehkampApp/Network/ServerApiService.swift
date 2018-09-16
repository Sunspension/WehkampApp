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
    
    case addItem(productNumber: String, sizeCode: String, count: Int)
    
    case search(productNumber: String)
}

extension ServerApiService {
    
    var bodyParameters: [String : Any] {
        
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
            
            var item = [String : Any]()
            item["product_number"] = productNumber
            item["size_code"] = sizeCode
            item["number_of_products"] = count
            params["items"] = [item]
            
            break
            
        default:
            break
        }
        
        return params
    }
    
    var queryParameters: [String : Any] {
        
        switch self {
            
        case .search(let productNumber):
            
            return ["productNumbers" : productNumber]
            
        default:
            return [String : Any]()
        }
    }
}

extension ServerApiService: AccessTokenAuthorizable {
    
    var authorizationType: AuthorizationType {
        
        switch self {
            
        case .login, .search:
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
            
        case .search:
            return "/service/producttiles"
        }
    }
    
    var method: Moya.Method {
        
        switch self {
            
        case .login, .addItem:
            return .post
            
        case .updateItemsCount:
            return .put
            
        case .basket, .search:
            return .get
            
        case .delete:
            return .delete
        }
    }
    
    var sampleData: Data {
        
        return Data()
    }
    
    var task: Task {
        
        switch self {
            
        default:
            
            return .requestCompositeParameters(bodyParameters: bodyParameters,
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: queryParameters )
        }
    }
    
    var headers: [String : String]? {
        
        return nil
    }
}
