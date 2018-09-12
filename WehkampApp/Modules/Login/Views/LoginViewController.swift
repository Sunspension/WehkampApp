//
//  LoginViewController.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet private weak var userName: PaddedTextField!
    
    @IBOutlet private weak var password: PaddedTextField!
    
    @IBOutlet weak var login: UIButton!
    
    
    var viewModel: LoginViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Login"
        setupView()
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
}
