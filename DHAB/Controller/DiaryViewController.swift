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
    private var result: Results<DiaryModel>?
    
    @IBOutlet weak var inputDiaryButton: UIButton!
    @IBOutlet weak var diaryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        setDiaryData()
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        searchBar.delegate = self
        configureTapDiaryInputButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if RecognitionChange.shared.deleteDiary == true{
            setDiaryData()
            diaryTableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let realm = try! Realm()
        
        if searchText.isEmpty{
            let result = realm.objects(DiaryModel.self).sorted(byKeyPath: "date", ascending: false)
            diaryList = Array(result)
        }else{
            result = realm.objects(DiaryModel.self).filter("text CONTAINS %@ " , searchText).sorted(byKeyPath: "date", ascending: false)
            diaryList = Array(result!)
        }
        diaryTableView.reloadData()
    }
    

    @IBAction func inputDiaryButton(_ sender: UIButton) {
        tapInputDiaryButton()
    }
    
    func tapInputDiaryButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        let navigationController = UINavigationController(rootViewController: inputViewController)
        inputViewController.inputViewControllerDelegate = self
        present(navigationController,animated:true)
        inputViewController.isDiary = true
    }
    
    func configureTapDiaryInputButton(){
        inputDiaryButton.layer.cornerRadius = inputDiaryButton.bounds.width / 2
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
        cell.cellDateLabel.text = util.onliDayDateFormatter.string(from:diaryModel.date)
        cell.dayOfWeekLabel.text = util.dayOfWeekDateFormatter.string(from: diaryModel.date)
        cell.cellTitleLabel.text = diaryModel.title
        cell.cellTextLabel.text = diaryModel.text
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
}
