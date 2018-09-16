//
//  ServerApiProtocol.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift
import Moya

protocol ServerApiProtocol {
    
    func authorization(login: String, password: String) -> Single<Token>
    
    func basket() -> Single<[Product]>
    
    func updateItemsCount(id: String, count: Int) -> Single<Product>
    
    func deleteItem(id: String) -> Single<Response>
    
    func addItem(productNumber: String, sizeCode: String, count: Int) -> Single<Response>
    
    func search(productNumber: String) -> Single<[SearchItem]>
}
