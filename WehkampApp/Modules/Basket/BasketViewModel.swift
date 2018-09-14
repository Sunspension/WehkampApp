//
//  BasketViewModel.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let deleteItemNotification = "WADeleteItemNotification"

class BasketViewModel {
    
    private let _bag = DisposeBag()
    
    private let _api: ServerApiProtocol
    
    private let _deleteItemAction = PublishRelay<IndexPath>()
    
    var logoutAction = Observable.just(()) {
        
        didSet { setupLogoutAction()  }
    }
    
    var addItemAction = Observable.just(()) {
        
        didSet { setupAddItemAction()  }
    }
    
    var deleteItemAction: Observable<IndexPath> {
        
        return _deleteItemAction.asObservable()
    }
    
    var router: BasketRoutable?
    
    
    init(api: ServerApiProtocol) {
        
        _api = api
        setupNotificationHandler()
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
    
    private func setupNotificationHandler() {
        
        let name = Notification.Name(deleteItemNotification)
        NotificationCenter.default.rx
            .notification(name).bind { [unowned self] notification in
                
                let indexPath = notification.object as! IndexPath
                self._deleteItemAction.accept(indexPath)
        
            }.disposed(by: _bag)
    }
}
