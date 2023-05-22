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
    let diaryViewModel = DiaryViewModel()
    
    var toolbar: UIToolbar{
        let toolbarRect = CGRect(x: 0,y: 0, width:view.frame.size.width,height: 35)
        let toolbar = UIToolbar(frame: toolbarRect)
        let doneItem = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(didTapFinishButton))
        toolbar.setItems([doneItem], animated: modalPresentationCapturesStatusBarAppearance)
        return toolbar
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        diaryViewModel.setDiaryData()
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        searchBar.delegate = self
        diaryTableView.reloadData()
        setNavigationBarButton()
        configureSearchBar()
        configureNoDataLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavigationBarColor()
        if RecognitionChange.shared.deleteDiaryByCalendar == true{
            diaryViewModel.setDiaryData()
            diaryTableView.reloadData()
            RecognitionChange.shared.deleteDiaryByCalendar = false
        }
        
        if RecognitionChange.shared.updateDiaryByCalendar == true{
            diaryViewModel.setDiaryData()
            diaryTableView.reloadData()
            RecognitionChange.shared.updateDiaryByCalendar = false
        }
        
        if RecognitionChange.shared.updateDiaryByCalendarForDiary == true{
            diaryViewModel.setDiaryData()
            diaryTableView.reloadData()
            RecognitionChange.shared.updateDiaryByCalendarForDiary = false
        }
    }
    
    @objc func didTapFinishButton(){
        view.endEditing(true)
    }
    
    func configureSearchBar(){
        searchBar.inputAccessoryView = toolbar
        searchBar.placeholder = "過去の日記の検索"
        searchBar.keyboardType = .asciiCapable
    }
    
    func configureNoDataLabel(){
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.topAnchor.constraint(equalTo: diaryTableView.topAnchor,constant: 10).isActive = true
        noDataLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
        
    func setNavigationBarButton(){
        navigationItem.title = "日記"
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
        let leftButtonActionSelector: Selector = #selector(showInputView)
        let leftBarButton = UIBarButtonItem(image:UIImage(systemName: "plus"),style: .plain, target: self, action: leftButtonActionSelector)
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
            diaryViewModel.setDiaryData()
            diaryTableView.reloadData()
        }else{
            let textResult = Array(realm.objects(Diary.self).filter("text CONTAINS %@ " , searchText).sorted(byKeyPath: "date", ascending: false))
            var titleResult = Array(realm.objects(Diary.self).filter("title CONTAINS %@", searchText).sorted(byKeyPath: "date", ascending: false))
            
            textResult.forEach{object in
                if let index = titleResult.firstIndex(where: {$0.id == object.id}){
                    titleResult.remove(at: index)
                }
            }
            
            let allResults = Set(Array(textResult) + Array(titleResult))
            diaryViewModel.diaryList = Array(allResults).sorted(by: {$0.date > $1.date})
            
            diaryViewModel.diaryByMonth = [:]
            for diary in diaryViewModel.diaryList{
                let month = util.yearDateFormatter.string(from: diary.date)
                if diaryViewModel.diaryByMonth[month] == nil{
                    diaryViewModel.diaryByMonth[month] = []
                }
                diaryViewModel.diaryByMonth[month]?.append(diary)
            }
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
        diaryViewModel.setDiaryData()
        diaryTableView.reloadData()
    }
}

extension DiaryViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        let sortedKeys = diaryViewModel.diaryByMonth.keys.sorted(by: {$0 > $1})
        if sortedKeys.count == 0{
            diaryTableView.isHidden = true
            noDataLabel.isHidden = false
        }else{
            diaryTableView.isHidden = false
            noDataLabel.isHidden = true
        }
        
        return sortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedKeys = diaryViewModel.diaryByMonth.keys.sorted(by: {$0 > $1})
        let month = sortedKeys[section]
        return diaryViewModel.diaryByMonth[month]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedKeys = diaryViewModel.diaryByMonth.keys.sorted(by: {$0 > $1})
        let monthString = sortedKeys[section]
        if let date = util.monthDateFormatter.date(from: monthString){
            return util.monthDateFormatter.string(from: date)
        }else{
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
        let sortedKeys = diaryViewModel.diaryByMonth.keys.sorted(by: {$0 > $1})
        let month = sortedKeys[indexPath.section]
        let diary = diaryViewModel.diaryByMonth[month]?[indexPath.row]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let attributedText = NSAttributedString(string:diary!.text,attributes:[.font:cell.cellTextLabel.font!,.paragraphStyle: paragraphStyle])
        
        if view.frame.height < 650{
            cell.cellTextLabel.numberOfLines = 3
        }
        
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
        let sortedKeys = diaryViewModel.diaryByMonth.keys.sorted(by: {$0 > $1})
        let month = sortedKeys[indexPath.section]
        let diary = diaryViewModel.diaryByMonth[month]?[indexPath.row]
        
        let storyboard = UIStoryboard(name: "DiaryViewController", bundle: nil)
        guard let lookDiaryViewController = storyboard.instantiateViewController(withIdentifier: "LookDiaryViewController") as? LookDiaryViewController else{return}
        self.navigationController?.pushViewController(lookDiaryViewController, animated: true)
        lookDiaryViewController.lookDiaryViewModel.diary = diary
        lookDiaryViewController.forDiaryViewUpdateDiaryByLookDiaryViewDelegate = self
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let sortedKeys = diaryViewModel.diaryByMonth.keys.sorted(by: {$0 > $1})
        let targetMonth = sortedKeys[indexPath.section]
        let targetItem = diaryViewModel.diaryByMonth[sortedKeys[indexPath.section]]![indexPath.row]
        diaryViewModel.diaryByMonth[sortedKeys[indexPath.section]]?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        let realm = try! Realm()
        try! realm.write{
            realm.delete(targetItem)
        }
        
        if diaryViewModel.diaryByMonth[targetMonth]?.count == 0{
            diaryViewModel.diaryByMonth.removeValue(forKey: targetMonth)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
        
        RecognitionChange.shared.deleteDiaryByDiary = true
        //カレンダービューの日記の更新をする必要あり
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if view.frame.height < 650 {
            return 90
        }else{
            return 120
        }
    }
}

extension DiaryViewController:UpdateDiaryByLookDiaryViewDelegate{
    func configureText(title: String, text: String) {
        return
    }
    
    func updateDiaryByLookDiaryView() {
        diaryViewModel.setDiaryData()
        diaryTableView.reloadData()
    }
}
