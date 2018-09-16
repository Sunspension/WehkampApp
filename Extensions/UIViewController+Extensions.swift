//
//  UIViewController+Extensions.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    
    func showError(title: String = "Error", message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

public extension Reactive where Base: UIViewController {
    
    public var keyboardHeight: Observable<CGFloat> {
        
        let willShow = NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillShow)
            .map({ ($0.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0 })
        
        let willHide = NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillHide)
            .map({ _ in CGFloat(0) })
        
        return Observable.from([willShow, willHide]).merge()
    }
}
