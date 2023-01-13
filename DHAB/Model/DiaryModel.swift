//
//  DiaryModel.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift

class DiaryModel: Object{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var title: String = ""
    @objc dynamic var text: String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
}
