//
//  SearchViewModel.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 15/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import RxCocoa

class SearchViewModel {
    
    private let _bag = DisposeBag()
    
    private let _api: ServerApiProtocol
    
    private let _onSuccess = PublishRelay<Void>()
    
    private let _onError = PublishRelay<Error>()
    
    var onSuccess: Observable<Void> {
        
        return _onSuccess.asObservable()
    }
    
    var onError: Observable<Error> {
        
        return _onError.asObservable()
    }
    
    init(api: ServerApiProtocol) {
        
        _api = api
        setupNotification()
    }
    
    
    func search(_ productNumber: String) -> Observable<[SearchItemViewModel]> {
        
        return _api.search(productNumber: productNumber).asObservable()
            .flatMap { [weak self] items -> Observable<[SearchItemViewModel]> in
                
                guard let sself = self else { return Observable.just([SearchItemViewModel]()) }
                let viewModels = items.map({ SearchItemViewModel(item: $0, api: sself._api) })
                
                return Observable.just(viewModels)
            }
    }
    
    private func setupNotification() {
        
        let update = Notification.Name(Constants.Notifications.itemAddedToBasketNotification)
        NotificationCenter.default.rx
            .notification(update)
            .bind { [unowned self] _ in self._onSuccess.accept(()) }
            .disposed(by: _bag)
        
        let error = Notification.Name(Constants.Notifications.itemNotAddedToBasketNotification)
        NotificationCenter.default.rx
            .notification(error)
            .bind { [unowned self] notification in
                
                let error = notification.userInfo!["error"] as! Error
                self._onError.accept(error)
            }
            .disposed(by: _bag)
    }
}
