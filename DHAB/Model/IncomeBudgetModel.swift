//
//  IncomeBudgetModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/14.
//

import Foundation
import RealmSwift

class IncomeBudgetModel: Object{
    @objc dynamic var budgetDate:Date = Date()
    @objc dynamic var budgetAmount:Int = 0
    @objc dynamic var budgetExpenceItem:String = ""
}
