//
//  PaymentModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift

class JournalModel: Object{
    @objc dynamic var date:Date = Date()
    @objc dynamic var price:Int = 0
    @objc dynamic var memo:String = ""
    @objc dynamic var isPayment:Bool = true
    @objc dynamic var category:String = ""
    @objc dynamic var id:String = UUID().uuidString
    
    convenience init(price: Int, memo: String, category: String) throws {
        self.init()
        
        guard price < 100000000 else {
            throw ValidationError.invalidPriceLimit
        }
        
        guard memo.count <= 10 else {
            throw ValidationError.invalidMemoLimit
        }
        
        self.price = price
        self.memo = memo
    }
    
    enum ValidationError: Error {
        case invalidPriceLimit
        case invalidMemoLimit
    }
    
}
