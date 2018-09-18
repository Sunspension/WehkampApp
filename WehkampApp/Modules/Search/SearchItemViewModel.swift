//
//  SearchItemViewModel.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 15/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift
import Moya

protocol SearchItemViewModelProtocol {
    
    var itemName: String { get }
    
    var price: String { get }
    
    var productImage: String { get }
    
    func addItemToBasket()
}

class SearchItemViewModel: SearchItemViewModelProtocol {
    
    private let _bag = DisposeBag()
    
    private let _item: SearchItem
    
    private let _api: ServerApiProtocol
    
    var itemName: String {
        
        return _item.productName
    }
    
    var price: String {
        
        return String(_item.price / 100)
    }
    
    var productImage: String {
        
        return _item.imageUrl
    }
    
    
    init(item: SearchItem, api: ServerApiProtocol) {
        
        _item = item
        _api = api
    }
    
    func addItemToBasket() {
        
        _api.addItem(productNumber: _item.productNumber, sizeCode: _item.sizeCode, count: 1)
            .flatMap({ response -> Single<Response> in
                
                return Single.create(subscribe: { event -> Disposable in
                    
                    if response.statusCode > 300 {
                        
                        let message = String(data: response.data, encoding: String.Encoding.utf8)
                        event(.error(WAError.message(message: message ?? "Something went wrong")))
                    }
                    else { event(.success(response)) }
                    
                    return Disposables.create()
                })
            })
            .catchError { [weak self] error in
                
                self?.notifyAboutError(error)
                return Single.just(Response(statusCode: 0, data: Data()))
            }
            .filter({ $0.request != nil })
            .subscribe(onSuccess: { [weak self] _ in self?.notifyBasket() })
            .disposed(by: _bag)
    }
    
    private func notifyBasket() {
        
        let name = Notification.Name(Constants.Notifications.itemAddedToBasketNotification)
        let notification = Notification(name: name)
        NotificationCenter.default.post(notification)
    }
    
    private func notifyAboutError(_ error: Error) {
        
        let name = Notification.Name(Constants.Notifications.itemNotAddedToBasketNotification)
        let notification = Notification(name: name, userInfo: ["error" : error])
        NotificationCenter.default.post(notification)
    }
}
