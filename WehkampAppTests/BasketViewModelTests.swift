//
//  BasketViewModelTests.swift
//  WehkampAppTests
//
//  Created by Vladimir Kokhanevich on 16/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
import RxSwift
import Moya

@testable import WehkampApp

class BasketViewModelTests: XCTestCase {
    
    private let _bag = DisposeBag()
    
    private let _storage = StorageManager()
    
    private lazy var _api = ServerApi(storgeManager: self._storage)
    
    private lazy var _viewModel = BasketViewModel(api: self._api)
    
    
    func testRequestBasket() {
        
        let promise = expectation(description: "basket")
        
        _viewModel.products.take(1).subscribe(onNext: { _ in promise.fulfill() }).disposed(by: _bag)
        
        addItem().filter({ $0.request != nil })
            .subscribe(onSuccess: { [unowned self] _ in self._viewModel.requestBasket() })
            .disposed(by: _bag)
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
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
}
