//
//  LoginRouter.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

protocol LoginRoutable {
    
    func onSuccessLogin()
    
    func onError(error: Error)
}

class LoginRouter {
    
    private var _router: Routable
    
    private weak var _view: UIViewController?
    
    
    init(view: UIViewController, _ router: Routable) {
        
        _router = router
        _view = view
    }
}

extension LoginRouter: LoginRoutable {
    
    func onSuccessLogin() {
        
        let controller = _router.controller(.products)
        _view?.navigationController?.setViewControllers([controller], animated: true)
    }
    
    func onError(error: Error) {
        
        _view?.showError(message: error.localizedDescription)
    }
}
