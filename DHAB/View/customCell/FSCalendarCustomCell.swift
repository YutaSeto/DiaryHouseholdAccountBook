//
//  FSCalendarCell.swift
//  DHAB
//
//  Created by setoon on 2023/03/28.
//

import UIKit
import FSCalendar

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
        self.layer.borderColor = UIColor.lightGray.cgColor // 枠線の色
    }
    
    var date: Date!{
        didSet{
            self.labelsDate = date
        }
    }
    
    func select() {
        _isSelected = true
        self.contentView.backgroundColor = .lightGray
    }
    
    func deselect() {
        _isSelected = false
        self.contentView.backgroundColor = .white
    }
}
