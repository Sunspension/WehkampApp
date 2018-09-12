//
//  Routable.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Swinject

protocol Routable: class {
    
    var container: Container { get }
    
    func controller(_ type: AppControllerType) -> UIViewController
}
