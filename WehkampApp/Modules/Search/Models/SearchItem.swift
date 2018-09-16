//
//  SearchItem.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 15/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

private enum CodingKeys: String, CodingKey {
    
    case number = "productNumber",
    code = "sizeCode",
    images = "images",
    price = "pricing",
    name = "title"
}

struct SearchItem2: Decodable {
    
    var productName = ""
    
    var productNumber = ""
    
    init() {}
    
    init(from decoder: Decoder) throws {
        
        
    }
}

struct SearchItem: Decodable {
    
    var productName = ""
    
    var productNumber = ""
    
    var sizeCode = ""
    
    var imageUrl = ""
    
    var price = 0.0
    
    init() { }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        productName = try values.decode(String.self, forKey: .name)
        productNumber = try values.decode(String.self, forKey: .number)
        sizeCode = try values.decode(String.self, forKey: .code)
        
        let images = try values.decode([String : Any].self, forKey: .images)
        
        if let image = (images["imageUris"] as? [String])?.first {
            
            imageUrl = image
        }
        
        let prices = try values.decode([String : Any].self, forKey: .price)
        
        if let price = prices["price"] as? Int {
            
            self.price = Double(price)
        }
    }
}
