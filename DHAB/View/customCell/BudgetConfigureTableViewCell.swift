//
//  BudgetConfigureTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/01/24.
//

import UIKit

protocol BudgetConfigureTableViewCellDelegate{
    func tableViewCell(didChngeText text: String, data:BudgetTableViewCellItem? )
}


class BudgetConfigureTableViewCell: UITableViewCell {
    
    var data:BudgetTableViewCellItem?
    var price:Int = 0
    var delegate:BudgetConfigureTableViewCellDelegate?
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        priceTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),for:.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField:UITextField){
        guard let text = textField.text else{return}
        
        if let price = Int(text){
            data?.price = price
        }
        delegate?.tableViewCell(didChngeText: text, data: data)
    }
}
