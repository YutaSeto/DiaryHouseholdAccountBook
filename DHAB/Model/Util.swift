//
//  Util.swift
//  DHAB
//
//  Created by 瀬戸雄太 on 2023/03/12.
//

import Foundation
import UIKit

class Util:UIViewController{
    public var yearDateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    public var monthDateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年M月"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    public var dayDateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年M月d日"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    public var onliDayDateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d日"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    public var dayOfWeekDateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    public var monthAndDayDateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    func getComma(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let number = "\(formatter.string(from: NSNumber(value: num)) ?? "")"
        return number
    }
    
    func setFirstDay(date:Date) -> Date{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date.zeroclock)
        let firstDay = calendar.date(from: comps)!.zeroclock
        return firstDay
    }
    
    func setLastDay(date:Date) -> Date{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date.zeroclock)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        return lastDay!
    }
}
