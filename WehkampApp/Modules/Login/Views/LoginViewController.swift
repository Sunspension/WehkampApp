//
//  LoginViewController.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    private let _bag = DisposeBag()
    
    @IBOutlet private weak var userName: PaddedTextField!
    
    @IBOutlet private weak var password: PaddedTextField!
    
    @IBOutlet weak var login: UIButton!
    
    
    var viewModel: LoginViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Login"
        setupView()
        setupViewModel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        
        password.layer.cornerRadius = password.bounds.height / 2
        password.clipsToBounds = true
        userName.layer.cornerRadius = userName.bounds.height / 2
        userName.clipsToBounds = true
        login.layer.cornerRadius = login.bounds.height / 2
    }
    
    private func setupViewModel() {
        
        viewModel.password = password.rx.text.orEmpty.asObservable()
        viewModel.userName = userName.rx.text.orEmpty.asObservable()
        viewModel.loginAction = login.rx.tap
            .map({ [unowned self] in self.view.endEditing(true) })
            .asObservable()
        viewModel.isCanLogin.bind(to: login.rx.isEnabled).disposed(by: _bag)
    }
}
