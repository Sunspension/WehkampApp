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
    
    private (set) var container = Container()
    
    private let _storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    
    init() {
        
        container.register(LoginViewController.self) { _ in
            
            let controller = self._storyBoard.instantiateViewController(withIdentifier: "Login")
                as! LoginViewController
            let viewModel = LoginViewModel()
            controller.viewModel = viewModel
            
            return controller
        }
    }
    
    func controller(_ type: AppControllerType) -> UIViewController {
        
        switch type {
            
        case .root:
            let controller = container.resolve(LoginViewController.self)!
            return UINavigationController(rootViewController: controller)
        }
    }
}
