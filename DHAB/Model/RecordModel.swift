//
//  RecordModel.swift
//  DHAB
//
//  Created by 瀬戸雄太 on 2023/01/23.
//

import Foundation
import RealmSwift
import UIKit

@objcMembers class RecordModel:Object{
    dynamic var id: String = ""
    dynamic var payments = List<PaymentModel>()
    dynamic var incomes = List<IncomeModel>()
    dynamic var diary = List<DiaryModel>()
    dynamic var date: Date = Date()
    
    
    func sumPayments(){
    }
    
    func sumIncomes(){
    }
    
}
