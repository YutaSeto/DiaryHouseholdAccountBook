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
    
    convenience init(name: String, isPayment: Bool) throws {
        self.init()
        guard name.count <= 8 else {
            throw ValidationError.invalidNameLength
        }
        self.name = name
        self.isPayment = isPayment
    }
    
    enum ValidationError: Error {
        case invalidNameLength
        case invalidTooManyPayment
    }
}

