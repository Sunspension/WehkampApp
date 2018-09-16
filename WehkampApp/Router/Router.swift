//
//  Router.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Swinject

class Router: Routable {
    
    private let _container = Container()
    
    private let _storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    
    init() {
        
        _container.register(StorageManagable.self, factory: { _ in StorageManager() })
        
        _container.register(ServerApiProtocol.self) { resolver in
            
            let storage = resolver.resolve(StorageManagable.self)!
            return ServerApi(storgeManager: storage)
        }
        
        _container.register(LoginViewController.self) { resolver in
            
            let controller = self._storyBoard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            let api = resolver.resolve(ServerApiProtocol.self)!
            let storage = resolver.resolve(StorageManagable.self)!
            let router = LoginRouter(view: controller, self)
            let viewModel = LoginViewModel(api: api, storage: storage, router: router)
            
            controller.viewModel = viewModel
            
            return controller
        }
        
        _container.register(BasketViewController.self) { resolver in
            
            let controller = BasketViewController(style: .plain)
            let storage = resolver.resolve(StorageManagable.self)!
            let router = BasketRouter(view: controller, router: self, storage: storage)
            
            let api = resolver.resolve(ServerApiProtocol.self)!
            let viewModel = BasketViewModel(api: api, router: router)
            
            controller.viewModel = viewModel
            
            return controller
        }
        
        _container.register(SearchViewController.self) { resolver in
            
            let controller = SearchViewController(style: .plain)
            let api = resolver.resolve(ServerApiProtocol.self)!
            let viewModel = SearchViewModel(api: api)
            
            controller.viewModel = viewModel
            
            return controller
        }
    }
    
    func controller(_ type: AppControllerType) -> UIViewController {
        
        switch type {
            
        case .root:
            
            let storage = _container.resolve(StorageManagable.self)!
            
            if storage.jwToken().isEmpty {
                
                let controller = _container.resolve(LoginViewController.self)!
                return UINavigationController(rootViewController: controller)
            }
            else {
                
                let controller = _container.resolve(BasketViewController.self)!
                return UINavigationController(rootViewController: controller)
            }
            
            
        case .login:
            return _container.resolve(LoginViewController.self)!
            
        case .basket:
            return _container.resolve(BasketViewController.self)!
            
        case .search:
            return _container.resolve(SearchViewController.self)!
        }
    }
}
