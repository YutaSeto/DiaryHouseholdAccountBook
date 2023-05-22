//
//  RecognitionChange.swift
//  DHAB
//
//  Created by setoon on 2023/02/24.
//

import Foundation
import UIKit
import RealmSwift

final public class RecognitionChange{
    
    var updateCalendar:Bool = false
    var updateHouseholdAccountBook:Bool = false
    var deletePayment:Bool = false
    var deleteDiaryByCalendar:Bool = false
    var deleteDiaryByDiary:Bool = false
    var updateDiaryByCalendar:Bool = false
    var updateDiaryByCalendarForDiary:Bool = false
    var changeColor:Bool = false
    var startUpTimeModal:Bool = false{
        didSet{
            let defaults = UserDefaults.standard
            defaults.set(startUpTimeModal, forKey: "startUpTimeModal")
        }
    }
    var updateJournalByCalendar:Bool = false
    static let shared = RecognitionChange()
    
    private init(){
        let defaults = UserDefaults.standard
        startUpTimeModal = defaults.bool(forKey: "startUpTimeModal")
    }
    
}
