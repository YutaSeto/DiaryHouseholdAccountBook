//
//  BudgetViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/16.
//

import Foundation
import UIKit
import RealmSwift

class BudgetViewController: UIViewController{
    
    private var date = Date()
    
    @IBOutlet weak var budgetTableView: UITableView!
    @IBOutlet weak var dateBackButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePassButton: UIButton!
    @IBOutlet weak var configureButton: UIBarButtonItem!
    
    @IBAction func configureButton(_ sender: UIBarButtonItem) {
        tapConfigureButton()
    }
    
    @IBAction func dateBackButton(_ sender: UIButton) {
        dayBack()
    }
    
    @IBAction func datePassButton(_ sender: UIButton) {
        dayPass()
    }
    
    @objc func tapConfigureButton(){
        let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
        let budgetConfigureViewController = storyboard.instantiateViewController(identifier: "BudgetConfigureViewController") as! BudgetConfigureViewController
        navigationController?.pushViewController(budgetConfigureViewController, animated: true)
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapConfigureButton)
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    func dayBack(){
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    var expenceItemList:[ExpenceItemModel] = []
    var expenceItemViewDelegate:ExpenceItemViewControllerDelegate?
    
    public var budgetList = ["食費","衣類","保険"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = dateFormatter.string(from: date)
        budgetTableView.delegate = self
        budgetTableView.dataSource = self
        setExpenceItemData()
        setNavigationBarButton()
    }
    
    func setExpenceItemData(){
        let realm = try! Realm()
        let result = realm.objects(ExpenceItemModel.self)
        expenceItemList = Array(result)
        budgetTableView.reloadData()
    }
    
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenceItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = expenceItemList[indexPath.row].category
        return cell
    }
}
