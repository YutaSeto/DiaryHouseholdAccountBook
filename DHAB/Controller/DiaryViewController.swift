//
//  DiaryViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift
import UIKit

class DiaryViewController:UIViewController,UISearchBarDelegate{
   
    let util = Util()
    //検索機能関連
    @IBOutlet weak var searchBar: UISearchBar!
    
    //日記関連
    private var diaryList: [DiaryModel] = []
    private var diaryByMonth = [String: [DiaryModel]]()
    
    
    private var titleResult: Results<DiaryModel>?
    private var textResult: Results<DiaryModel>?
    
    @IBOutlet weak var diaryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        setDiaryData()
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        searchBar.delegate = self
        setNavigationBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if RecognitionChange.shared.deleteDiary == true{
            setDiaryData()
            diaryTableView.reloadData()
        }
    }
    
//    func setSectionMonth(){
//        for diary in diaryList{
//            let date = diary.date
//            util.monthDateFormatter.string(from: date)
//            if diaryByMonth[month] == nil{
//                diaryByMonth[month] = [Diary]()
//                monthArray.append(month)
//            }
//        }
//    }
    
    func setNavigationBarButton(){
        navigationItem.title = "日記"
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let leftButtonActionSelector: Selector = #selector(showInputView)
        let leftBarButton = UIBarButtonItem(image:UIImage(systemName: "plus"),style: .plain, target: self, action: leftButtonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func showInputView(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
        let navigationController = UINavigationController(rootViewController: inputViewController)
        inputViewController.inputViewControllerDelegate = self
        self.present(navigationController,animated:true)
        inputViewController.isDiary = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let realm = try! Realm()
        
        if searchText.isEmpty{
            let result = realm.objects(DiaryModel.self).sorted(byKeyPath: "date", ascending: false)
            diaryList = Array(result)
        }else{
            textResult = realm.objects(DiaryModel.self).filter("text CONTAINS %@ " , searchText).sorted(byKeyPath: "date", ascending: false)
            titleResult = realm.objects(DiaryModel.self).filter("title CONTAINS %@", searchText).sorted(byKeyPath: "date", ascending: false)
            let allResults = Set(Array(textResult!) + Array(titleResult!))
            diaryList = Array(allResults).sorted(by: {$0.date > $1.date})
        }
        diaryTableView.reloadData()
    }
    
    func setDiaryData(){
        let realm = try! Realm()
        let result = realm.objects(DiaryModel.self).sorted(byKeyPath: "date", ascending: false)
        diaryList = Array(result)
        diaryTableView.reloadData()
    }
}

extension DiaryViewController:InputViewControllerDelegate{
    func changeFromPaymentToIncome() {
        return
    }
    
    func changeFromIncomeToPayment() {
        return
    }
    
    func didReceiveNotification() {
        return
    }
    
    func updateIncome() {
        return
    }
    
    func updatePayment() {
        return
    }
    
    func updateCalendar() {
        return
    }
    
    func updateDiary() {
        setDiaryData()
    }
}

extension DiaryViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
        let diaryModel: DiaryModel = diaryList[indexPath.row]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let attributedText = NSAttributedString(string:diaryModel.text,attributes:[.font:cell.cellTextLabel.font!,.paragraphStyle: paragraphStyle])
        
        
        cell.cellDateLabel.text = util.onliDayDateFormatter.string(from:diaryModel.date)
        cell.dayOfWeekLabel.text = util.dayOfWeekDateFormatter.string(from: diaryModel.date)
        cell.cellTitleLabel.text = diaryModel.title
        cell.cellTextLabel.attributedText = attributedText
        cell.cellTextLabel.sizeToFit()
        if diaryModel.pictureList.count != 0{
            cell.thumbnailImageView.image = UIImage(data: diaryModel.pictureList[0])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "DiaryViewController", bundle: nil)
        guard let lookDiaryViewController = storyboard.instantiateViewController(withIdentifier: "LookDiaryViewController") as? LookDiaryViewController else{return}
        self.navigationController?.pushViewController(lookDiaryViewController, animated: true)
        lookDiaryViewController.diary = diaryList[indexPath.row]
//        lookDiaryViewController.configureTextView()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let targetItem = diaryList[indexPath.row]
        diaryList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        let realm = try! Realm()
        try! realm.write{
            realm.delete(targetItem)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
