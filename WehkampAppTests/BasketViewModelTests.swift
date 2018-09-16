//
//  BasketViewModelTests.swift
//  WehkampAppTests
//
//  Created by Vladimir Kokhanevich on 16/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
import RxSwift

@testable import WehkampApp

class BasketViewModelTests: XCTestCase {
    
    private let _bag = DisposeBag()
    
    private lazy var _viewModel = BasketViewModel(api: ServerApi(storgeManager: StorageManager()))
    
    func testRequestBasket() {
        
        let promise = expectation(description: "basket")
        
        _viewModel.products
            .subscribe(onNext: { products in
            
                // it's not a mistake to get empty basket
                promise.fulfill()
        
            }).disposed(by: _bag)
        
        _viewModel.requestBasket()
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
}
