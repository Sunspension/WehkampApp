//
//  BasketViewModel.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift

class BasketViewModel {
    
    private let _bag = DisposeBag()
    
    private let _api: ServerApiProtocol
    
    var logoutAction = Observable.just(()) {
        
        didSet { setupLogoutAction()  }
    }
    
    var router: BasketRoutable?
    
    
    init(api: ServerApiProtocol) {
        
        _api = api
    }
    
    
    func requestBasket() -> Observable<[Product]> {
        
        return _api.basket().asObservable()
    }
    
    private func setupLogoutAction() {
        
        logoutAction
            .bind { [unowned self] _ in self.router?.logout() }
            .disposed(by: _bag)
    }
}
