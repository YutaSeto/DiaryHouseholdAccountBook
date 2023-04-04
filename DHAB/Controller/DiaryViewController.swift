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
    private var diaryByMonth:[String: [DiaryModel]] = [:]
    
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
        if RecognitionChange.shared.deleteDiaryByCalendar == true{
            setDiaryData()
            diaryTableView.reloadData()
            
        }
    }
        
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
        inputViewController.inputViewModel.isDiary = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let realm = try! Realm()
        
        if searchText.isEmpty{
            setDiaryData()
            diaryTableView.reloadData()
        }else{
            let textResult = Array(realm.objects(DiaryModel.self).filter("text CONTAINS %@ " , searchText).sorted(byKeyPath: "date", ascending: false))
            var titleResult = Array(realm.objects(DiaryModel.self).filter("title CONTAINS %@", searchText).sorted(byKeyPath: "date", ascending: false))
            
            textResult.forEach{object in
                if let index = titleResult.firstIndex(where: {$0.id == object.id}){
                    titleResult.remove(at: index)
                }
            }
            
            let allResults = Set(Array(textResult) + Array(titleResult))
            diaryList = Array(allResults).sorted(by: {$0.date > $1.date})
            
            diaryByMonth = [:]
            for diary in diaryList{
                let month = util.yearDateFormatter.string(from: diary.date)
                if diaryByMonth[month] == nil{
                    diaryByMonth[month] = []
                }
                diaryByMonth[month]?.append(diary)
            }
        }
        diaryTableView.reloadData()
    }
    
    func setDiaryData(){
        let realm = try! Realm()
        let result = realm.objects(DiaryModel.self).sorted(byKeyPath: "date", ascending: false)
        diaryList = Array(result)
        
        diaryByMonth.removeAll()
        
        for diary in diaryList{
            let dateString = util.monthDateFormatter.string(from: diary.date)
            if diaryByMonth[dateString] == nil{
                diaryByMonth[dateString] = []
            }
            diaryByMonth[dateString]?.append(diary)
        }
        
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
    func numberOfSections(in tableView: UITableView) -> Int {
        let sortedKeys = diaryByMonth.keys.sorted(by: {$0 > $1})
        return sortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedKeys = diaryByMonth.keys.sorted(by: {$0 > $1})
        let month = sortedKeys[section]
        return diaryByMonth[month]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedKeys = diaryByMonth.keys.sorted(by: {$0 > $1})
        let monthString = sortedKeys[section]
        if let date = util.monthDateFormatter.date(from: monthString){
            return util.monthDateFormatter.string(from: date)
        }else{
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
        let sortedKeys = diaryByMonth.keys.sorted(by: {$0 > $1})
        let month = sortedKeys[indexPath.section]
        let diary = diaryByMonth[month]?[indexPath.row]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let attributedText = NSAttributedString(string:diary!.text,attributes:[.font:cell.cellTextLabel.font!,.paragraphStyle: paragraphStyle])
        
        
        cell.cellDateLabel.text = util.onliDayDateFormatter.string(from:diary!.date)
        cell.dayOfWeekLabel.text = util.dayOfWeekDateFormatter.string(from: diary!.date)
        cell.cellTitleLabel.text = diary!.title
        cell.cellTextLabel.attributedText = attributedText
        cell.cellTextLabel.sizeToFit()
        if !diary!.pictureList.isEmpty{
            cell.thumbnailImageView.image = UIImage(data: diary!.pictureList[0])
        }else{
            cell.thumbnailImageView.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortedKeys = diaryByMonth.keys.sorted(by: {$0 > $1})
        let month = sortedKeys[indexPath.section]
        let diary = diaryByMonth[month]?[indexPath.row]
        
        let storyboard = UIStoryboard(name: "DiaryViewController", bundle: nil)
        guard let lookDiaryViewController = storyboard.instantiateViewController(withIdentifier: "LookDiaryViewController") as? LookDiaryViewController else{return}
        self.navigationController?.pushViewController(lookDiaryViewController, animated: true)
        lookDiaryViewController.diary = diary
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let sortedKeys = diaryByMonth.keys.sorted(by: {$0 > $1})
        let targetMonth = sortedKeys[indexPath.section]
        let targetItem = diaryByMonth[sortedKeys[indexPath.section]]![indexPath.row]
        diaryByMonth[sortedKeys[indexPath.section]]?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        let realm = try! Realm()
        try! realm.write{
            realm.delete(targetItem)
        }
        
        if diaryByMonth[targetMonth]?.count == 0{
            diaryByMonth.removeValue(forKey: targetMonth)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
        
        RecognitionChange.shared.deleteDiaryByDiary = true
        //カレンダービューの日記の更新をする必要あり
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
