//
//  BudgetViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/16.
//

import Foundation
import UIKit
import RealmSwift

protocol BudgetViewControllerDelegate{
    func updateList()
}

class BudgetViewController: UIViewController{
    
    private var date = Date()
    var categoryList:[CategoryModel] = []
    var paymentBudgetList:[PaymentBudgetModel] = []
    var budgetTableViewDataSource: [BudgetTableViewCellItem] = []
    var budgetViewControllerDelegate:BudgetViewControllerDelegate?
    let realm = try! Realm()
    
    @IBOutlet weak var budgetTableView: UITableView!
    @IBOutlet weak var dateBackButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePassButton: UIButton!
    
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
        budgetConfigureViewController.date = date
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapConfigureButton)
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    func dayBack(){
        budgetViewControllerDelegate = self
        date = Calendar.current.date(byAdding: .month, value: -1, to:date)!
        setMonthFirstAndEnd()
        dateLabel.text = dateFormatter.string(from: date)
        self.budgetViewControllerDelegate?.updateList()
        budgetTableView.reloadData()
    }
    
    func dayPass(){
        budgetViewControllerDelegate = self
        date = Calendar.current.date(byAdding: .month, value: 1, to:date)!
        setMonthFirstAndEnd()
        dateLabel.text = dateFormatter.string(from: date)
        self.budgetViewControllerDelegate?.updateList()
        budgetTableView.reloadData()
    }
    
    private var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    func setMonthFirstAndEnd(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        dateLabel.text = dateFormatter.string(from: date)
        budgetTableView.delegate = self
        budgetTableView.dataSource = self
        setPaymentBudgetData()
        setCategoryData()
        setBudgetTableViewDataSourse()
        setNavigationBarButton()
    }
    

    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
        budgetTableView.reloadData()
    }
    
    func setPaymentBudgetData(){
        let result = realm.objects(PaymentBudgetModel.self)
        paymentBudgetList = Array(result)
        budgetTableView.reloadData()
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
            
            budgetTableView.reloadData()
        }
    }
    
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        budgetTableViewDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        let item = budgetTableViewDataSource[indexPath.row]
        cell.budgetCategoryLabel.text = item.name
        cell.budgetPriceLabel.text = String(item.price)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        budgetViewControllerDelegate = self
        
        let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
        
        var textFieldOnAlert = UITextField()
        alert.addTextField{textField in
            textFieldOnAlert = textField
            textField.placeholder = "0"
        }
        let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
            let dataSource = self.budgetTableViewDataSource[indexPath.row]
            if let budget = self.paymentBudgetList.filter({$0.id == dataSource.id}).first{
                let realm = try!Realm()
                try! realm.write{
                    budget.budgetPrice = Int(textFieldOnAlert.text!)!
                }
            }
            self.budgetViewControllerDelegate?.updateList()
            self.budgetTableView.reloadData()
        })
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(cancel)
        alert.addAction(edit)
        self.present(alert,animated: true, completion: nil)
    }
}

extension BudgetViewController:BudgetViewControllerDelegate{
    func updateList(){
        setPaymentBudgetData()
        setCategoryData()
        budgetTableViewDataSource = []
        setBudgetTableViewDataSourse()
    }
}
