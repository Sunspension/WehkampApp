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
    
    private var _stackOffset: CGFloat = 0
    
    @IBOutlet private weak var userName: PaddedTextField!
    
    @IBOutlet private weak var password: PaddedTextField!
    
    @IBOutlet private weak var login: UIButton!
    
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var busy: UIActivityIndicatorView!
    
    @IBOutlet weak var center: NSLayoutConstraint!
    
    var viewModel: LoginViewModelProtocol!
    
    
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
        
        rx.keyboardHeight
            .bind { [unowned self] height in self.keyboardHandler(height) }
            .disposed(by: _bag)
    }
    
    private func setupViewModel() {
        
        viewModel.password = password.rx.text.orEmpty.asObservable()
        viewModel.userName = userName.rx.text.orEmpty.asObservable()

        viewModel.loginAction = login.rx.tap
            .map({ [unowned self] in self.view.endEditing(true) })
            .asObservable()

        viewModel.isCanLogin.bind(to: login.rx.isEnabled).disposed(by: _bag)
        
        viewModel.loginActivity
            .bind { [weak self] inProgress in
                
                if inProgress { self?.busy.startAnimating() }
                else { self?.busy.stopAnimating() }
        
            }.disposed(by: _bag)
    }
    
    private func keyboardHandler(_ height: CGFloat) {
        
        DispatchQueue.main.async {
            
            let delta = self.view.frame.maxY - self.stack.frame.maxY
            if delta > height && self._stackOffset == 0 { return }
            
            if self._stackOffset == 0 {
                
                self._stackOffset = height - delta + 16
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.center.constant -= self._stackOffset
                    self.view.layoutIfNeeded()
                })
            }
            else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.center.constant += self._stackOffset
                    self._stackOffset = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
}
