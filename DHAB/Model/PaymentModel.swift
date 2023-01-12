//
//  PaymentModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift

class PaymentModel: Object{
    @objc dynamic var date:Date = Date()
    @objc dynamic var price:Int = 0
    @objc dynamic var expenceItem:String = ""
}
