//
//  BudgetConfigureTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/01/24.
//

import UIKit

class BudgetConfigureTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expenceItemLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
