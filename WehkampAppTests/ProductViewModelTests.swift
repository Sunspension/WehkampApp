//
//  ProductViewModelTests.swift
//  WehkampAppTests
//
//  Created by Vladimir Kokhanevich on 16/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
import RxSwift
import Moya

@testable import WehkampApp

class ProductViewModelTests: XCTestCase {
    
    private let _bag = DisposeBag()
    
    private let storage = StorageManager()
    
    private lazy var _api = ServerApi(storgeManager: self.storage)
    
    private var _viewModel: ProductViewModel!
    
    
    func testIncreaseNumberOfItems() {
        
        let promise = expectation(description: "increase")
        
        addProduct(count: 1).subscribe(onSuccess: { [unowned self] product in
            
            let count = product.count
            self._viewModel = ProductViewModel(product: product, api: self._api)
            
            self._viewModel.increaseCount()
            self._viewModel.count.skip(1).subscribe(onNext: { itemsCount in
                
                XCTAssert(count + 1 == Int(itemsCount)!)
                promise.fulfill()
                
            }).disposed(by: self._bag)
            
        }).disposed(by: _bag)
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
    
    func testDecreaseNumberOfItems() {
        
        let promise = expectation(description: "decrease")
        
        addProduct(count: 2).subscribe(onSuccess: { [unowned self] product in
            
            let count = product.count
            self._viewModel = ProductViewModel(product: product, api: self._api)
            
            self._viewModel.decreaseCount()
            self._viewModel.count.skip(1).subscribe(onNext: { itemsCount in
                
                XCTAssert(count - 1 == Int(itemsCount)!)
                promise.fulfill()
                
            }).disposed(by: self._bag)
            
        }).disposed(by: _bag)
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
    
    func testDeleteItem() {
        
        let promise = expectation(description: "delete item")
        
        addItem(number: "785012", sizeCode: "044", count: 1)
            .flatMap({ response -> Single<String> in
                
                Single.create(subscribe: { event -> Disposable in
                    
                    if response.statusCode < 300 {
                        
                        let serialized = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments)
                        
                        if let objects = serialized as? [[String : Any]], let id = objects.first?["id"] as? String {
                            
                            event(.success(id))
                        }
                        else {
                            
                            event(.error(WAError.message(message: "Parsing error")))
                        }
                    }
                    else {
                        
                        event(.error(WAError.message(message: "Something went wrong")))
                    }
                    
                    return Disposables.create()
                })
            })
            .flatMap({ [unowned self] id in self._api.deleteItem(id: id)})
            .subscribe(onSuccess: { _ in promise.fulfill() })
            .disposed(by: _bag)
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
    
    private func addProduct(count: Int) -> Single<Product> {
        
        return authorization()
            .flatMap { [unowned self] _ in  self.addItem(count: count) }
            .flatMap { [unowned self] _ in self._api.basket() }
            .flatMap { items in Single.just(items.first!) }
    }
    
    private func addItem(number: String = "16151274", sizeCode: String = "036", count: Int) -> Single<Response> {
        
        return self.authorization().flatMap { _ in
            
            self._api.addItem(productNumber: number, sizeCode: sizeCode, count: count)
            
            }.flatMap({ response -> Single<Response> in
                
                return Single.create(subscribe: { event -> Disposable in
                    
                    if response.statusCode > 300 {
                        
                        let message = String(data: response.data, encoding: String.Encoding.utf8)
                        event(.error(WAError.message(message: message ?? "Something went wrong")))
                    }
                    else { event(.success(response)) }
                    
                    return Disposables.create()
                })
                
            }).catchErrorJustReturn(Response(statusCode: 0, data: Data()))
    }
    
    private func authorization() -> Single<Bool> {
        
        return _api.authorization(login: "iosassessment@wehkamp.nl", password: "swiftrules")
            .flatMap { token -> Single<Bool> in
                
                return Single.create(subscribe: { [unowned self] event in
                    
                    if !token.jwt.isEmpty {
                        
                        self.storage.saveToken(token.jwt)
                        event(.success(true))
                    }
                    else { event(.error(WAError.message(message: "bad authorization"))) }
                    
                    return Disposables.create()
                })
        }
    }
}
