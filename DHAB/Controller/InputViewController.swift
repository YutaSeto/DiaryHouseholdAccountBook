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
    
    let inputViewModel = InputViewModel()
    let util = Util()
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeight: NSLayoutConstraint!
    //家計簿記入画面関連
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
    
    var toolbar: UIToolbar{
        let toolbarRect = CGRect(x: 0,y: 0, width:view.frame.size.width,height: 35)
        let toolbar = UIToolbar(frame: toolbarRect)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapFinishButton))
        toolbar.setItems([doneItem], animated: modalPresentationCapturesStatusBarAppearance)
        return toolbar
    }
    
    //日記関連
    var collectionViewDelegate:UICollectionViewDelegate?
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
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
        settingCollectionView()
        inputViewModel.setCategoryData()
        inputViewModel.setIncomeCategoryData()
        configureAddButton()
        setNavigationBarButton()
        setToolbar()
        configureTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if inputViewModel.isDiary == true{
            viewChangeSegmentedControl.selectedSegmentIndex = 1
            addDiaryView()
        }
        
        if inputViewModel.diary != nil || inputViewModel.journal != nil{
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
        inputViewModel.journal = data
        priceTextField.text = String(data.price)
        resultLabel.text = data.category
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
    
    func setIncomeData(data:JournalModel){
        inputViewModel.journal = data
        priceTextField.text = String(inputViewModel.journal!.price)
        resultLabel.text = inputViewModel.journal?.category
        inputViewModel.isPayment = false
        inputViewModel.date = inputViewModel.journal!.date
        if data.memo != ""{
            memoTextField.text = data.memo
        }
    }
    
    func setDiary(data:DiaryModel){
        inputViewModel.diary = data
        titleTextField.text = inputViewModel.diary!.text
        diaryInputTextView.text = inputViewModel.diary!.text
        inputViewModel.date = inputViewModel.diary!.date
        inputViewModel.imageArray = Array(data.pictureList)
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
        let numberOfItems = inputViewModel.categoryList.count
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
        let incomeNumberOfItems = inputViewModel.incomeCategoryList.count
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
        inputViewModel.journal = nil
        
    }
    
    @objc func didTapFinishButton(){
        if let targetDateText = dateTextField.text,
           let targetDate = util.monthDateFormatter.date(from:targetDateText){
            inputViewModel.date = targetDate.zeroclock
        }
        if let targetDateText = diaryDateTextField.text,
           let targetDate = util.monthDateFormatter.date(from: targetDateText){
            inputViewModel.date = targetDate.zeroclock
        }
        view.endEditing(true)
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
        if inputViewModel.journal != nil{
            addButton.isEnabled = true
            continueAddButton.isEnabled = true
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
            inputViewModel.addNewJournal(priceText: priceTextField.text!, memoText: memoTextField.text!, result: resultLabel.text!)
            inputViewControllerDelegate?.updatePayment()
            dismiss(animated: true)
        }else if inputViewModel.journal != nil{ //paymetTableViewを選択した場合
            if inputViewModel.journal?.isPayment == true{
                inputViewModel.OverwriteJournal(priceText: priceTextField.text!, result: resultLabel.text!, memoText: memoTextField.text!)
                    if inputViewModel.isPayment == false{
                        inputViewControllerDelegate?.changeFromPaymentToIncome()
                    }
                }else if inputViewModel.journal?.isPayment == false{
                    inputViewModel.OverwriteJournal(priceText: priceTextField.text!, result: resultLabel.text!, memoText: memoTextField.text!)
                    if inputViewModel.isPayment == true{
                        inputViewControllerDelegate?.changeFromIncomeToPayment()
                    }
                }
                inputViewControllerDelegate?.updatePayment()
                inputViewControllerDelegate?.updateCalendar()
                RecognitionChange.shared.updateCalendar = true
                inputViewModel.journal = nil
                dismiss(animated: true)
        }
    }
    
    private func tapContinueAddButton(){
        if inputViewModel.journal == nil{
            inputViewModel.addNewJournal(priceText: priceTextField.text!, memoText: memoTextField.text!, result: resultLabel.text!)
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            resultLabel.text = ""
            priceTextField.text = ""
            addButton.isEnabled = false
            continueAddButton.isEnabled = false
        }else if inputViewModel.journal != nil{
            inputViewModel.OverwriteJournal(priceText: priceTextField.text!, result: resultLabel.text!, memoText: memoTextField.text!)
            inputViewControllerDelegate?.updatePayment()
            RecognitionChange.shared.updateCalendar = true
            inputViewModel.journal = nil
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
        inputViewModel.date = Calendar.current.date(byAdding: .day, value: -1, to: inputViewModel.date)!
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
    }
    
    func dayPass(){
        inputViewModel.date = Calendar.current.date(byAdding: .day, value: 1, to: inputViewModel.date)!
        dateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
        diaryDateTextField.text = util.dayDateFormatter.string(from: inputViewModel.date)
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
        if inputViewModel.diary == nil{
            inputViewModel.addNewDiary(titleText: titleTextField.text!, diaryText: diaryInputTextView.text!)
            inputViewControllerDelegate?.updateDiary()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
        }else{
            inputViewModel.overwriteDiary(titleText:titleTextField.text!,diaryText:diaryInputTextView.text!)
            inputViewControllerDelegate?.updateDiary()
            RecognitionChange.shared.updateCalendar = true
            dismiss(animated: true)
        }
    }
    
    
}

extension InputViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === paymentCollectionView{
            return inputViewModel.categoryList.count
        }else if collectionView === imageCollectionView{
            return inputViewModel.imageArray.count
        }else if collectionView === incomeCollectionView{
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
                cell.toggleSelection()
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
            let cellWidth = collectionView.frame.width / 3
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
            resultLabel.text = inputViewModel.categoryList[indexPath.row].name
            
            
            for i in 0 ..< inputViewModel.categoryList.count{
                collectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            for i in 0 ..< inputViewModel.incomeCategoryList.count{
                incomeCollectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            inputViewModel.isPayment = true
            
            return
        }else if collectionView === imageCollectionView{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let pictureViewController = storyboard.instantiateViewController(withIdentifier: "PictureViewController") as? PictureViewController else{return}
            self.navigationController?.pushViewController(pictureViewController, animated: true)
            
            let selectedImage = inputViewModel.imageArray[indexPath.item]
            inputViewModel.selectedIndex = indexPath.item
            pictureViewController.inputViewControllerImage = selectedImage
            pictureViewController.pictureViewControllerDelegate = self
            pictureViewController.text = diaryInputTextView.text
            pictureViewController.titleText = titleTextField.text
        }else if collectionView === incomeCollectionView{
            let cell = incomeCollectionView.cellForItem(at: indexPath)
            resultLabel.text = inputViewModel.incomeCategoryList[indexPath.row].name
            
            for i in 0 ..< inputViewModel.categoryList.count{
                paymentCollectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            for i in 0 ..< inputViewModel.incomeCategoryList.count{
                incomeCollectionView.cellForItem(at: IndexPath(item: i, section: 0))?.backgroundColor = .white
            }
            cell?.backgroundColor = .lightGray
            
            if priceTextField.text != ""{
                addButton.isEnabled = true
                continueAddButton.isEnabled = true
            }
            inputViewModel.isPayment = false
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
