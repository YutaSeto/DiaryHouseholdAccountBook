//
//  InputCollectionViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/03/16.
//

import UIKit

class InputCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor // 枠線の色
    }

}
