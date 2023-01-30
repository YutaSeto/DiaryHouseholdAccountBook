//
//  BudgetConfigureView.swift
//  DHAB
//
//  Created by setoon on 2023/01/19.
//

import Foundation
import RealmSwift
import UIKit

class BudgetConfigureViewController: UIViewController{
    
    var date: Date = Date()
    var expenceItemList = [""]
    var paymentBudgetList:[PaymentBudgetModel] = []
    var expenceItemViewDelegate:ExpenceItemViewControllerDelegate?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var budgetConfigureTableView: UITableView!
    
    private var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    func setPaymentBudgetData(){
        _ = try! Realm()
        let result = Array(Set(paymentBudgetList.map({$0.budgetExpenceItem})))
        expenceItemList = Array(result)
        budgetConfigureTableView.reloadData()
    }
    
    func setExpenceItemData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentBudgetModel.self)
        paymentBudgetList = Array(result)
        budgetConfigureTableView.reloadData()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        budgetConfigureTableView.register(UINib(nibName: "BudgetConfigureTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        budgetConfigureTableView.delegate = self
        budgetConfigureTableView.dataSource = self
        setExpenceItemData()
        setPaymentBudgetData()
    }
    
}

extension BudgetConfigureViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenceItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
        //費目についての記述
        cell.expenceItemLabel.text = expenceItemList[indexPath.row]
        
        //予算についての記述
        let realm = try! Realm()
        let paymentBudgetData = realm.objects(PaymentBudgetModel.self)
        for i in 0 ..< paymentBudgetData.count{
            if dateFormatter.string(from: paymentBudgetData[i].budgetDate) == dateFormatter.string(from: date) && paymentBudgetData[i].budgetExpenceItem == cell.expenceItemLabel.text{
                cell.priceTextField.text = String(paymentBudgetData[i].budgetPrice)
                break
            } else {
                cell.priceTextField.text = "0"
            }
        }
        return cell
    }
}
