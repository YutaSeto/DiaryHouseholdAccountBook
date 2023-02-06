//
//  HouseholdAccountBookTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/01/14.
//

import UIKit

class HouseholdAccountBookTableViewCell: UITableViewCell {

    @IBOutlet weak var expenceItemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
