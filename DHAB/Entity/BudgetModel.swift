//
//  PaymentBudgetModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/14.
//

import Foundation
import RealmSwift


class BudgetModel: Object{
    @objc dynamic var id: String = ""
    @objc dynamic var expenseID: String = ""
    @objc dynamic var budgetDate: Date = Date()
    @objc dynamic var isPayment: Bool = true
    @objc dynamic var budgetPrice: Int = 0
}
