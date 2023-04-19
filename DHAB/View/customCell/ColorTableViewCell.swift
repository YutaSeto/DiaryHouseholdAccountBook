//
//  ColorTableViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/04/19.
//

import UIKit

class ColorTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        colorView.layer.cornerRadius = 5
        checkMark.image = UIImage(systemName: "checkmark")
        checkMark.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeCheckMark(){
        checkMark.isHidden = false
    }
}
