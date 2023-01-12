//
//  IncomeModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift

class IncomeModel: Object{
    @objc dynamic var date:Date = Date()
    @objc dynamic var amount:Int = 0
    @objc dynamic var expenceItem:String = ""
}
