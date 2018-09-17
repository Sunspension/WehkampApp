//
//  ApiTests.swift
//  WehkampAppTests
//
//  Created by Vladimir Kokhanevich on 16/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
import RxSwift
import Moya

@testable import WehkampApp

class ApiTests: XCTestCase {
    
    static var count = 0
    
    private let _bag = DisposeBag()
    
    private let _storage = StorageManager()
    
    private lazy var _api = ServerApi(storgeManager: self._storage)
    
    
    func testAuthorization() {
        
        executeWithAsyncResult { promise in
            
            self.authorization()
                .subscribe(onSuccess: { _ in promise.fulfill() })
                .disposed(by: self._bag)
        }
    }
    
    func testBasketRequest() {
        
        executeWithAsyncResult { promise in
            
            self.authorization()
                .flatMap({ [unowned self] _ in self.addItem() })
                .flatMap({ [unowned self] _ in self._api.basket() })
                .subscribe(onSuccess: { items in
                    
                    XCTAssert(!items.isEmpty)
                    promise.fulfill()
                    
            }).disposed(by: self._bag)
        }
    }
    
    func testSearch() {
        
        executeWithAsyncResult { promise in
            
            self.authorization()
                .flatMap { [unowned self] _ in self._api.search(productNumber: "785026") }
                .subscribe(onSuccess: { items in
                    
                    XCTAssert(items.count > 0)
                    promise.fulfill()
                    
                }).disposed(by: _bag)
        }
    }
    
    func testAddItem() {
        
        executeWithAsyncResult { promise in
            
            self.addItem()
                .filter({ $0.request != nil })
                .subscribe(onSuccess: { _ in promise.fulfill() })
                .disposed(by: _bag)
        }
    }
    
    func testDeleteItem() {
        
        executeWithAsyncResult { promise in
            
            let itemId = "3a3c2eac-af78-4114-8b48-e1a010dae843"
            self.addItem()
                .flatMap({ [unowned self] _ in self._api.deleteItem(id: itemId)})
                .subscribe(onSuccess: { _ in promise.fulfill() })
                .disposed(by: _bag)
        }
    }
    
    private func addItem() -> Single<Response> {
        
        return self.authorization().flatMap { _ in
            
            self._api.addItem(productNumber: "785045", sizeCode: "305", count: 1)
            
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
                        
                        self._storage.saveToken(token.jwt)
                        event(.success(true))
                    }
                    else { event(.error(WAError.message(message: "bad authorization"))) }
                    
                    return Disposables.create()
                })
        }
    }
    
    private func executeWithAsyncResult(_ closure: (_ promise: XCTestExpectation) -> Void) {
        
        let promise = expectation(description: "api" + "\(ApiTests.count += 1)")
        closure(promise)
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
}
