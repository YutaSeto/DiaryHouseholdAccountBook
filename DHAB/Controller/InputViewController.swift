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
    func didReceiveNotification()
    func changeFromPaymentToIncome()
    func changeFromIncomeToPayment()
}

class InputViewController:UIViewController{
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    //家計簿記入画面関連
    var payment:JournalModel? = nil
    var income:JournalModel? = nil
    var selectedIndexPath: IndexPath?
    var selectedIncomeIndexPath: IndexPath?
    var isPayment:Bool = true
    let util = Util()
    let realm = try! Realm()
    var categoryList:[CategoryModel] = []
    var incomeCategoryList:[CategoryModel] = []
    public var date:Date = Date()
    public var inputViewControllerDelegate:InputViewControllerDelegate?
    public var inputViewControllerDelegate2:InputViewControllerDelegate?
    @IBOutlet weak var incomeCollectionView: UICollectionView!
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
        incomeCollectionView.delegate = self
        incomeCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        diaryInputTextView.delegate = self
        let nib = UINib(nibName: "SliderViewCell", bundle: nil)
        let collectionViewNib = UINib(nibName: "InputCollectionViewCell", bundle: nil)
        imageCollectionView.register(nib, forCellWithReuseIdentifier: "SliderViewCell")
        paymentCollectionView.register(collectionViewNib, forCellWithReuseIdentifier: "customCell")
        incomeCollectionView.register(collectionViewNib, forCellWithReuseIdentifier: "customCell")
        configureTextfield()
        configureDateTextField()
        addSubView()
        addHouseholdAccountView()
        settingSubView()
        dateTextField.text = util.dayDateFormatter.string(from: date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: date)
        settingCollectionView()
        setCategoryData()
        setIncomeCategoryData()
        configureAddButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAddButton()
    }
    
    //遷移先のボタンの色を変更することができていない。cellがnilになるのはどうしてか。
    func setPaymentData(data:JournalModel){
        payment = data
        priceTextField.text = String(data.price)
        resultLabel.text = data.category
        isPayment = true
        date = data.date
        setCategoryData()
        paymentCollectionView.dataSource = self
        paymentCollectionView.delegate = self
        paymentCollectionView.reloadData()
        
        if let selectedItem = paymentCollectionView.indexPathsForSelectedItems?.first{
            paymentCollectionView.cellForItem(at: selectedItem)?.backgroundColor = .white
        }
        
        
        let index:Int = categoryList.firstIndex(where: {$0.name == payment!.category})!
        let indexPath:IndexPath = IndexPath(item: index, section: 0)
        paymentCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        collectionView(paymentCollectionView, didSelectItemAt: indexPath)
    }
    
    func setIncomeData(data:JournalModel){
        income = data
        priceTextField.text = String(income!.price)
        resultLabel.text = income?.category
        isPayment = false
        date = income!.date
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
        inputViewControllerDelegate2?.didReceiveNotification()
    }
    
    @IBAction func continueAddButton(_ sender: UIButton) {
        tapContinueAddButton()
        inputViewControllerDelegate2?.didReceiveNotification()
        if let selectedItem = paymentCollectionView.indexPathsForSelectedItems?.first{
            paymentCollectionView.cellForItem(at: selectedItem)?.backgroundColor = .white
        }
        if let selectedItem = incomeCollectionView.indexPathsForSelectedItems?.first{
            incomeCollectionView.cellForItem(at: selectedItem)?.backgroundColor = .white
        }
        payment = nil
        income = nil
        
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
                let journalModel = JournalModel()
                journalModel.date = date
                journalModel.price = Int(priceTextField.text!) ?? 0
                journalModel.category = resultLabel.text!
                journalModel.isPayment = isPayment
                realm.add(journalModel)
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
        }else if payment != nil{ //paymetTableViewを選択した場合
            let realm = try! Realm()
            try! realm.write{
                payment?.date = date
                payment?.isPayment = isPayment
                payment?.price = Int(priceTextField.text!) ?? 0
                payment?.category = resultLabel.text!
            }
            if isPayment == false{
                inputViewControllerDelegate?.changeFromPaymentToIncome()
            }
            inputViewControllerDelegate?.updatePayment()
            inputViewControllerDelegate?.updateCalendar()
            RecognitionChange.shared.updateCalendar = true
            payment = nil
            income = nil
            dismiss(animated: true)
        }else if income != nil{
            let realm = try! Realm()
            try! realm.write{
                income?.date = date
                income?.isPayment = isPayment
                income?.price = Int(priceTextField.text!) ?? 0
                income?.category = resultLabel.text!
            }
            if isPayment == true{
                inputViewControllerDelegate?.changeFromIncomeToPayment()
            }
            inputViewControllerDelegate?.updateIncome()
            inputViewControllerDelegate?.updateCalendar()
            RecognitionChange.shared.updateCalendar = true
            payment = nil
            income = nil
            dismiss(animated: true)
        }
    }
    
    private func tapContinueAddButton(){
        let realm = try! Realm()
        if payment == nil && income == nil{
            try! realm.write{
                let journalModel = JournalModel()
                journalModel.date = date.zeroclock
                journalModel.price = Int(priceTextField.text!) ?? 0
                journalModel.isPayment = isPayment
                journalModel.category = resultLabel.text!
                realm.add(journalModel)
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            resultLabel.text = ""
            priceTextField.text = ""
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }else if payment != nil && income == nil{
            let realm = try! Realm()
            try! realm.write{
                payment?.date = date.zeroclock
                payment?.isPayment = isPayment
                payment?.price = Int(priceTextField.text!) ?? 0
                payment?.category = resultLabel.text!
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            payment = nil
            resultLabel.text = ""
            priceTextField.text = ""
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }else if income != nil && payment == nil {
            let realm = try! Realm()
            try! realm.write{
                income?.date = date.zeroclock
                income?.isPayment = isPayment
                income?.price = Int(priceTextField.text!) ?? 0
                income?.category = resultLabel.text!
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            income = nil
            resultLabel.text = ""
            priceTextField.text = ""
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }
    }
    
    func configureTextfield(){
        priceTextField.textAlignment = NSTextAlignment.right
    }
    
    func settingCollectionView(){
        
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: paymentCollectionView.frame.width / 4,height: paymentCollectionView.frame.height / 3)
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        paymentCollectionView.layer.borderWidth = 1.0
        paymentCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        paymentCollectionView.layer.cornerRadius = 1.0
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
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == true}
        categoryList = Array(result)
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
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
        }else if collectionView.tag == 2{
            return incomeCategoryList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! InputCollectionViewCell
            cell.categoryLabel.text = categoryList[indexPath.row].name
            return cell
        }else if collectionView.tag == 1{
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderViewCell", for: indexPath)
            let contentImageView = cell.contentView.viewWithTag(1) as! UIImageView
            let cellImage = UIImage(data: imageArray[indexPath.item])!
            contentImageView.image = cellImage
            return cell
        }else if collectionView.tag == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! InputCollectionViewCell
            cell.categoryLabel.text = incomeCategoryList[indexPath.row].name
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0{
            let sectionInsets = UIEdgeInsets(top: 5, left: 2, bottom: 2, right: 5)
            let itemsPerRow: CGFloat = 4
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: 40)
        }else if collectionView.tag == 1{
            let cellWidth = collectionView.frame.width / 5
            let cellHeight = cellWidth
            return CGSize(width: cellWidth, height: cellHeight)
        }else if collectionView.tag == 2{
            let sectionInsets = UIEdgeInsets(top: 5, left: 2, bottom: 2, right: 5)
            let itemsPerRow: CGFloat = 4
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            return CGSize(width: widthPerItem, height: 40)
        }
        return CGSize(width: 0, height: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0{
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .lightGray
            resultLabel.text = categoryList[indexPath.row].name
            if selectedIndexPath != nil{
                if indexPath != selectedIndexPath{
                    paymentCollectionView.cellForItem(at:selectedIndexPath!)?.backgroundColor = .white
                    selectedIndexPath = indexPath
                }
            }else{
                selectedIndexPath = indexPath
            }
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            isPayment = true
            guard selectedIncomeIndexPath != nil else{return}
            incomeCollectionView.cellForItem(at: selectedIncomeIndexPath!)?.backgroundColor = .white
            selectedIncomeIndexPath = nil
            return
        }else if collectionView.tag == 1{
            return
        }else if collectionView.tag == 2{
            let cell = incomeCollectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .lightGray
            resultLabel.text = incomeCategoryList[indexPath.row].name
            if selectedIncomeIndexPath != nil{
                if indexPath != selectedIncomeIndexPath{
                    incomeCollectionView.cellForItem(at:selectedIncomeIndexPath!)?.backgroundColor = .white
                    selectedIncomeIndexPath = indexPath
                }
            }else{
                selectedIncomeIndexPath = indexPath
            }
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            isPayment = false
            cell?.backgroundColor = .lightGray
            guard selectedIndexPath != nil else{return}
            paymentCollectionView.cellForItem(at: selectedIndexPath!)?.backgroundColor = .white
            selectedIndexPath = nil
            return
        }
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
