//
//  IncomeCategory.swift
//  DHAB
//
//  Created by setoon on 2023/02/17.
//

import Foundation
import RealmSwift
import UIKit

class IncomeCategoryModel:Object{
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
}
