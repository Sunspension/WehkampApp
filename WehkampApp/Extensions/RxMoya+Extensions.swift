//
//  RxMoya+Extensions.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Moya
import RxSwift

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    
    func mapResponse<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil) -> Single<D> {
        
        return flatMap { res in
            
            return Single.create(subscribe: { event in
                
                if let response = try? res.map(type, atKeyPath: keyPath, using: JSONDecoder(), failsOnEmptyData: true) {
                    
                    event(.success(response))
                }
                else {
                    
                    let error = self.handleError(res)
                    event(.error(error))
                }
                
                return Disposables.create()
            })
        }
    }
    
    private func handleError(_ response: Response) -> WAError {
        
        if let serverError = try? response.map(ServerError.self) {
            
            return WAError.serverError(error: serverError)
        }
        else {
            
            return WAError.any(message: response.description)
        }
    }
}
