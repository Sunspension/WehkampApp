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
            let viewModel = LoginViewModel(api: api, storage: storage)
            viewModel.router = LoginRouter(view: controller, self)
            controller.viewModel = viewModel
            
            return controller
        }
    }
    
    func controller(_ type: AppControllerType) -> UIViewController {
        
        switch type {
            
        case .root:
            let controller = _container.resolve(LoginViewController.self)!
            return UINavigationController(rootViewController: controller)
            
        case .products:
            return UIViewController()
        }
    }
}
