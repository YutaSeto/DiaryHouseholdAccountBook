//
//  NotificationModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/17.
//

import Foundation
import UIKit

class NotificationModel{
    
    var date:Date = Date()
    var datePicker:UIDatePicker{
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.timeZone = TimeZone(identifier: "Asia/tokyo")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.locale = Locale(identifier: "ja-JP")
        return datePicker
    }
}
