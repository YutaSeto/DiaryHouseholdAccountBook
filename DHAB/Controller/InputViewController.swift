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
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!
    //家計簿記入画面関連
    var journal:JournalModel? = nil
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
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var continueAddButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    
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
    var isDiary:Bool = false
    var diary:DiaryModel?
    var selectedIndex:Int?
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
    @IBOutlet weak var countLabel: UILabel!
    
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
        setNavigationBarButton()
        setToolbar()
        configureTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAddButton()
        
        if isDiary == true{
            viewChangeSegmentedControl.selectedSegmentIndex = 1
            addDiaryView()
        }
        
        if diary != nil || journal != nil{
            viewChangeSegmentedControl.isHidden = true
            segmentedControlHeight.constant = 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        settingCollectionViewAutoLayout()
    }
    
    func setToolbar(){
        titleTextField.inputAccessoryView = toolbar
        priceTextField.inputAccessoryView = toolbar
        memoTextField.inputAccessoryView = toolbar
        diaryInputTextView.inputAccessoryView = toolbar
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector: Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: buttonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func tapBackButton(){
        dismiss(animated: true)
    }
    
    func setPaymentData(data:JournalModel){
        journal = data
        priceTextField.text = String(data.price)
        resultLabel.text = data.category
        isPayment = journal!.isPayment
        date = data.date
        setCategoryData()
        if data.memo != ""{
            memoTextField.text = data.memo
        }
        paymentCollectionView.dataSource = self
        paymentCollectionView.delegate = self
        paymentCollectionView.reloadData()
        
    }
    
    func setIncomeData(data:JournalModel){
        journal = data
        priceTextField.text = String(journal!.price)
        resultLabel.text = journal?.category
        isPayment = false
        date = journal!.date
        if data.memo != ""{
            memoTextField.text = data.memo
        }
    }
    
    func setDiary(data:DiaryModel){
        diary = data
        titleTextField.text = diary!.text
        diaryInputTextView.text = diary!.text
        date = diary!.date
        imageArray = Array(data.pictureList)
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
    
    private func settingCollectionViewAutoLayout(){
        paymentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        paymentCollectionView.topAnchor.constraint(equalTo: dateTextField.bottomAnchor,constant: 10).isActive = true
        paymentCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        paymentCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        let numberOfItems = categoryList.count
        let itemHeight: CGFloat = 38.0
        let space: CGFloat = 5
        
        func returnRows(items:Int) -> Int{
            if items <= 4{
                return 1
            }else if items <= 8{
                return 2
            }else if items <= 12{
                return 3
            }
            return 1
        }
        let paymentCollectionHeight = CGFloat((returnRows(items: numberOfItems) * Int(itemHeight)) + Int(returnRows(items: numberOfItems) - 2) * Int(space))
        let incomeNumberOfItems = incomeCategoryList.count
        paymentCollectionView.heightAnchor.constraint(equalToConstant: paymentCollectionHeight).isActive = true
        incomeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        incomeCollectionView.topAnchor.constraint(equalTo: paymentCollectionView.bottomAnchor,constant: 10).isActive = true
        incomeCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        incomeCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 10).isActive = true
        let incomeCollectionHeight = CGFloat((returnRows(items: incomeNumberOfItems) * Int(itemHeight)) + Int(returnRows(items: incomeNumberOfItems) - 1) * Int(space))
        incomeCollectionView.heightAnchor.constraint(equalToConstant: incomeCollectionHeight).isActive = true
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
        journal = nil
        
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
        if journal != nil{
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
    
    func configureTextView(){
        diaryInputTextView.layer.borderWidth = 1
        diaryInputTextView.layer.borderColor = UIColor.systemGray.cgColor
        diaryInputTextView.layer.cornerRadius = 5
        diaryInputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        countLabel.alpha = 0.3
    }
    
    func configureAddButton(){
        if journal != nil{
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
        if journal == nil{
            let realm = try! Realm()
            try! realm.write{
                let journalModel = JournalModel()
                journalModel.date = date
                journalModel.price = Int(priceTextField.text!) ?? 0
                journalModel.category = resultLabel.text!
                journalModel.isPayment = isPayment
                journalModel.memo = memoTextField.text!
                realm.add(journalModel)
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
        }else if journal != nil{ //paymetTableViewを選択した場合
            if journal?.isPayment == true{
                let realm = try! Realm()
                try! realm.write{
                    journal?.date = date
                    journal?.isPayment = isPayment
                    journal?.price = Int(priceTextField.text!) ?? 0
                    journal?.category = resultLabel.text!
                    journal?.memo = memoTextField.text!
                }
                if isPayment == false{
                    inputViewControllerDelegate?.changeFromPaymentToIncome()
                }
            }else if journal?.isPayment == false{
                try! realm.write{
                    journal?.date = date
                    journal?.isPayment = isPayment
                    journal?.price = Int(priceTextField.text!) ?? 0
                    journal?.category = resultLabel.text!
                    journal?.memo = memoTextField.text!
                }
                if isPayment == true{
                    inputViewControllerDelegate?.changeFromIncomeToPayment()
                }
            }
            inputViewControllerDelegate?.updatePayment()
            inputViewControllerDelegate?.updateCalendar()
            RecognitionChange.shared.updateCalendar = true
            journal = nil
            dismiss(animated: true)
        }
    }
    
    private func tapContinueAddButton(){
        let realm = try! Realm()
        if journal == nil{
            try! realm.write{
                let journalModel = JournalModel()
                journalModel.date = date.zeroclock
                journalModel.price = Int(priceTextField.text!) ?? 0
                journalModel.isPayment = isPayment
                journalModel.category = resultLabel.text!
                journalModel.memo = memoTextField.text!
                realm.add(journalModel)
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            resultLabel.text = ""
            priceTextField.text = ""
            addButton.isEnabled = false
            continueAddButton.isEnabled = false
        }else if journal != nil{
            let realm = try! Realm()
            try! realm.write{
                journal?.date = date.zeroclock
                journal?.isPayment = isPayment
                journal?.price = Int(priceTextField.text!) ?? 0
                journal?.category = resultLabel.text!
                journal?.memo = memoTextField.text!
            }
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            journal = nil
            resultLabel.text = ""
            priceTextField.text = ""
            addButton.isEnabled = false
            continueAddButton.isEnabled = false
        }
    }
    
    func configureTextfield(){
        priceTextField.placeholder = "金額を記入してください"
        priceTextField.textAlignment = NSTextAlignment.right
        memoTextField.placeholder = "店名や商品名など"
        memoTextField.textAlignment = NSTextAlignment.right
    }
    
    func settingCollectionView(){
        
        paymentCollectionView.layer.borderWidth = 1.0
        paymentCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        paymentCollectionView.layer.cornerRadius = 5.0
        incomeCollectionView.layer.borderWidth = 1.0
        incomeCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        incomeCollectionView.layer.cornerRadius = 5.0
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
    
    @objc func diaryInputTextViewDidChange(_ textView:UITextView){
        let count = diaryInputTextView.text.count
        countLabel.text = "\(count) / 2000"
    }
    
    
    private func addDiary(){
        if diary == nil{
            let realm = try! Realm()
            try! realm.write{
                diaryModel.date = date.zeroclock
                diaryModel.title = titleTextField.text!
                diaryModel.text = diaryInputTextView.text
                diaryModel.pictureList.append(objectsIn: imageArray)
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
                diary!.pictureList.removeAll()
                diary!.date = date.zeroclock
                diary!.title = titleTextField.text!
                diary!.text = diaryInputTextView.text
                diary!.pictureList.append(objectsIn: imageArray)
            }
            titleTextField.text = ""
            diaryInputTextView.text = ""
            inputViewControllerDelegate?.updateDiary()
            RecognitionChange.shared.updateCalendar = true
            diary = nil
            dismiss(animated: true)
        }
    }
    
    func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: (image.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (image.cgImage?.colorSpace!)!, bitmapInfo: (image.cgImage?.bitmapInfo.rawValue)!)

        ctx?.concatenate(transform)

        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        if let cgImage = ctx?.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return image
        }
    }
}

extension InputViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === paymentCollectionView{
            return categoryList.count
        }else if collectionView === imageCollectionView{
            return imageArray.count
        }else if collectionView === incomeCollectionView{
            return incomeCategoryList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === paymentCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! InputCollectionViewCell
            cell.categoryLabel.text = categoryList[indexPath.row].name
            if journal != nil{
                cell.journal = journal!
                cell.toggleSelection()
            }
            return cell
        }else if collectionView === imageCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderViewCell", for: indexPath) as! SliderViewCell
            let cellImage = fixImageOrientation(UIImage(data: imageArray[indexPath.item])!)
            cell.imageView.image = cellImage
            cell.imageView.contentMode = .scaleAspectFit
            return cell
        }else if collectionView === incomeCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! InputCollectionViewCell
            cell.categoryLabel.text = incomeCategoryList[indexPath.row].name

            if journal != nil{
                cell.journal = journal!
            }
            cell.toggleSelection()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === paymentCollectionView{
            let cellWidth = paymentCollectionView.bounds.width / 4 - 20
            let labelHeight:CGFloat = 18.0
            let cellHeight = labelHeight + 10
            return CGSize(width: cellWidth, height: cellHeight)
        }else if collectionView === imageCollectionView{
            let cellWidth = collectionView.frame.width / 5
            let cellHeight = cellWidth
            return CGSize(width: cellWidth, height: cellHeight)
        }else if collectionView === incomeCollectionView{
            let cellWidth = incomeCollectionView.bounds.width / 4 - 20
            let labelHeight:CGFloat = 18.0
            let cellHeight = labelHeight + 10
            return CGSize(width: cellWidth, height: cellHeight)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === paymentCollectionView{
            let cell = collectionView.cellForItem(at: indexPath)
            resultLabel.text = categoryList[indexPath.row].name
            
            for i in 0 ..< categoryList.count{
                collectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            for i in 0 ..< incomeCategoryList.count{
                incomeCollectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            isPayment = true
            
            return
        }else if collectionView === imageCollectionView{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let pictureViewController = storyboard.instantiateViewController(withIdentifier: "PictureViewController") as? PictureViewController else{return}
            self.navigationController?.pushViewController(pictureViewController, animated: true)
            
            let selectedImage = imageArray[indexPath.item]
            selectedIndex = indexPath.item
            pictureViewController.inputViewControllerImage = selectedImage
            pictureViewController.pictureViewControllerDelegate = self
        }else if collectionView === incomeCollectionView{
            let cell = incomeCollectionView.cellForItem(at: indexPath)
            resultLabel.text = incomeCategoryList[indexPath.row].name
            
            for i in 0 ..< categoryList.count{
                paymentCollectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            for i in 0 ..< incomeCategoryList.count{
                incomeCollectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            isPayment = false
            return
        }
    }
    
    @objc func dismissZoomImageView(_ sender: UITapGestureRecognizer) {
        guard let zoomView = sender.view else { return }
        UIView.animate(withDuration: 0.3, animations: {
            zoomView.alpha = 0
        }) { _ in
            zoomView.removeFromSuperview()
        }
    }
}

extension InputViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        
        let image = (info[.originalImage] as! UIImage)
        let imageData = image.jpegData(compressionQuality: 0.5)

        imageArray.append(imageData!)
        imageCollectionView.reloadData()
        dismiss(animated:true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / imageCollectionView.frame.size.width)
    }
}

extension InputViewController:UITextViewDelegate{
    public func textViewDidChange(_ textView: UITextView) {
        countLabel.text = String("\(diaryInputTextView.text.count)/2000")
        
        if diaryInputTextView.text!.count <= 2000 && diaryInputTextView.text != "" && titleTextField.text != ""{
            addDiaryButton.isEnabled = true
        }else{
            addDiaryButton.isEnabled = false
        }
    }
}

extension InputViewController:PictureViewControllerDelegate{
    func deletePicuture() {
        imageArray.remove(at: selectedIndex!)
        print(imageArray.count)
        imageCollectionView.reloadData()
    }
}
