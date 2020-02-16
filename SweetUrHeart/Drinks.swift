//
//  Drinks.swift
//  SweetUrHeart
//
//  Created by 陳勁廷 on 2020/2/15.
//  Copyright © 2020 陳勁廷. All rights reserved.
//

import Foundation


struct Drinks {
    var name: String
    var price: Int
    
}

//讀取訂單內容用的
struct Menu {
    
    var name: String
    var drink: String
    var price: String
    var ice: Ice
    var sugar: String
    
    init() {
        name = ""
        drink = ""
        price = ""
        ice = .regular
        sugar = ""
    }
}

enum Ice:String{
    case regular = "冰沙", moreIce = "冰塊"
}

//顯示cell資料、上傳及下載sheetDB及下載資料用的
struct DrinksInformation : Codable{
    var name: String
    var drinks: String
    var price: String
    var ice: String
    var sugar: String
    
    
    
    init?(json: [String : Any]) {
        guard let name = json["name"] as? String,
            let drinks = json["drinks"] as? String,
            let sugar = json["sugar"] as? String,
            let price = json["price"] as? String,
            let ice = json["ice"] as? String
            else {
                return nil
        }
        self.name = name
        self.drinks = drinks
        self.sugar = sugar
        self.price = price
        self.ice = ice
        
    }
    
}





