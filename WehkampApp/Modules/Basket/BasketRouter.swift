//
//  BasketRouter.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

protocol BasketRoutable {
    
    func logout()
    
    func addItem()
    
    func showSuccess()
}

class BasketRouter {
    
    private let _router: Routable
    
    private weak var _view: UIViewController?
    
    private let _storage: StorageManagable
    
    
    init(view: UIViewController, router: Routable, storage: StorageManagable) {
        
        _view = view
        _router = router
        _storage = storage
    }
}

extension BasketRouter: BasketRoutable {
    
    func logout() {
        
        _storage.deleteToken()
        let controller = _router.controller(.login)
        _view?.navigationController?.setViewControllers([controller], animated: true)
    }
    
    func addItem() {
        
        let controller = _router.controller(.search)
        let navi = UINavigationController(rootViewController: controller)
        _view?.present(navi, animated: true, completion: nil)
    }
    
    func showSuccess() {
        
        _view?.showError(title: "Success", message: "Item was added successfully")
    }
}
