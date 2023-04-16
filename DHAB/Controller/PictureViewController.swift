//
//  PictureViewController.swift
//  DHAB
//
//  Created by setoon on 2023/03/24.
//

import Foundation
import UIKit

protocol PictureViewControllerDelegate{
    func deletePicuture()
    func setAddDiaryButtonIsEnable()
}

class PictureViewController:UIViewController{
    
    let pictureViewModel = PictureViewModel()
    var pictureViewControllerDelegate:PictureViewControllerDelegate?
    var image:Data!{
        didSet{
            imageView.image = UIImage(data: pictureViewModel.inputViewControllerImage)!
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image = pictureViewModel.inputViewControllerImage
        setNavigationBarBackButton()
        setNavigationBarDeleteButton()
        setStatusBarBackgroundColor(.flatPowderBlueColorDark())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
    }
    
    func setNavigationBarBackButton(){
        let leftButtonActionSelector: Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: leftButtonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
//        self.navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)
    }
    
    @objc func tapBackButton(){
        self.navigationController?.popViewController(animated: true)
        if pictureViewModel.text != "" && pictureViewModel.titleText != ""{
            pictureViewControllerDelegate?.setAddDiaryButtonIsEnable()
        }
    }
    
    
    func setNavigationBarDeleteButton(){
        let buttonActionSelector: Selector = #selector(tapDeleteButton)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func tapDeleteButton(){
        pictureViewControllerDelegate?.deletePicuture()
        self.navigationController?.popViewController(animated: true)
    }
}
