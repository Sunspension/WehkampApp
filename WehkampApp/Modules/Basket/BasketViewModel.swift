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
    
    var addItemAction = Observable.just(()) {
        
        didSet { setupAddItemAction()  }
    }
    
    var router: BasketRoutable?
    
    
    init(api: ServerApiProtocol) {
        
        _api = api
    }
    
    
    func requestBasket() -> Observable<[ProductViewModel]> {
        
        return _api.basket()
            .asObservable()
            .flatMap({ [weak self] in self?.createProductViewModels($0) ?? Observable.just([ProductViewModel]()) })
    }
    
    private func createProductViewModels(_ products: [Product]) -> Observable<[ProductViewModel]> {
        
        let viewModels = products.map { ProductViewModel(product: $0, api: _api) }
        return Observable.just(viewModels)
    }
    
    private func setupLogoutAction() {
        
        logoutAction
            .bind { [unowned self] _ in self.router?.logout() }
            .disposed(by: _bag)
    }
    
    private func setupAddItemAction() {
        
        addItemAction
            .bind { [unowned self] _ in self.router?.addItemController() }
            .disposed(by: _bag)
    }
}
