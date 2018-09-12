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
        
        let plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true), AccessTokenPlugin(tokenClosure: self._storage.jwToken())]
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
}
