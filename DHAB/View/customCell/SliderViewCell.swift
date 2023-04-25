//
//  SliderViewCell.swift
//  DHAB
//
//  Created by setoon on 2023/01/31.
//

import UIKit

class SliderViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    var image:UIImage!{
        didSet{
            imageView.image = image
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
