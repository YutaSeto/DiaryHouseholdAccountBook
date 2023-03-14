//
//  InputViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift
import DKImagePickerController

protocol InputViewControllerDelegate{
    func updatePayment()
    func updateDiary()
    func updateCalendar()
    func updateIncome()
}

class InputViewController:UIViewController{
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    //家計簿記入画面関連
    var payment:PaymentModel? = nil
    var income:IncomeModel? = nil
    private var paymentModelList: [PaymentModel] = []
    let util = Util()
    let realm = try! Realm()
    var categoryList:[CategoryModel] = []
    public var date:Date = Date()
    public var inputViewControllerDelegate:InputViewControllerDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var continueAddButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    
    var datePicker:UIDatePicker{
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(identifier: "Asia/tokyo")
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ja-JP")
        return datePicker
    }
    
    var toolbar: UIToolbar{
        let toolbarRect = CGRect(x: 0,y: 0, width:view.frame.size.width,height: 35)
        let toolbar = UIToolbar(frame: toolbarRect)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapFinishButton))
        toolbar.setItems([doneItem], animated: modalPresentationCapturesStatusBarAppearance)
        return toolbar
    }
    
    //日記関連
    var diary:DiaryModel?
    var pictureModelList:[PictureModel] = []
    var imageArray:[Data] = []
    var currentIndex = 0
    var collectionViewDelegate:UICollectionViewDelegate?
    private var diaryModel = DiaryModel()
    private var diaryList:[DiaryModel] = []
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addImageButton: UIView!
    @IBOutlet weak var diaryInputTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var addDiaryButton: UIButton!
    
    @IBOutlet weak var diaryDateTextField: UITextField!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        paymentCollectionView.delegate = self
        paymentCollectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        diaryInputTextView.delegate = self
        let nib = UINib(nibName: "SliderViewCell", bundle: nil)
        imageCollectionView.register(nib, forCellWithReuseIdentifier: "SliderViewCell")
        configureSliderCell()
        configureTextfield()
        configureDateTextField()
        addSubView()
        addHouseholdAccountView()
        settingSubView()
        dateTextField.text = util.dayDateFormatter.string(from: date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: date)
        settingCollectionView()
        setCategoryData()
        resultLabel.text = ""
        configureAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setPaymentOrIncomeData()
    }
    
    func setPaymentData(data:PaymentModel){
        payment = data
        priceTextField.text = String(payment!.price)
        resultLabel.text = payment?.category
        date = payment!.date
    }
    
    func setIncomeData(data:IncomeModel){
        income = data
        priceTextField.text = String(income!.amount)
        resultLabel.text = income?.category
        date = income!.date
    }
    
    func setPaymentOrIncomeData(){
        if payment != nil{
            resultLabel.text = payment?.category
            priceTextField.text = String(payment!.price)
            date = payment!.date
            resultLabel.text = payment?.category
        }else if income != nil{
            resultLabel.text = income?.category
            date = income!.date
            priceTextField.text = String(income!.amount)
        }
    }
    
    func setDiary(data:DiaryModel){
        diary = data
        titleTextField.text = diary!.text
        diaryInputTextView.text = diary!.text
        date = diary!.date
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
    
    @objc func didTapFinishButton(){
        if let targetDateText = dateTextField.text,
           let targetDate = util.monthDateFormatter.date(from:targetDateText){
            date = targetDate.zeroclock
        }
        if let targetDateText = diaryDateTextField.text,
           let targetDate = util.monthDateFormatter.date(from: targetDateText){
            date = targetDate.zeroclock
        }
        view.endEditing(true)
    }
    
    func configureDateTextField(){
        let householdAccountBookDatePicker = datePicker
        let targetDate = Date()
        householdAccountBookDatePicker.date = targetDate
        dateTextField.inputView = householdAccountBookDatePicker
        dateTextField.text = util.dayDateFormatter.string(from: targetDate)
        dateTextField.inputAccessoryView = toolbar
        householdAccountBookDatePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        householdAccountBookDatePicker.date = targetDate
        diaryDateTextField.inputView = householdAccountBookDatePicker
        diaryDateTextField.text = util.monthDateFormatter.string(from: targetDate)
        diaryDateTextField.inputAccessoryView = toolbar
        householdAccountBookDatePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        
    }
    
    @objc func didChangeDate(picker: UIDatePicker){
        date = picker.date
        dateTextField.text = util.dayDateFormatter.string(from: picker.date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: picker.date)
    }
    
    @IBAction func textFieldActionAddButtonInactive(_ sender: Any) {
        if payment != nil || income != nil{
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }else if priceTextField.text != "" && resultLabel.text != ""{
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }else{
            addButton.isEnabled = false
            continueAddButton.isEnabled = false
        }
    }
    
    func configureAddButton(){
        if payment != nil || income != nil{
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }else if diary != nil{
            addDiaryButton.isEnabled = true
        }else{
            addButton.isEnabled = false
            continueAddButton.isEnabled = false
            addDiaryButton.isEnabled = false
        }
    }
    
    private func tapAddButton(){
        if payment == nil && income == nil{
            let realm = try! Realm()
            try! realm.write{
                let paymentModel = PaymentModel()
                paymentModel.date = date
                paymentModel.price = Int(priceTextField.text!) ?? 0
                paymentModel.category = resultLabel.text!
                realm.add(paymentModel)
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
        }else if payment != nil{ //paymetTableViewを選択した場合
//            if resultLabel.text == {  正しく支出を修正した場合
                let realm = try! Realm()
                try! realm.write{
                    payment?.date = date
                    payment?.price = Int(priceTextField.text!) ?? 0
                    payment?.category = resultLabel.text!
                }
            inputViewControllerDelegate?.updatePayment()
            inputViewControllerDelegate?.updateCalendar()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
            //            }else if resultLabel.text == { //支出選択から収入に変更した場合
            
            //            }
            //正しく収入を修正した場合
        }else if income != nil{
            let realm = try! Realm()
            try! realm.write{
                income?.date = date
                income?.amount = Int(priceTextField.text!) ?? 0
                income?.category = resultLabel.text!
            }
            inputViewControllerDelegate?.updateIncome()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
            //誤って支出に修正した場合
//            else if resultLabel.text =={
//
//            }
        }
    }
    
    private func tapContinueAddButton(){
        let realm = try! Realm()
        if payment == nil && income == nil{
            try! realm.write{
                let paymentModel = PaymentModel()
                paymentModel.date = date.zeroclock
                paymentModel.price = Int(priceTextField.text!) ?? 0
                paymentModel.category = resultLabel.text!
                realm.add(paymentModel)
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            resultLabel.text = ""
            priceTextField.text = ""
        }else if payment != nil{
            let realm = try! Realm()
            try! realm.write{
                payment?.date = date.zeroclock
                payment?.price = Int(priceTextField.text!) ?? 0
                payment?.category = resultLabel.text!
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            payment = nil
        }else if income != nil{
            let realm = try! Realm()
            try! realm.write{
                income?.date = date.zeroclock
                income?.amount = Int(priceTextField.text!) ?? 0
                income?.category = resultLabel.text!
            }
            inputViewControllerDelegate?.updateIncome()
            RecognitionChange.shared.updateCalendar = true
            income = nil
        }
    }
    
    func configureTextfield(){
        priceTextField.textAlignment = NSTextAlignment.right
    }
    
    func settingCollectionView(){
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: collectionView.frame.width / 4,height: collectionView.frame.height / 3)
    }
    
    func dayBack(){
        date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        dateTextField.text = util.dayDateFormatter.string(from: date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: date)
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        dateTextField.text = util.dayDateFormatter.string(from: date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: date)
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
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
        collectionViewDelegate = self
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.mediaTypes = ["public.image"]
        present(picker, animated:true)
    }
    
    @IBAction func titleTextFieldActionDiaryButtonInactive(_ sender: Any) {
        if titleTextField.text != "" && diaryInputTextView.text != ""{
            addDiaryButton.isEnabled = true
        }else{
            addDiaryButton.isEnabled = false
        }
    }
    
    
    private func addDiary(){
        if diary == nil{
            let realm = try! Realm()
            try! realm.write{
                diaryModel.date = date.zeroclock
                diaryModel.title = titleTextField.text!
                diaryModel.text = diaryInputTextView.text
                diaryModel.pictureList.append(objectsIn: pictureModelList)
                realm.add(diaryModel)
            }
            titleTextField.text = ""
            diaryInputTextView.text = ""
            inputViewControllerDelegate?.updateDiary()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
        }else{
            let realm = try! Realm()
            try! realm.write{
                diary!.date = date.zeroclock
                diary!.title = titleTextField.text!
                diary!.text = diaryInputTextView.text
                diary!.pictureList.append(objectsIn: pictureModelList)
            }
            titleTextField.text = ""
            diaryInputTextView.text = ""
            inputViewControllerDelegate?.updateDiary()
            RecognitionChange.shared.updateCalendar = true
            diary = nil
            dismiss(animated: true)
        }
    }
}

extension InputViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0{
            return categoryList.count
        }else if collectionView.tag == 1{
            return imageArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0{
            let sectionInsets = UIEdgeInsets(top: 10, left: 2, bottom: 2, right: 10)
            let itemsPerRow: CGFloat = 4
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: 40)
        }else if collectionView.tag == 1{
            return CGSize(width: imageCollectionView.frame.width, height: imageCollectionView.frame.height)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0{
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let contentLabel = cell.contentView.viewWithTag(1) as! UILabel
            contentLabel.text = categoryList[indexPath.row].name
            contentLabel.adjustsFontSizeToFitWidth = true
            return cell
        }else if collectionView.tag == 1{
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderViewCell", for: indexPath)
            let contentImageView = cell.contentView.viewWithTag(1) as! UIImageView
            let cellImage = imageArray[indexPath.item]
            contentImageView.image = UIImage(data:cellImage)!
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0{
            resultLabel.text = categoryList[indexPath.row].name
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            return
        }else if collectionView.tag == 1{
            return
        }
        return
    }
    
    //修正必要。大きさがアスペクト比を崩さずに、コレクションビューセルの縦の幅に合わせるよう
    func configureSliderCell(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80,height: imageCollectionView.frame.height)
        imageCollectionView.collectionViewLayout = layout
    }
}

extension InputViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout{
   
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        let realm = try! Realm()
        try! realm.write{
            let result = PictureModel()
            result.imageData = (info[.originalImage] as! UIImage).pngData()!
            result.createdAt = date.zeroclock
            realm.add(result)
        }
        imageArray.append((info[.originalImage] as! UIImage).pngData()!)
        imageCollectionView.reloadData()
        dismiss(animated:true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / imageCollectionView.frame.size.width)
    }
}

extension InputViewController:UITextViewDelegate{
    public func textViewDidChange(_ textView: UITextView) {
        if diaryInputTextView.text != "" && titleTextField.text != ""{
            addDiaryButton.isEnabled = true
        }else{
            addDiaryButton.isEnabled = false
        }
    }
}
