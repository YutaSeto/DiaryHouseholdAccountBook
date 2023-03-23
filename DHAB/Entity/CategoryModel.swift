//
//  CategoryModel.swift
//  DHAB
//
//  Created by setoon on 2023/02/04.
//

import Foundation
import RealmSwift

class CategoryModel: Object{
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var isPayment: Bool = true
}

