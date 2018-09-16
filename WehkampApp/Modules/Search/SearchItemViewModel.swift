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

class SearchItemViewModel {
    
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
            .catchError { _ in Single.just(Response(statusCode: 0, data: Data())) }
            .filter({ $0.statusCode != 0 })
            .subscribe(onSuccess: { [weak self] _ in self?.notifyBasket() })
            .disposed(by: _bag)
    }
    
    func notifyBasket() {
        
        let name = Notification.Name(Constants.Notifications.itemWasAddedToBasketNotification)
        let notification = Notification(name: name)
        NotificationCenter.default.post(notification)
    }
}
