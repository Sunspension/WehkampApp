//
//  ServerApi.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class ServerApi {
    
    private let _storage: StorageManagable
    
    private lazy var provider: MoyaProvider<ServerApiService> = {
        
        let plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true),
                                     AccessTokenPlugin(tokenClosure: self._storage.jwToken())]
        return MoyaProvider<ServerApiService>(plugins: plugins)
    }()
    
    init(storgeManager: StorageManagable) {
        
        _storage = storgeManager
    }
}

extension ServerApi: ServerApiProtocol {
    
    func authorization(login: String, password: String) -> Single<Token> {
        
        let login = ServerApiService.login(login: login, password: password)
        return provider.rx.request(login).mapResponse(Token.self)
    }
    
    func basket() -> Single<[Product]> {
        
        return provider.rx.request(.basket)
            .mapResponse([Product].self, atKeyPath: "basket_items")
    }
    
    func updateItemsCount(id: String, count: Int) -> Single<Product> {
        
        let addItem = ServerApiService.updateItemsCount(id: id, count: count)
        return provider.rx.request(addItem).mapResponse(Product.self)
    }
    
    func deleteItem(id: String) -> Single<Response> {
        
        return provider.rx.request(.delete(id: id))
    }
    
    func addItem(productNumber: String, sizeCode: Int, count: Int) -> Single<Response> {
        
        let addItem = ServerApiService.addItem(productNumber: productNumber, sizeCode: sizeCode, count: count)
        return provider.rx.request(addItem)
    }
}
