//
//  DiaryViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift
import UIKit

class DiaryViewController:UIViewController,InputViewControllerDelegate,UISearchBarDelegate{
    
    //検索機能関連
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    
    //日記関連
    private var diaryList: [DiaryModel] = []
    private var result: Results<DiaryModel>?
    
    @IBOutlet weak var inputDiaryButton: UIButton!
    @IBAction func inputDiaryButton(_ sender: UIButton) {
        tapInputDiaryButton()
    }
    
    func tapInputDiaryButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        inputViewController.inputViewControllerDelegate = self
        present(inputViewController,animated:true)
        inputViewController.addDiaryView()
    }
    
    func configureTapDiaryInputButton(){
        inputDiaryButton.layer.cornerRadius = inputDiaryButton.bounds.width / 2
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        setDiaryData()
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        searchBar.delegate = self
        configureTapDiaryInputButton()
    }
    
    @IBOutlet weak var diaryTableView: UITableView!
    
    func setDiaryData(){
        let realm = try! Realm()
        let result = realm.objects(DiaryModel.self).sorted(byKeyPath: "date", ascending: false)
        diaryList = Array(result)
        diaryTableView.reloadData()
    }
    
    func updatePayment() {
    }
    
    func updateDiary() {
        setDiaryData()
    }
    
}

extension DiaryViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diaryList.count
    }
    private var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
        let diaryModel: DiaryModel = diaryList[indexPath.row]
        cell.cellDateLabel.text = dateFormatter.string(from:diaryModel.date)
        cell.cellTitleLabel.text = diaryModel.title
        cell.cellTextLabel.text = diaryModel.text
        return cell
    }
}
