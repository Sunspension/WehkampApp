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
    availability = "availability_text",
    price = "original_price",
    normalizedName = "normalized_name",
    alternateUrls = "alternate_urls",
    size = "size",
    maxCount = "max_items_in_basket"
}

final class Product: Decodable {
    
    var id = ""
    
    var count = 0
    
    var maxCount = 0
    
    var number = ""
    
    var name = ""
    
    var availability = ""
    
    var price = 0.0
    
    var sizeCode = ""
    
    var normalizedName = ""
    
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        count = try values.decode(Int.self, forKey: .count)
        maxCount = try values.decode(Int.self, forKey: .maxCount)
        number = try values.decode(String.self, forKey: .number)
        name = try values.decode(String.self, forKey: .name)
        price = try values.decode(Double.self, forKey: .price)
        availability = try values.decode(String.self, forKey: .availability)
        normalizedName = try values.decode(String.self, forKey: .normalizedName)
        
        let size = try values.decode([String : Any].self, forKey: .size)
        sizeCode = size["code"] as! String
    }
}

extension Product: CustomStringConvertible {
    
    var description: String {
        
        return "number: \(number) name: \(name) price: \(price) count: \(count))"
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
