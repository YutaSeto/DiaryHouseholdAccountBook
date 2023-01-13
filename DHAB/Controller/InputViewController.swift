//
//  InputViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift

class InputViewController:UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
    
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    func addHouseholdAccountView(){
        diaryView.removeFromSuperview()
        self.view.addSubview(householdAccountBookView)
    }
    func addDiaryView(){
        householdAccountBookView.removeFromSuperview()
        self.view.addSubview(diaryView)
    }
    
    func settingSubView(){
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
    }
    
    //家計簿記入画面関連
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    var date:Date = Date()
    var modifiedDate: Date!
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
    }
    @IBOutlet weak var paymentCollectionView: UICollectionView!
    
    var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        paymentList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let contentLabel = cell.contentView.viewWithTag(1) as! UILabel
        contentLabel.text = paymentList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        resultLabel.text = paymentList[indexPath.row]
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
    
    var paymentList = ["食費","衣類","通信費","保険"]
    
    //日記記入関連の画面
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var diaryDateLabel: UILabel!
    @IBOutlet weak var diaryInputTextView: UITextView!
    @IBAction func diaryDayBackButton(_ sender: UIButton) {
        dayBack()
    }
    @IBAction func diaryDayPassButton(_ sender: UIButton) {
        dayPass()
    }
    
    @IBAction func addDiaryButton(_ sender: UIButton) {
        addDiary()
    }
    
    var diaryModel = DiaryModel()
    var diaryList:[DiaryModel] = []
    
    func addDiary(){
        let realm = try! Realm()
        try! realm.write{
            diaryModel.date = date
            diaryModel.title = titleTextField.text!
            diaryModel.text = diaryInputTextView.text
            realm.add(diaryModel)
            
                       
            print(diaryModel)
            print(diaryList)
            
            titleTextField.text = ""
            diaryInputTextView.text = ""
        }
    }
    
    
}
