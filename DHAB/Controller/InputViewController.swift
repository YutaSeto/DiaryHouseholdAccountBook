//
//  InputViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift

protocol InputViewControllerDelegate{
    func updatePayment()
    func updateDiary()
    func updateCalendar()
}

class InputViewController:UIViewController{
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    //家計簿記入画面関連
    private var paymentModelList: [PaymentModel] = []
    let realm = try! Realm()
    var categoryList:[CategoryModel] = []
    var uniqueCategory = [""]
    public var date:Date = Date()
    public var inputViewControllerDelegate:InputViewControllerDelegate?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    
    //日記関連
    var imageArray = [UIImage(named: "sample1")!]
    var currentIndex = 0
    private var diaryModel = DiaryModel()
    private var diaryList:[DiaryModel] = []
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var diaryDateLabel: UILabel!
    @IBOutlet weak var addImageButton: UIView!
    @IBOutlet weak var diaryInputTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        addSubView()
        addHouseholdAccountView()
        settingSubView()
        dateLabel.text = dateFormatter.string(from:date)
        diaryDateLabel.text = dateFormatter.string(from: date)
        paymentCollectionView.delegate = self
        paymentCollectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        settingCollectionView()
        setCategoryData()
        setUniqueCategory()
        resultLabel.text = ""
        let nib = UINib(nibName: "SliderViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SliderViewCell")
    }
    
    func addSubView(){
        view.addSubview(householdAccountBookView)
        view.addSubview(diaryView)
    }
    
    private func addHouseholdAccountView(){
        diaryView.isHidden = true
        householdAccountBookView.isHidden = false
    }
    
    func addDiaryView(){
        householdAccountBookView.isHidden = true
        diaryView.isHidden = false
    }
    
    private func settingSubView(){
        householdAccountBookView.translatesAutoresizingMaskIntoConstraints = false
        householdAccountBookView.topAnchor.constraint(equalTo: viewChangeSegmentedControl.bottomAnchor,constant: 10).isActive = true
        householdAccountBookView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        householdAccountBookView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        householdAccountBookView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        diaryView.translatesAutoresizingMaskIntoConstraints = false
        diaryView.topAnchor.constraint(equalTo: viewChangeSegmentedControl.bottomAnchor,constant: 10).isActive = true
        diaryView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        diaryView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        diaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //segmentedControll関連
    @IBAction func viewChangeSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addHouseholdAccountView()
        case 1:
            addDiaryView()
        default:
            return
        }
    }
    
    //日付操作関連
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        tapAddButton()
    }
    
    @IBAction func continueAddButton(_ sender: UIButton) {
        tapContinueAddButton()
    }
    
    //家計簿関連
    private func tapAddButton(){
        let realm = try! Realm()
        try! realm.write{
            let paymentModel = PaymentModel()
            paymentModel.date = date
            paymentModel.price = Int(priceTextField.text!) ?? 0
            paymentModel.category = resultLabel.text!
            realm.add(paymentModel)
        }
        inputViewControllerDelegate?.updatePayment()
        inputViewControllerDelegate?.updateCalendar()
        
        dismiss(animated: true)
    }
    
    private func tapContinueAddButton(){
        let realm = try! Realm()
        try! realm.write{
            let paymentModel = PaymentModel()
            paymentModel.date = date
            paymentModel.price = Int(priceTextField.text!) ?? 0
            paymentModel.category = resultLabel.text!
            realm.add(paymentModel)
        }
        inputViewControllerDelegate?.updatePayment()
        resultLabel.text = ""
        priceTextField.text = ""
    }
    
    private var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    
    func settingCollectionView(){
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: collectionView.frame.width / 3,height: collectionView.frame.height / 3)
    }
    
    func dayBack(){
        date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        dateLabel.text = dateFormatter.string(from: date)
        diaryDateLabel.text = dateFormatter.string(from: date)
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        dateLabel.text = dateFormatter.string(from: date)
        diaryDateLabel.text = dateFormatter.string(from: date)
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
    }
    
    func setUniqueCategory(){
        uniqueCategory = Array(Set(categoryList.map({$0.name})))
    }
    
    //日記記入関連の画面
    @IBAction func diaryDayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func diaryDayPassButton(_ sender: UIButton) {
        dayPass()
    }
    
    @IBAction func addDiaryButton(_ sender: UIButton) {
        addDiary()
    }
    @IBAction func addImageButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated:true)
    }
    
    private func addDiary(){
        let realm = try! Realm()
        try! realm.write{
            diaryModel.date = date
            diaryModel.title = titleTextField.text!
            diaryModel.text = diaryInputTextView.text
            realm.add(diaryModel)
        }
        titleTextField.text = ""
        diaryInputTextView.text = ""
        inputViewControllerDelegate?.updateDiary()
        dismiss(animated: true)
    }
}

extension InputViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let contentLabel = cell.contentView.viewWithTag(1) as! UILabel
        contentLabel.text = uniqueCategory[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        resultLabel.text = uniqueCategory[indexPath.row]
    }
}


extension InputViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout{
    
    private func imagePickerConroller(_ Picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String: Any]){
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return imageArray.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderViewCell
            let contentImageView = cell.contentView.viewWithTag(0) as! UIImageView
            cell.image = imageArray[indexPath.item]
            contentImageView.image = imageArray[indexPath.item]
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: imageCollectionView.frame.width, height: imageCollectionView.frame.height)
        }
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            currentIndex = Int(scrollView.contentOffset.x / imageCollectionView.frame.size.width)
        }
        //画像選択時の処理
        let images = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        //キャンセル時の処理
    }
}
