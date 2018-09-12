//
//  LoginViewModel.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class LoginViewModel {
    
    private let _bag = DisposeBag()
    
    private let _api: ServerApiProtocol
    
    private let _storage: StorageManagable
    
    private let _loginActivity = PublishRelay<Bool>()
    
    var loginActivity: Observable<Bool> {
        
        return _loginActivity.asObservable()
    }
    
    var userName = Observable.just("")
    
    var password = Observable.just("")
    
    var loginAction = Observable.just(()) {
        
        didSet { setupLoginAction() }
    }
    
    var isCanLogin: Observable<Bool> {
        
        return Observable
            .combineLatest(userName, password) { !$0.isEmpty && !$1.isEmpty }
    }
    
    var router: LoginRoutable?
    
    
    init(api: ServerApiProtocol, storage: StorageManagable) {
        
        _api = api
        _storage = storage
    }
    
    private func setupLoginAction() {
        
        let loginPassword = Observable.combineLatest(userName, password) { (userName: $0, password: $1) }
        
        loginAction.withLatestFrom(loginPassword)
            .bind(onNext: { [unowned self] _ in self._loginActivity.accept(true) })
            .disposed(by: _bag)
        
        loginAction.withLatestFrom(loginPassword)
            .flatMapLatest { [unowned self] pair in self._api.authorization(login: pair.userName, password: pair.password) }
            .asDriver(onErrorRecover: { [weak self] error in
                
                self?.router?.onError(error: error)
                return Driver.just(Token(jwt: ""))
            })
            .filter({ !$0.jwt.isEmpty })
            .drive(onNext: { [weak self] token in
                
                self?._storage.saveToken(token.jwt)
                self?.router?.onSuccessLogin()
                
            }).disposed(by: _bag)

    }
}
