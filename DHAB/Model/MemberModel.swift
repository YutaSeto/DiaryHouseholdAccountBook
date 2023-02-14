//
//  MemberModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift

@objcMembers class Record: Object{
    dynamic var id: String = UUID().uuidString
    dynamic let payments: List<PaymentModel>! = nil
    dynamic let incomes: List<IncomeModel>! = nil
    dynamic let diary:DiaryModel! = nil
    override static func primaryKey() -> String? {
        return "id"
    }
}
