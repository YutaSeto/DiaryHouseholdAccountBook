//
//  HouseholdAccountBookTableViewCellItem.swift
//  DHAB
//
//  Created by setoon on 2023/02/06.
//

import Foundation
import Foundation
import RealmSwift

struct HouseholdAccountBookTableViewCellItem{
    var id: String = ""
    var name: String = ""
    var paymentPrice:Int = 0
    var budgetPrice: Int = 0
}

struct IncomeTableViewCellItem{
    var id: String = ""
    var name: String = ""
    var incomePrice:Int = 0
    var incomeBudget: Int = 0
}
