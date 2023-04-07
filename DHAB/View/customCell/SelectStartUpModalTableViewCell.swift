//
//  SelectStartUpModalTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/04/06.
//

import UIKit

class SelectStartUpModalTableViewCell: UITableViewCell {

    @IBOutlet weak var modalSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn{
            RecognitionChange.shared.startUpTimeModal = true
        }else{
            RecognitionChange.shared.startUpTimeModal = false
        }
    }
}
