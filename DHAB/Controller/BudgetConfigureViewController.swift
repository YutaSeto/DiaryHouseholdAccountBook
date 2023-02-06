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
    
    let realm = try! Realm()
    var date: Date = Date()
    var categoryList:[CategoryModel] = []
    var paymentBudgetList:[PaymentBudgetModel] = []
    var budgetTableViewDataSource: [BudgetTableViewCellItem] = []
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var budgetConfigureTableView: UITableView!
    
    @IBAction func saveButton(_ sender: UIButton) {
        tapSaveButton()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        navigationController?.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
    
    func tapSaveButton(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
        budgetTableViewDataSource.forEach{ category in
            if let data:PaymentBudgetModel = dayCheckBudget2.filter({$0.id == category.id}).first{
//                data.budgetPrice = category[indexPath.row].priceTextField.text!
            }
            
        }
        
        
        navigationController?.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
    
    private var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    func setPaymentBudgetData(){
        let result = realm.objects(PaymentBudgetModel.self)
        paymentBudgetList = Array(result)
        budgetConfigureTableView.reloadData()
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
        budgetConfigureTableView.reloadData()
    }
    
    func setBudgetTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        categoryList.forEach{ expense in
            let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay})
            let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
            if let budget:PaymentBudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).first{
                let item = BudgetTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                budgetTableViewDataSource.append(item)
            } else {
                let budget = PaymentBudgetModel()
                budget.id = UUID().uuidString
                budget.expenseID = expense.id
                budget.budgetDate = date
                budget.budgetPrice = 0
                try! realm.write { realm.add(budget)}
                paymentBudgetList.append(budget)
                
                let item = BudgetTableViewCellItem(
                    id:budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                budgetTableViewDataSource.append(item)
            }
            
            budgetConfigureTableView.reloadData()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        budgetConfigureTableView.register(UINib(nibName: "BudgetConfigureTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        budgetConfigureTableView.delegate = self
        budgetConfigureTableView.dataSource = self
        setCategoryData()
        setPaymentBudgetData()
        setBudgetTableViewDataSourse()
        dateLabel.text = dateFormatter.string(from:date)
    }
    
}

extension BudgetConfigureViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        budgetTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
        let item = budgetTableViewDataSource[indexPath.row]
        cell.categoryLabel.text = item.name
        cell.priceTextField.text = String(item.price)
        return cell
    }
    
}
