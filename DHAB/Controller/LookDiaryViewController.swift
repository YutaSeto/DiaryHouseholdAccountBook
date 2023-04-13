//
//  LookDiaryViewController.swift
//  DHAB
//
//  Created by setoon on 2023/03/24.
//

import Foundation
import UIKit

class LookDiaryViewController:UIViewController{
    
    let lookDiaryViewModel = LookDiaryViewModel()
    let util = Util()
    var forDiaryViewUpdateDiaryByLookDiaryViewDelegate:UpdateDiaryByLookDiaryViewDelegate?
    var forCalendarViewUpdateDiaryByCalendarViewDelegate:UpdateDiaryByCalendarViewDelegate?
    @IBOutlet weak var diaryTextViewHeight: NSLayoutConstraint!
    
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
        configureTextFont()
        setNavigationBarButton()
        setNavigationBarTitle()
        configureTextView()
        setStatusBarBackgroundColor(.flatPowderBlueColorDark())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureTextView(){
        titleTextView.text! = lookDiaryViewModel.diary!.title
        diaryTextView.text! = lookDiaryViewModel.diary!.text
        lookDiaryViewModel.pictureList = Array(lookDiaryViewModel.diary!.pictureList)
        let height = diaryTextView.sizeThatFits(CGSize(width: diaryTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        diaryTextViewHeight.constant = height
    }
    
    func configureTextFont(){
        titleTextView.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func setNavigationBarTitle(){
        navigationItem.title = util.forLookDiaryViewDateFormatter.string(from:lookDiaryViewModel.diary!.date)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        let rightButtonActionSelector: Selector = #selector(tapEditButton)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: rightButtonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)
    }

    @objc func tapBackButton(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapEditButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
        let navigationController = UINavigationController(rootViewController: inputViewController)
        inputViewController.inputViewModel.diary = lookDiaryViewModel.diary!
        inputViewController.setDiary(data: lookDiaryViewModel.diary!)
        present(navigationController,animated:true)
        inputViewController.addDiaryView()
        inputViewController.inputViewModel.isDiary = true
        inputViewController.forDiaryViewUpdateDiaryByLookDiaryViewDelegate = forDiaryViewUpdateDiaryByLookDiaryViewDelegate
        inputViewController.forCalendarViewUpdateDiaryByCalendarViewDelegate = forCalendarViewUpdateDiaryByCalendarViewDelegate
        inputViewController.forLookDiaryViewUpdateDiaryByCalendarViewDelegate = self
        inputViewController.forLookDiaryViewUpdateDiaryByLookDiaryViewDelegate = self
    }
}

extension LookDiaryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lookDiaryViewModel.pictureList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderViewCell", for: indexPath) as! SliderViewCell
        let cellImage = UIImage(data: lookDiaryViewModel.diary!.pictureList[indexPath.item])!
        cell.imageView.image = cellImage
        cell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let image = UIImage(data: lookDiaryViewModel.pictureList[indexPath.row])
        let imageSize = image?.size
        let width:CGFloat = imageSize!.width
        let height:CGFloat = imageSize!.height
        let cellWidth = collectionView.bounds.width
        let aspect = cellWidth / width
        let cellHeight = height * aspect
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


extension LookDiaryViewController:UpdateDiaryByLookDiaryViewDelegate{
    func configureText(title:String, text:String){
        titleTextView.text = title
        diaryTextView.text = text
    }
    
    func updateDiaryByLookDiaryView() {
        lookDiaryViewModel.pictureList = Array(lookDiaryViewModel.diary!.pictureList)
        
        let constraints = diaryTextView.constraints
        let heightConstraint = constraints.first { $0.firstAttribute == .height }
        heightConstraint!.isActive = false
        
        let height = diaryTextView.sizeThatFits(CGSize(width: diaryTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        diaryTextView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageCollectionView.reloadData()
    }
}

extension LookDiaryViewController:UpdateDiaryByCalendarViewDelegate{
    func updateDiaryByCalendarView() {
        lookDiaryViewModel.pictureList = Array(lookDiaryViewModel.diary!.pictureList)
        let height = diaryTextView.sizeThatFits(CGSize(width: diaryTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        diaryTextView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageCollectionView.reloadData()
    }
}
