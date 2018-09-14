//
//  ProductViewModel.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 14/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProductViewModel {
    
    private let _bag = DisposeBag()
    
    private let _product: Product
    
    private let _api: ServerApiProtocol
    
    private let _count = BehaviorSubject<String>(value: "0")
    
    private let _price = BehaviorSubject<String>(value: "0")
    
    var plusItem = Driver.just(()) {
        
        didSet { setupPlusItem() }
    }
    
    var minusItem = Driver.just(()) {
        
        didSet { setupMinusItem() }
    }
    
    var deleteItem = Driver.just(()) {
        
        didSet { setupRemoveItem() }
    }
    
    var productName: String {
        
        return _product.name
    }
    
    var availability: String {
        
        return _product.availability
    }
    
    var productImage: String {
        
        // https://images.wehkamp.nl/i/wehkamp/16151274_pb_01?w=100
        return "https://images.wehkamp.nl/i/wehkamp/" + "\(_product.number)" + "_pb_01"
    }
    
    var count: Observable<String> {
        
        return _count.asObservable()
    }
    
    var price: Observable<String> {
        
        return _price.asObservable()
    }
    
    init(product: Product, api: ServerApiProtocol) {
        
        _product = product
        _api = api
        
        setCount()
        setPrice()
    }
    
    private func setupPlusItem() {
        
        plusItem.drive(onNext: { [unowned self] _ in
            
            if self._product.count == self._product.maxCount { return }
            self.updateItemsCount(self._product.count + 1)
        
        }).disposed(by: _bag)
    }
    
    private func setupMinusItem() {
        
        minusItem.drive(onNext: { [unowned self] _ in
            
            if self._product.count == 1 { return }
            self.updateItemsCount(self._product.count - 1)
            
        }).disposed(by: _bag)
    }
    
    private func setupRemoveItem() {
        
        
    }
    
    private func updateItemsCount(_ count: Int) {
        
        _api.updateItemsCount(id: _product.id, count: count)
            .catchError { error in return Single.just(Product(), scheduler: MainScheduler.instance) }
            .filter({ !$0.id.isEmpty })
            .subscribe(onSuccess: { [weak self] in self?.handleUpdatedProduct($0) }, onError: { debugPrint($0) })
            .disposed(by: _bag)
    }
    
    private func removeItemFromRemoteBasket() {
        
        
    }
    
    private func handleUpdatedProduct(_ product: Product) {
        
        _product.count = product.count
        setCount()
        
        _product.price = product.price
        setPrice()
    }
    
    private func setPrice() {
        
        _price.onNext(String(_product.price / 100))
    }
    
    private func setCount() {
        
        _count.onNext(String(_product.count))
    }
}
