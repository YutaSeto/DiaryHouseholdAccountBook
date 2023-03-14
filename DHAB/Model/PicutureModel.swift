//
//  PicutureModel.swift
//  DHAB
//
//  Created by setoon on 2023/02/24.
//

import Foundation
import RealmSwift

class PictureModel:Object{
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var imageData:Data = Data()
    @objc dynamic var createdAt:Date = Date()
}
