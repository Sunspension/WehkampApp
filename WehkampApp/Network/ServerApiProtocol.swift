//
//  ServerApiProtocol.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift

protocol ServerApiProtocol {
    
    func authorization(login: String, password: String) -> Single<Token>
}
