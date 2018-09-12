//
//  StorageManager.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 12/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import KeychainAccess

private enum KeychainKeys: String {
    
    case token = "WA_JWToken"
}

protocol StorageManagable {
    
    func saveToken(_ token: String)
    
    func jwToken() -> String
    
    func deleteToken()
}

struct StorageManager {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
}

extension StorageManager: StorageManagable {
    
    func jwToken() -> String {
        
        return keychain[KeychainKeys.token.rawValue] ?? ""
    }
    
    func saveToken(_ token: String) {
        
        keychain[KeychainKeys.token.rawValue] = token
    }
    
    func deleteToken() {
        
        try? keychain.remove(KeychainKeys.token.rawValue)
    }
}
