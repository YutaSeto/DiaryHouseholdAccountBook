//
//  DiaryTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/01/13.
//

import UIKit

class DiaryTableViewCell: UITableViewCell {

    @IBOutlet weak var cellDateLabel: UILabel!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellTextLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
