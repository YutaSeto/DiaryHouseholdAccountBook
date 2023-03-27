//
//  LookDiaryViewController.swift
//  DHAB
//
//  Created by setoon on 2023/03/24.
//

import Foundation
import UIKit

class LookDiaryViewController:UIViewController{
    
    var diary:DiaryModel?
    var pictureList:[Data] = []
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SliderViewCell", bundle: nil)
        imageCollectionView.register(nib, forCellWithReuseIdentifier: "SliderViewCell")
        configureCollectionViewFlowLayout()
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        titleTextView.isEditable = false
        diaryTextView.isEditable = false
        setNavigationBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTextView()
    }
    
    func configureTextView(){
        titleTextView.text! = diary!.title
        diaryTextView.text! = diary!.text
        pictureList = Array(diary!.pictureList)
    }
    
    func configureCollectionViewFlowLayout(){
        let layout = UICollectionViewFlowLayout()
        let spacing:CGFloat = 10.0
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        imageCollectionView.collectionViewLayout = layout
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector: Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: buttonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func tapBackButton(){
        self.navigationController?.popViewController(animated: true)
    }
}

extension LookDiaryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictureList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderViewCell", for: indexPath) as! SliderViewCell
        let cellImage = UIImage(data: diary!.pictureList[indexPath.item])!
        cell.imageView.image = cellImage
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let image = UIImage(data: pictureList[indexPath.row])
        let imageSize = image?.size
        let width:CGFloat = imageSize!.width
        let height:CGFloat = imageSize!.height
        let cellWidth = collectionView.bounds.width
        let aspect = cellWidth / width
        let cellHeight = height * aspect
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    
}


