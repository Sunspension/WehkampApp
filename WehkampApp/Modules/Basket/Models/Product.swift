//
//  Basket.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

private enum CodingKeys: String, CodingKey {
    
    case id = "id",
    number = "product_number",
    count = "number_of_products",
    name = "title",
    price = "original_price",
    imageUrl = "url",
    alternateUrls = "alternate_urls"
}

struct Product: Decodable {
    
    let id: String
    
    let count: Int
    
    let number: String
    
    let name: String
    
    let price: Double
    
    let imageUrlString: String?
    
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        count = try values.decode(Int.self, forKey: .count)
        number = try values.decode(String.self, forKey: .number)
        name = try values.decode(String.self, forKey: .name)
        price = try values.decode(Double.self, forKey: .price)
        
        let alternate = try values.decode([Any].self, forKey: .alternateUrls) as! [[String : Any]]
        imageUrlString = alternate.first?["url"] as? String
    }
}

extension Product: CustomStringConvertible {
    
    var description: String {
        
        return "number: \(number) name: \(name) price: \(price) count: \(count) image: \(imageUrlString ?? "")"
    }
}

extension Product: Hashable {
    
    var hashValue: Int {
        
        return id.hashValue
    }
}

extension Product: Equatable {
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        
        return lhs.id == rhs.id && lhs.count == rhs.count
    }
}
