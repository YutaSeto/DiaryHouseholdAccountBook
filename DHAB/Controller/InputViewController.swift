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
}

class InputViewController:UIViewController{
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    private func addHouseholdAccountView(){
        diaryView.removeFromSuperview()
        self.view.addSubview(householdAccountBookView)
    }
    func addDiaryView(){
        householdAccountBookView.removeFromSuperview()
        self.view.addSubview(diaryView)
    }
    
    private func settingSubView(){
        householdAccountBookView.frame = CGRect(x: 0,
                                                y: viewChangeSegmentedControl.frame.minY + viewChangeSegmentedControl.frame.height,
                                                width: self.view.frame.width,
                                                height: (self.view.frame.height - viewChangeSegmentedControl.frame.minY))
        diaryView.frame = CGRect(x: 0,
                                 y: viewChangeSegmentedControl.frame.minY + viewChangeSegmentedControl.frame.height,
                                 width: self.view.frame.width,
                                 height: (self.view.frame.height - viewChangeSegmentedControl.frame.minY))
    }
    
    //segmentedControll関連
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        addHouseholdAccountView()
        settingSubView()
        dateLabel.text = dateFormatter.string(from:date)
        diaryDateLabel.text = dateFormatter.string(from: date)
        paymentCollectionView.delegate = self
        paymentCollectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        picker.delegate = self
        settingCollectionView()
        setCategoryData()
        setUniqueCategory()
        resultLabel.text = ""
        
        let nib = UINib(nibName: "SliderViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "SliderViewCell")

        
    }
    
    //家計簿記入画面関連
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    public var date:Date = Date()
    public var inputViewControllerDelegate:InputViewControllerDelegate?
    @IBOutlet weak var priceTextField: UITextField!
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
    }
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    
    @IBAction func addButton(_ sender: UIButton) {
        tapAddButton()
    }
    
    @IBAction func continueAddButton(_ sender: UIButton) {
        tapContinueAddButton()
    }
    
    private var paymentModelList: [PaymentModel] = []
    let realm = try! Realm()
    var categoryList:[CategoryModel] = []
    var uniqueCategory = [""]
    
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
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var diaryDateLabel: UILabel!
    @IBOutlet var addImageButton: UIView!
    @IBOutlet weak var diaryInputTextView: UITextView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
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
        present(picker, animated:true)
    }
    
    var imageArray = [UIImage(named: "sample1")!]
    var currentIndex = 0
    
    let picker = UIImagePickerController()
    private var diaryModel = DiaryModel()
    private var diaryList:[DiaryModel] = []
    
    
    
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
          cell.image = imageArray[indexPath.item]
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
