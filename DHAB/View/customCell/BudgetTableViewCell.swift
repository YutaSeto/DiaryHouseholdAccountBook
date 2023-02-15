//
//  BudgetTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/01/16.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {

    @IBOutlet weak var budgetCategoryLabel: UILabel!
    @IBOutlet weak var budgetPriceLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
