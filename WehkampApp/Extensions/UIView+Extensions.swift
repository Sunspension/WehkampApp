//
//  UIView+Extensions.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 14/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadow(offset: CGSize, color: UIColor = .black, radius: CGFloat, opacity: Float) {
        
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
}
