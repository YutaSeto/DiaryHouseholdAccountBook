//
//  FSCalendarCell.swift
//  DHAB
//
//  Created by setoon on 2023/03/28.
//

import UIKit
import FSCalendar
import ChameleonFramework

class FSCalendarCustomCell: FSCalendarCell {
    
    @IBOutlet weak var dayLabel:UILabel!
    @IBOutlet weak var paymentLabel:UILabel!
    @IBOutlet weak var incomeLabel:UILabel!
    
    var collectionViewDate:Date?
    var labelsDate:Date?
    var _isSelected = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
            
    func select(){
        _isSelected = true
        
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        self.layer.borderColor = themeColor.darkColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func deselect(){
        _isSelected = false
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
