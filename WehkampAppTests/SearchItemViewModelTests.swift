//
//  SearchItemViewModelTests.swift
//  WehkampAppTests
//
//  Created by Vladimir Kokhanevich on 16/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
import RxSwift

@testable import WehkampApp

class SearchItemViewModelTests: XCTestCase {
    
    private let _bag = DisposeBag()
    
    private lazy var _searchItem: SearchItem = {
        
        var item = SearchItem()
        item.price = 1399
        item.productNumber = "785023"
        item.sizeCode = "062"
        item.productName = "newborn baby broek"
        item.imageUrl = ""
        
        return item
    }()
    
    private lazy var _viewModel = SearchItemViewModel(item: self._searchItem,
                                                      api: ServerApi(storgeManager: StorageManager()))
    
    func testAddItem() {
        
        let promise = expectation(description: "addItem")
        
        let name = Notification.Name(Constants.Notifications.itemAddedToBasketNotification)
        
        NotificationCenter.default.rx.notification(name)
            .subscribe(onNext: { _ in promise.fulfill() })
            .disposed(by: _bag)
        
        _viewModel.addItemToBasket()
        
        waitForExpectations(timeout: 5) { error in print(error ?? "") }
    }
    
}
