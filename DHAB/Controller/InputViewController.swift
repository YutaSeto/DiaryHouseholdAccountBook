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
import ChameleonFramework

protocol InputViewControllerDelegate{
    func updatePayment()
    func updateDiary()
    func updateCalendar()
    func didReceiveNotification()
    func changeFromPaymentToIncome()
    func changeFromIncomeToPayment()
}

protocol InputByStartUpModalDelegate{
    func updateJournal()
    func updateDiaryAndCalendar()
    func fixSelectedDate(date:Date)
}

protocol UpdateDiaryByLookDiaryViewDelegate{
    func updateDiaryByLookDiaryView()
    func configureText(title:String,text:String)
}

protocol UpdateDiaryByCalendarViewDelegate{
    func updateDiaryByCalendarView()
}

class InputViewController:UIViewController{
    
    let inputViewModel = InputViewModel()
    let util = Util()
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var householdAccountBookScrollView: UIScrollView!
    
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!
    //家計簿記入画面関連
    var inputViewControllerDelegate:InputViewControllerDelegate?
    var inputByStartUpModalDelegate:InputByStartUpModalDelegate?
    var forCalendarViewUpdateDiaryByCalendarViewDelegate:UpdateDiaryByCalendarViewDelegate?
    var forLookDiaryViewUpdateDiaryByCalendarViewDelegate:UpdateDiaryByCalendarViewDelegate?
    var forDiaryViewUpdateDiaryByLookDiaryViewDelegate:UpdateDiaryByLookDiaryViewDelegate?
    var forLookDiaryViewUpdateDiaryByLookDiaryViewDelegate:UpdateDiaryByLookDiaryViewDelegate?
    @IBOutlet weak var incomeCollectionView: UICollectionView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var continueAddButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var paymentNodataLabel: UILabel!
    @IBOutlet weak var incomeNodataLabel: UILabel!
    @IBOutlet weak var diaryNoDataLabel: UILabel!
    
    @IBOutlet weak var weekBackButton: UIButton!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var weekPassButton: UIButton!
    
    
    var toolbar: UIToolbar{
        let toolbarRect = CGRect(x: 0,y: 0, width:view.frame.size.width,height: 35)
        let toolbar = UIToolbar(frame: toolbarRect)
        let doneItem = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(didTapFinishButton))
        toolbar.setItems([doneItem], animated: modalPresentationCapturesStatusBarAppearance)
        return toolbar
    }
    
    //日記関連
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addImageButton: UIView!
    @IBOutlet weak var diaryInputTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var addDiaryButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var diaryDateTextField: UITextField!
    
    @IBOutlet weak var diaryWeekBackButton: UIButton!
    @IBOutlet weak var diaryDayBackButton: UIButton!
    @IBOutlet weak var diaryDayPassButton: UIButton!
    @IBOutlet weak var diaryWeekPassButton: UIButton!
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        paymentCollectionView.delegate = self
        paymentCollectionView.dataSource = self
        incomeCollectionView.delegate = self
        incomeCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        diaryInputTextView.delegate = self
        priceTextField.delegate = self
        memoTextField.delegate = self
        titleTextField.delegate = self
        let nib = UINib(nibName: "SliderViewCell", bundle: nil)
        let collectionViewNib = UINib(nibName: "InputCollectionViewCell", bundle: nil)
        imageCollectionView.register(nib, forCellWithReuseIdentifier: "SliderViewCell")
        paymentCollectionView.register(collectionViewNib, forCellWithReuseIdentifier: "customCell")
        incomeCollectionView.register(collectionViewNib, forCellWithReuseIdentifier: "customCell")
        configureTextfield()
        configureButton()
        configureDateTextField()
        addSubView()
        addHouseholdAccountView()
        settingSubView()
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
        settingCollectionView()
        inputViewModel.setCategoryData()
        inputViewModel.setIncomeCategoryData()
        configureAddButton()
        setNavigationBarButton()
        setToolbar()
        changeNavigationBarColor()
        changeSegmentedControlColor()
        changeButtonColor()
        configureTextView()
        setNavigationTitle()
        if inputViewModel.journal == nil{
            addButton.setTitle("追加する",for: .normal)
        }else{
            addButton.setTitle("修正する", for: .normal)
        }
        
        if inputViewModel.diary == nil{
            addDiaryButton.setTitle("追加する", for: .normal)
        }else{
            addDiaryButton.setTitle("修正する", for: .normal)
        }
        
        if inputViewModel.diary != nil{
            diaryNoDataLabel.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if inputViewModel.isDiary == true{
            viewChangeSegmentedControl.selectedSegmentIndex = 1
            addDiaryView()
        }
        
        if inputViewModel.diary != nil || inputViewModel.journal != nil || inputViewControllerDelegate != nil{
            vanishSegmentedControl()
        }
    }
    
    override func viewDidLayoutSubviews() {
        settingCollectionViewAutoLayout()
    }
    
    func setNavigationTitle(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        if inputViewModel.journal == nil && inputViewModel.diary == nil{
            navigationItem.title = "新規作成"
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true) ?? .black]
        }else{
            navigationItem.title = "編集"
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true) ?? .black]
        }
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    func changeNavigationBarColor(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        appearance.backgroundColor = themeColor.color
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true) ?? .black]
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
    }
    
    @objc func tapBackButton(){
        dismiss(animated: true)
    }
    
    func setPaymentData(data:Journal){
        inputViewModel.journal = data
        priceTextField.text = String(data.price)
        inputViewModel.category = data.category
        inputViewModel.isPayment = inputViewModel.journal!.isPayment
        inputViewModel.date = data.date
        inputViewModel.setCategoryData()
        if data.memo != ""{
            memoTextField.text = data.memo
        }
        paymentCollectionView.dataSource = self
        paymentCollectionView.delegate = self
        paymentCollectionView.reloadData()
    }
    
    func setIncomeData(data:Journal){
        inputViewModel.journal = data
        priceTextField.text = String(inputViewModel.journal!.price)
        inputViewModel.category = inputViewModel.journal!.category
        inputViewModel.isPayment = false
        inputViewModel.date = inputViewModel.journal!.date
        if data.memo != ""{
            memoTextField.text = data.memo
        }
    }
    
    func setDiary(data:Diary){
        inputViewModel.diary = data
        titleTextField.text = inputViewModel.diary!.title
        diaryInputTextView.text = inputViewModel.diary!.text
        inputViewModel.date = inputViewModel.diary!.date
        inputViewModel.imageArray = Array(data.pictureList)
    }
    
    func addSubView(){
        view.addSubview(householdAccountBookScrollView)
        view.addSubview(diaryView)
    }
    
    private func addHouseholdAccountView(){
        diaryView.isHidden = true
        householdAccountBookScrollView.isHidden = false
    }
    
    func addDiaryView(){
        householdAccountBookScrollView.isHidden = true
        diaryView.isHidden = false
    }
    
    private func settingSubView(){
        householdAccountBookScrollView.isScrollEnabled = false
        householdAccountBookScrollView.translatesAutoresizingMaskIntoConstraints = false
        householdAccountBookScrollView.topAnchor.constraint(equalTo: viewChangeSegmentedControl.bottomAnchor,constant: 10).isActive = true
        householdAccountBookScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        householdAccountBookScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        householdAccountBookScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        householdAccountBookView.translatesAutoresizingMaskIntoConstraints = false
        householdAccountBookView.topAnchor.constraint(equalTo: householdAccountBookScrollView.topAnchor).isActive = true
        householdAccountBookView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        householdAccountBookView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        householdAccountBookView.heightAnchor.constraint(equalToConstant: 1200).isActive = true
        
        diaryView.translatesAutoresizingMaskIntoConstraints = false
        diaryView.topAnchor.constraint(equalTo: viewChangeSegmentedControl.bottomAnchor,constant: 10).isActive = true
        diaryView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        diaryView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        diaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if view.frame.height < 650{
            diaryInputTextView.translatesAutoresizingMaskIntoConstraints = false
            diaryInputTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor,constant: 10).isActive = true
            diaryInputTextView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 25).isActive = true
            diaryInputTextView.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -25).isActive = true
            diaryInputTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }
        
        paymentNodataLabel.translatesAutoresizingMaskIntoConstraints = false
        paymentNodataLabel.topAnchor.constraint(equalTo: paymentCollectionView.topAnchor,constant: 10).isActive = true
        paymentNodataLabel.rightAnchor.constraint(equalTo: paymentCollectionView.rightAnchor, constant: -8).isActive = true
        
        incomeNodataLabel.translatesAutoresizingMaskIntoConstraints = false
        incomeNodataLabel.topAnchor.constraint(equalTo: incomeCollectionView.topAnchor,constant: 10).isActive = true
        incomeNodataLabel.rightAnchor.constraint(equalTo: incomeCollectionView.rightAnchor, constant: -8).isActive = true
        
        diaryNoDataLabel.translatesAutoresizingMaskIntoConstraints = false
        diaryNoDataLabel.topAnchor.constraint(equalTo: diaryInputTextView.topAnchor,constant: 7).isActive = true
        diaryNoDataLabel.leftAnchor.constraint(equalTo: diaryInputTextView.leftAnchor, constant: 13).isActive = true
        
    }
    
    private func settingCollectionViewAutoLayout(){
        paymentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        paymentCollectionView.topAnchor.constraint(equalTo: dateTextField.bottomAnchor,constant: 10).isActive = true
        paymentCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        paymentCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        let numberOfItems = inputViewModel.categoryList.count
        let itemHeight: CGFloat = 38.0
        let space: CGFloat = 5
        var paymentCollectionHeight: CGFloat = 0
        
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
        if returnRows(items: numberOfItems) == 3{
            paymentCollectionHeight = CGFloat((returnRows(items: numberOfItems) * Int(itemHeight)) + Int(returnRows(items: numberOfItems) - 2) * Int(space))
        }else{
            paymentCollectionHeight = CGFloat((returnRows(items: numberOfItems) * Int(itemHeight)) + Int(returnRows(items: numberOfItems) - 1) * Int(space))
        }
        let incomeNumberOfItems = inputViewModel.incomeCategoryList.count
        paymentCollectionView.heightAnchor.constraint(equalToConstant: paymentCollectionHeight).isActive = true
        incomeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        incomeCollectionView.topAnchor.constraint(equalTo: paymentCollectionView.bottomAnchor,constant: 10).isActive = true
        incomeCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        incomeCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        let incomeCollectionHeight = CGFloat((returnRows(items: incomeNumberOfItems) * Int(itemHeight)) + Int(returnRows(items: incomeNumberOfItems) - 1) * Int(space))
        incomeCollectionView.heightAnchor.constraint(equalToConstant: incomeCollectionHeight).isActive = true
    }
    
    //segmentedControll関連
    @IBAction func viewChangeSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addHouseholdAccountView()
            view.endEditing(true)
        case 1:
            addDiaryView()
            view.endEditing(true)
        default:
            return
        }
    }
    
    //日付操作関連
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func oneWeekBackButton(_ sender: UIButton) {
        oneWeekBack()
    }
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
    }
    @IBAction func oneWeekPassButton(_ sender: UIButton) {
        oneWeekPass()
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        tapAddButton()
        inputViewControllerDelegate?.didReceiveNotification()
        inputByStartUpModalDelegate?.updateJournal()
        inputByStartUpModalDelegate?.fixSelectedDate(date: inputViewModel.date)
    }
    
    @IBAction func continueAddButton(_ sender: UIButton) {
        tapContinueAddButton()
        inputViewControllerDelegate?.didReceiveNotification()
        for i in 0 ..< inputViewModel.categoryList.count{
            if let targetCell = paymentCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? InputCollectionViewCell{
                targetCell.backgroundColor = .white
                targetCell.categoryLabel.textColor = .flatBlack()
            }
        }

        for i in 0 ..< inputViewModel.incomeCategoryList.count{
            if let targetCell = incomeCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? InputCollectionViewCell{
                targetCell.backgroundColor = .white
                targetCell.categoryLabel.textColor = .flatBlack()
            }
        }
        
        if let selectedItem = incomeCollectionView.indexPathsForSelectedItems?.first{
            incomeCollectionView.cellForItem(at: selectedItem)?.backgroundColor = .white
        }
        inputByStartUpModalDelegate?.updateJournal()
        inputViewModel.journal = nil

        if view.frame.height < 650{
            view.endEditing(true)
            householdAccountBookScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func changeButtonColor(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        weekBackButton.tintColor = themeColor.arrowColor
        dayBackButton.tintColor = themeColor.arrowColor
        weekPassButton.tintColor = themeColor.arrowColor
        dayPassButton.tintColor = themeColor.arrowColor
        diaryWeekBackButton.tintColor = themeColor.arrowColor
        diaryDayBackButton.tintColor = themeColor.arrowColor
        diaryWeekPassButton.tintColor = themeColor.arrowColor
        diaryDayPassButton.tintColor = themeColor.arrowColor

    }
    
    @objc func didTapFinishButton(){
        view.endEditing(true)
        householdAccountBookScrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func configureDateTextField(){
        let householdAccountBookDatePicker = inputViewModel.datePicker
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
        inputViewModel.date = picker.date
        dateTextField.text = util.dayDateFormatter.string(from: picker.date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: picker.date)
    }
    
    @IBAction func textFieldActionAddButtonInactive(_ sender: Any) {
        if inputViewModel.journal != nil{
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
        }else if priceTextField.text != "" && inputViewModel.category != ""{
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
    
    func configureButton(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        addButton.backgroundColor = themeColor.color
        addButton.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
        addButton.layer.cornerRadius = 5
        addButton.layer.borderColor = UIColor.systemGray2.cgColor
        
        continueAddButton.backgroundColor = themeColor.color
        continueAddButton.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
        continueAddButton.layer.cornerRadius = 5
        continueAddButton.layer.borderColor = UIColor.systemGray2.cgColor
        addDiaryButton.backgroundColor = themeColor.color
        addDiaryButton.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
        addDiaryButton.layer.cornerRadius = 5
        addDiaryButton.layer.borderColor = UIColor.systemGray2.cgColor
        addImageButton.backgroundColor = themeColor.color
        addImageButton.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
        addImageButton.layer.cornerRadius = 5
        addImageButton.layer.borderColor = UIColor.systemGray2.cgColor
        
    }
    
    func configureAddButton(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        if inputViewModel.journal != nil{
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
            addButton.setTitleColor(UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true), for: .normal)
            continueAddButton.setTitleColor(UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true), for: .normal)
        }else if inputViewModel.diary != nil{
            addDiaryButton.isEnabled = true
        }else{
            addButton.isEnabled = false
            continueAddButton.isEnabled = false
            addDiaryButton.isEnabled = false
        }
    }
    
    private func tapAddButton(){
        if inputViewModel.journal == nil{
            if inputViewModel.isValidPrice(price: (Int(priceTextField.text!) ?? Int("0"))!){
                showAlert(title: "金額は1億円以内にしてください")
                return
            }
            if inputViewModel.isValidMemoLimit(memo: memoTextField.text!){
                showAlert(title: "メモは10文字以内にしてください")
                return
            }
            inputViewModel.addNewJournal(priceText: Int(priceTextField.text!) ?? Int("0")!, expenseItem: inputViewModel.category, memo: memoTextField.text!)
            inputViewControllerDelegate?.updatePayment()
            dismiss(animated: true)
        }else if inputViewModel.journal != nil{ //paymetTableViewを選択した場合
            if inputViewModel.journal?.isPayment == true{
                if inputViewModel.isValidPrice(price: Int(priceTextField.text!)!){
                    showAlert(title: "金額は1億円以内にしてください")
                    return
                }
                if inputViewModel.isValidMemoLimit(memo: memoTextField.text!){
                    showAlert(title: "メモは10文字以内にしてください")
                    return
                }
                
                inputViewModel.overwriteJournal(price: Int(priceTextField.text!)!, result: inputViewModel.category, memo: memoTextField.text!)
                
                if inputViewModel.isPayment == false{
                    inputViewControllerDelegate?.changeFromPaymentToIncome()
                }
            }else if inputViewModel.journal?.isPayment == false{
                if inputViewModel.isValidPrice(price: Int(priceTextField.text!)!){
                    showAlert(title: "金額は1億円以内にしてください")
                    return
                }
                if inputViewModel.isValidMemoLimit(memo: memoTextField.text!){
                    showAlert(title: "メモは10文字以内にしてください")
                    return
                }
                
                inputViewModel.overwriteJournal(price: Int(priceTextField.text!)!, result: inputViewModel.category, memo: memoTextField.text!)
                if inputViewModel.isPayment == true{
                    inputViewControllerDelegate?.changeFromIncomeToPayment()
                }
            }
            inputViewControllerDelegate?.updatePayment()
            inputViewControllerDelegate?.updateCalendar()
            inputViewModel.journal = nil
            dismiss(animated: true)
        }
        RecognitionChange.shared.updateCalendar = true
    }
    
    func showAlert(title:String){
        let alert = UIAlertController(title:title, message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    private func tapContinueAddButton(){
        if inputViewModel.journal == nil{
            if inputViewModel.isValidPrice(price: Int(priceTextField.text!)!){
                showAlert(title: "金額は1億円以内にしてください")
                return
            }
            if inputViewModel.isValidMemoLimit(memo: memoTextField.text!){
                showAlert(title: "メモは10文字以内にしてください")
                return
            }
            inputViewModel.addNewJournal(priceText: Int(priceTextField.text!)!, expenseItem: inputViewModel.category, memo: memoTextField.text!)
            inputViewControllerDelegate?.updatePayment()
        }else if inputViewModel.journal != nil{ //paymetTableViewを選択した場合
            if inputViewModel.journal?.isPayment == true{
                if inputViewModel.isValidPrice(price: Int(priceTextField.text!)!){
                    showAlert(title: "金額は1億円以内にしてください")
                    return
                }
                if inputViewModel.isValidMemoLimit(memo: memoTextField.text!){
                    showAlert(title: "メモは10文字以内にしてください")
                    return
                }
                
                inputViewModel.overwriteJournal(price: Int(priceTextField.text!)!, result: inputViewModel.category, memo: memoTextField.text!)
                
                if inputViewModel.isPayment == false{
                    inputViewControllerDelegate?.changeFromPaymentToIncome()
                }
            }else if inputViewModel.journal?.isPayment == false{
                if inputViewModel.isValidPrice(price: Int(priceTextField.text!)!){
                    showAlert(title: "金額は1億円以内にしてください")
                    return
                }
                if inputViewModel.isValidMemoLimit(memo: memoTextField.text!){
                    showAlert(title: "メモは10文字以内にしてください")
                    return
                }
                
                inputViewModel.overwriteJournal(price: Int(priceTextField.text!)!, result: inputViewModel.category, memo: memoTextField.text!)
                if inputViewModel.isPayment == true{
                    inputViewControllerDelegate?.changeFromIncomeToPayment()
                }
            }
            inputViewControllerDelegate?.updatePayment()
            inputViewControllerDelegate?.updateCalendar()
            inputViewModel.journal = nil
        }
        inputViewModel.journal = nil
        inputViewModel.category = ""
        priceTextField.text = ""
        addButton.setTitle("追加する",for: .normal)
        addButton.isEnabled = false
        continueAddButton.isEnabled = false
        
        RecognitionChange.shared.updateCalendar = true
    }
    
    func vanishSegmentedControl(){
        viewChangeSegmentedControl.isHidden = true
        segmentedControlHeight.constant = 0
    }
    
    func changeSegmentedControlColor(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        viewChangeSegmentedControl.selectedSegmentTintColor = themeColor.segmentedControlColor
        viewChangeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(contrastingBlackOrWhiteColorOn: themeColor.segmentedControlColor, isFlat: true)!], for: .selected)
        viewChangeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(contrastingBlackOrWhiteColorOn: UIColor.systemGray3, isFlat: true)!], for: .normal)
    }
    
    func configureTextfield(){
        priceTextField.placeholder = "金額を記入してください"
        priceTextField.textAlignment = NSTextAlignment.right
        priceTextField.layer.borderColor = UIColor.systemGray2.cgColor
        priceTextField.layer.borderWidth = 1.0
        priceTextField.layer.cornerRadius = 5.0
        memoTextField.placeholder = "店名や商品名など"
        memoTextField.textAlignment = NSTextAlignment.right
        memoTextField.layer.borderColor = UIColor.systemGray2.cgColor
        memoTextField.layer.borderWidth = 1.0
        memoTextField.layer.cornerRadius = 5.0
        titleTextField.placeholder = "タイトルを記入してください"
        titleTextField.layer.borderColor = UIColor.systemGray2.cgColor
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = 5.0
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
        inputViewModel.date = Calendar.current.date(byAdding: .day, value: -1, to: inputViewModel.date.zeroclock)!
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
    }
    
    func oneWeekBack(){
        inputViewModel.date = Calendar.current.date(byAdding: .day, value: -7, to: inputViewModel.date.zeroclock)!
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
    }
    
    func dayPass(){
        inputViewModel.date = Calendar.current.date(byAdding: .day, value: 1, to: inputViewModel.date.zeroclock)!
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
    }
    
    func oneWeekPass(){
        inputViewModel.date = Calendar.current.date(byAdding: .day, value: 7, to: inputViewModel.date.zeroclock)!
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date.zeroclock)
    }
    
    //日記記入関連の画面
    @IBAction func diaryDayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func diaryOneWeekBackButton(_ sender: UIButton) {
        oneWeekBack()
    }
    @IBAction func diaryDayPassButton(_ sender: UIButton) {
        dayPass()
    }
    @IBAction func diaryOneWeekPassButton(_ sender: UIButton) {
        oneWeekPass()
    }
    
    @IBAction func addDiaryButton(_ sender: UIButton) {
        addDiary()
    }
    @IBAction func addImageButton(_ sender: UIButton) {
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
        if diaryInputTextView.text!.count >= 2000{
            countLabel.textColor = .red
        }else{
            countLabel.textColor = .systemGray2
        }
        
    }
    
    
    func addDiary(){
        if inputViewModel.diary == nil{
            inputViewModel.addNewDiary(titleText: titleTextField.text!, diaryText: diaryInputTextView.text!)
        }else{
            inputViewModel.overwriteDiary(titleText:titleTextField.text!,diaryText:diaryInputTextView.text!)
        }
        inputViewControllerDelegate?.updateDiary()
        dismiss(animated: true)
        RecognitionChange.shared.updateCalendar = true
        RecognitionChange.shared.updateDiaryByCalendarForDiary = true
        forLookDiaryViewUpdateDiaryByLookDiaryViewDelegate?.configureText(title: titleTextField.text!, text: diaryInputTextView.text!)
        forLookDiaryViewUpdateDiaryByLookDiaryViewDelegate?.updateDiaryByLookDiaryView()
        forDiaryViewUpdateDiaryByLookDiaryViewDelegate?.updateDiaryByLookDiaryView()
        inputByStartUpModalDelegate?.updateDiaryAndCalendar()
    }
    
    
    
}

extension InputViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === paymentCollectionView{
            if inputViewModel.categoryList.count == 0{
                paymentNodataLabel.isHidden = false
            }else{
                paymentNodataLabel.isHidden = true
            }
            return inputViewModel.categoryList.count
        }else if collectionView === imageCollectionView{
            return inputViewModel.imageArray.count
        }else if collectionView === incomeCollectionView{
            if inputViewModel.incomeCategoryList.count == 0{
                incomeNodataLabel.isHidden = false
            }else{
                incomeNodataLabel.isHidden = true
            }
            
            return inputViewModel.incomeCategoryList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === paymentCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! InputCollectionViewCell
            cell.categoryLabel.text = inputViewModel.categoryList[indexPath.row].name
            if inputViewModel.journal != nil{
                cell.journal = inputViewModel.journal!
                if inputViewModel.journal!.isPayment == true{
                }
            }
            return cell
        }else if collectionView === imageCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderViewCell", for: indexPath) as! SliderViewCell
            let cellImage = inputViewModel.fixImageOrientation(UIImage(data: inputViewModel.imageArray[indexPath.item])!)
            cell.imageView.image = cellImage
            cell.imageView.contentMode = .scaleAspectFit
            return cell
        }else if collectionView === incomeCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! InputCollectionViewCell
            cell.categoryLabel.text = inputViewModel.incomeCategoryList[indexPath.row].name
            
            if inputViewModel.journal != nil{
                cell.journal = inputViewModel.journal!
            }
            
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
            let cellWidth = collectionView.frame.width / 2
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
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        if collectionView === paymentCollectionView{
            let cell = collectionView.cellForItem(at: indexPath) as! InputCollectionViewCell
            inputViewModel.category = inputViewModel.categoryList[indexPath.row].name
            
            for i in 0 ..< inputViewModel.categoryList.count{
                if let targetCell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? InputCollectionViewCell{
                    targetCell.backgroundColor = .white
                    targetCell.categoryLabel.textColor = .flatBlack()
                }
            }
            cell.backgroundColor = themeColor.color
            cell.categoryLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
            
            
            for i in 0 ..< inputViewModel.incomeCategoryList.count{
                if let targetCell = incomeCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? InputCollectionViewCell{
                    targetCell.backgroundColor = .white
                    targetCell.categoryLabel.textColor = .flatBlack()
                }
            }
            
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            inputViewModel.isPayment = true
            if priceTextField.text == ""{
                priceTextField.becomeFirstResponder()
            }
            return
        }else if collectionView === imageCollectionView{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let pictureViewController = storyboard.instantiateViewController(withIdentifier: "PictureViewController") as? PictureViewController else{return}
            self.navigationController?.pushViewController(pictureViewController, animated: true)
            
            let selectedImage = inputViewModel.imageArray[indexPath.item]
            inputViewModel.selectedIndex = indexPath.item
            pictureViewController.pictureViewModel.inputViewControllerImage = selectedImage
            pictureViewController.pictureViewControllerDelegate = self
            pictureViewController.pictureViewModel.text = diaryInputTextView.text
            pictureViewController.pictureViewModel.titleText = titleTextField.text
        }else if collectionView === incomeCollectionView{
            let cell = incomeCollectionView.cellForItem(at: indexPath) as? InputCollectionViewCell
            inputViewModel.category = inputViewModel.incomeCategoryList[indexPath.row].name
            
            for i in 0 ..< inputViewModel.categoryList.count{
                if let targetCell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? InputCollectionViewCell{
                    targetCell.backgroundColor = .white
                    targetCell.categoryLabel.textColor = .flatBlack()
                }
            }
            cell?.backgroundColor = themeColor.color
            cell!.categoryLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
            
            for i in 0 ..< inputViewModel.categoryList.count{
                if let targetCell = paymentCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? InputCollectionViewCell{
                    targetCell.backgroundColor = .white
                    targetCell.categoryLabel.textColor = .flatBlack()
                }
            }
            
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            inputViewModel.isPayment = false
            if priceTextField.text == ""{
                priceTextField.becomeFirstResponder()
            }
            return
        }
    }
}

extension InputViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        
        let image = (info[.originalImage] as! UIImage)
        let imageData = image.jpegData(compressionQuality: 0.5)
        
        inputViewModel.imageArray.append(imageData!)
        imageCollectionView.reloadData()
        dismiss(animated:true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        inputViewModel.currentIndex = Int(scrollView.contentOffset.x / imageCollectionView.frame.size.width)
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
        
        if diaryInputTextView.text.count == 0{
            diaryNoDataLabel.isHidden = false
        }else{
            diaryNoDataLabel.isHidden = true
        }
    }
}

extension InputViewController:PictureViewControllerDelegate{
    func setAddDiaryButtonIsEnable() {
        addDiaryButton.isEnabled = true
    }
    
    func deletePicuture() {
        inputViewModel.imageArray.remove(at: inputViewModel.selectedIndex!)
        imageCollectionView.reloadData()
    }
}

extension InputViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if view.frame.height < 650{
            householdAccountBookScrollView.isScrollEnabled = true
            if textField === priceTextField || textField === memoTextField{
                let scrollPoint = CGPoint(x:0, y: memoTextField.frame.origin.y - 50)
                householdAccountBookScrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if view.frame.height < 650{
            householdAccountBookScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleTextField{
            textField.resignFirstResponder()
            diaryInputTextView.becomeFirstResponder()
        }
        return true
    }
}
