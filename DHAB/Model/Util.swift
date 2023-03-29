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
        dateFormatter.dateFormat = "yy年M月dd日"
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
}
