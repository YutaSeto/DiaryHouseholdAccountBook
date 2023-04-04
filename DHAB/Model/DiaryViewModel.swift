//
//  DiaryViewModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/03.
//

import Foundation
import UIKit
import RealmSwift

class DiaryViewModel{
    
    let util = Util()
    var diaryList: [Diary] = []
    var diaryByMonth:[String: [Diary]] = [:]
    var titleResult: Results<Diary>?
    var textResult: Results<Diary>?
    
    func setDiaryData(){
        let realm = try! Realm()
        let result = realm.objects(Diary.self).sorted(byKeyPath: "date", ascending: false)
        diaryList = Array(result)
        
        diaryByMonth.removeAll()
        
        for diary in diaryList{
            let dateString = util.monthDateFormatter.string(from: diary.date)
            if diaryByMonth[dateString] == nil{
                diaryByMonth[dateString] = []
            }
            diaryByMonth[dateString]?.append(diary)
        }
    }
}
