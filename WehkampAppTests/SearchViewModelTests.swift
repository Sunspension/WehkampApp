//
//  SearchViewModelTests.swift
//  WehkampAppTests
//
//  Created by Vladimir Kokhanevich on 16/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
import RxSwift

@testable import WehkampApp

class SearchViewModelTests: XCTestCase {
    
    private let _bag = DisposeBag()
    
    private lazy var _viewModel = SearchViewModel(api: ServerApi(storgeManager: StorageManager()))
    
    
    func testSearch() {
        
        let promise = expectation(description: "search")
        
        _viewModel.search("785026").subscribe(onNext: { items in
            
            XCTAssert(!items.isEmpty)
            promise.fulfill()
            
        }).disposed(by: _bag)
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
}
