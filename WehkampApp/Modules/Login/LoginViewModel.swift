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

class LoginViewModel {
    
    private let _bag = DisposeBag()
    
    private let _api: ServerApiProtocol
    
    private let _storage: StorageManagable
    
    private let _router: LoginRoutable
    
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
    
    
    init(api: ServerApiProtocol, storage: StorageManagable, router: LoginRoutable) {
        
        _api = api
        _storage = storage
        _router = router
    }
    
    private func setupLoginAction() {
        
        let loginPassword = Observable
            .combineLatest(userName, password) { (userName: $0, password: $1) }
            .share(replay: 1)
        
        loginAction
            .withLatestFrom(loginPassword)
            .bind(onNext: { [unowned self] _ in self._loginActivity.accept(true) })
            .disposed(by: _bag)
        
        loginAction
            .withLatestFrom(loginPassword)
            .flatMapLatest { [unowned self] pair in self.loginRequest(pair) }
            .filter({ !$0.jwt.isEmpty })
            .subscribe(onNext: { [weak self] token in
                
                self?._loginActivity.accept(false)
                self?._storage.saveToken(token.jwt)
                self?._router.onSuccessLogin()
                
            }).disposed(by: _bag)
    }
    
    private func loginRequest(_ pair: (login: String, password: String)) -> Single<Token> {
        
        return _api
            .authorization(login: pair.login, password: pair.password)
            .catchError({ [weak self] error -> Single<Token> in
                
                self?._loginActivity.accept(false)
                self?._router.onError(error: error)
                
                return Single.just(Token(jwt: ""))
            })
    }
}
