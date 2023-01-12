//
//  MemberModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift

class MemberModel:Object{
    @objc dynamic var id: String = UUID().uuidString
    dynamic var payments: List<PaymentModel>!
    dynamic var incomes: List<IncomeModel>!
}
