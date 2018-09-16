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

class BasketViewModel {
    
    private let _bag = DisposeBag()
    
    private let _api: ServerApiProtocol
    
    private let _router: BasketRoutable
    
    private let _deleteItem = PublishRelay<ProductViewModel>()
    
    private let _products = PublishRelay<[ProductViewModel]>()
    
    private let _busy = PublishRelay<Bool>()
    
    var products: Observable<[ProductViewModel]> {
        
        return _products.asObservable()
    }
    
    var deleteItem: Observable<ProductViewModel> {
        
        return _deleteItem.asObservable()
    }
    
    var busy: Observable<Bool> {
        
        return _busy.asObservable()
    }
    
    init(api: ServerApiProtocol, router: BasketRoutable) {
        
        _api = api
        _router = router
        setupNotificationHandler()
    }
    
    func onViewDidLoad() {
        
        _busy.accept(true)
    }
    
    func requestBasket() {
        
        _api.basket().asObservable()
            .catchError({ error in debugPrint(error); return Observable.just([Product]()) })
            .flatMap({ [weak self] in self?.createProductViewModels($0) ?? Observable.just([ProductViewModel]()) })
            .subscribe(onNext: { [weak self] in
                
                self?._busy.accept(false)
                self?._products.accept($0) }, onError: { [weak self] in
                        
                        self?._busy.accept(false)
                        debugPrint($0)
            
            }).disposed(by: _bag)
    }
    
    func logout() {
        
        _router.logout()
    }
    
    func addItem() {
        
        _router.addItem()
    }
    
    private func createProductViewModels(_ products: [Product]) -> Observable<[ProductViewModel]> {
        
        let viewModels = products.map { ProductViewModel(product: $0, api: _api) }
        return Observable.just(viewModels)
    }
    
    private func setupNotificationHandler() {
        
        let delete = Notification.Name(Constants.Notifications.deleteItemNotification)
        NotificationCenter.default.rx
            .notification(delete)
            .bind { [unowned self] notification in
                
                let viewModel = notification.object as! ProductViewModel
                self._deleteItem.accept(viewModel)
        
            }.disposed(by: _bag)
        
        let update = Notification.Name(Constants.Notifications.itemWasAddedToBasketNotification)
        NotificationCenter.default.rx
            .notification(update)
            .bind { [unowned self] _ in self.requestBasket() }
            .disposed(by: _bag)
    }
}
