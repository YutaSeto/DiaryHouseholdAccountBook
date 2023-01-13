//
//  DiaryViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift
import UIKit

class DiaryViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,InputViewControllerDelegate{
    
    var diaryList: [DiaryModel] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        diaryList.count
    }
    var dateFormatter: DateFormatter{
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
        cell.cellTextTextView.text = diaryModel.text
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        setDiaryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        diaryTableView.delegate = self
    }
    
    @IBOutlet weak var diaryTableView: UITableView!
    
    func setDiaryData(){
        let realm = try! Realm()
        let result = realm.objects(DiaryModel.self)
        diaryList = Array(result)
        diaryTableView.reloadData()
    }
    
    func updatePayment() {
        return
    }
    
    func updateDiary() {
        setDiaryData()
    }
    
}
