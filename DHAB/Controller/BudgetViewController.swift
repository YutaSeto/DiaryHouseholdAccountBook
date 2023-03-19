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
    
    var util = Util()
    var date = Date()
    var categoryList:[CategoryModel] = []
    var incomeCategoryList:[CategoryModel] = []
    var paymentBudgetList:[BudgetModel] = []
    var incomeBudgetList:[BudgetModel] = []
    var budgetTableViewDataSource: [BudgetTableViewCellItem] = []
    var incomeBudgetTableViewDataSource: [IncomeBudgetTableViewCellItem] = []
    var budgetViewControllerDelegate:BudgetViewControllerDelegate?
    var inputViewControllerDelegate:InputViewControllerDelegate?
    let realm = try! Realm()
    
    @IBOutlet weak var budgetTableView: UITableView!
    @IBOutlet weak var incomeBudgetTableView: UITableView!
    @IBOutlet weak var dateBackButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePassButton: UIButton!
    @IBOutlet weak var budgetTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        incomeBudgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        dateLabel.text = util.monthDateFormatter.string(from: date)
        budgetTableView.delegate = self
        budgetTableView.dataSource = self
        incomeBudgetTableView.delegate = self
        incomeBudgetTableView.dataSource = self
        setPaymentBudgetData()
        setIncomeBudgetData()
        setCategoryData()
        setIncomeCategoryData()
        setBudgetTableViewDataSourse()
        setIncomeBudgetTableViewDataSourse()
        setNavigationBarButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        budgetTableViewHeight.constant = CGFloat(budgetTableView.contentSize.height)
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
        budgetConfigureViewController.delegate = self
        budgetConfigureViewController.date = date.zeroclock
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapConfigureButton)
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add,target: self,action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func dayBack(){
        date = Calendar.current.date(byAdding: .month, value: -1, to:date)!
        dateLabel.text = util.monthDateFormatter.string(from: date)
        updateList()
        budgetTableView.reloadData()
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .month, value: 1, to:date)!
        dateLabel.text = util.monthDateFormatter.string(from: date)
        updateList()
        budgetTableView.reloadData()
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == true}
        categoryList = Array(result)
        budgetTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
    }
    
    func setPaymentBudgetData(){
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == true}
        paymentBudgetList = Array(result)
        budgetTableView.reloadData()
    }
    
    func setIncomeBudgetData(){
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == false}
        incomeBudgetList = Array(result)
        incomeBudgetTableView.reloadData()
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
            if let budget:BudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).first{
                let item = BudgetTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                budgetTableViewDataSource.append(item)
            } else {
                let budget = BudgetModel()
                budget.id = UUID().uuidString
                budget.expenseID = expense.id
                budget.budgetDate = date.zeroclock
                budget.isPayment = true
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
        }
        budgetTableView.reloadData()
    }
    
    func setIncomeBudgetTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        incomeCategoryList.forEach{ expense in
            let dayCheckBudget = incomeBudgetList.filter({$0.budgetDate >= firstDay})
            let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
            if let budget:BudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).filter({$0.isPayment == false}).first{
                let item = IncomeBudgetTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                incomeBudgetTableViewDataSource.append(item)
            } else {
                let budget = BudgetModel()
                budget.id = UUID().uuidString
                budget.expenseID = expense.id
                budget.budgetDate = date.zeroclock
                budget.isPayment = false
                budget.budgetPrice = 0
                try! realm.write { realm.add(budget)}
                incomeBudgetList.append(budget)
                
                let item = IncomeBudgetTableViewCellItem(
                    id:budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                incomeBudgetTableViewDataSource.append(item)
            }
        }
        incomeBudgetTableView.reloadData()
    }
    
    func updateList(){
        setPaymentBudgetData()
        setCategoryData()
        budgetTableViewDataSource = []
        incomeBudgetTableViewDataSource = []
        setBudgetTableViewDataSourse()
        setIncomeBudgetTableViewDataSourse()
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.tag == 0{
            return "支出"
        }else if tableView.tag == 1{
            return "収入"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return budgetTableViewDataSource.count
        }else if tableView.tag == 1{
            return incomeBudgetTableViewDataSource.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = budgetTableViewDataSource[indexPath.row]
            cell.budgetCategoryLabel.text = item.name
            cell.budgetPriceLabel.text = String(item.price)
            return cell
        }else if tableView.tag == 1{
            let cell = incomeBudgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = incomeBudgetTableViewDataSource[indexPath.row]
            cell.budgetCategoryLabel.text = item.name
            cell.budgetPriceLabel.text = String(item.price)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            _ = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            
            let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
            
            var textFieldOnAlert = UITextField()
            alert.addTextField{textField in
                textFieldOnAlert = textField
                textField.placeholder = String(self.budgetTableViewDataSource[indexPath.row].price)
                textField.textAlignment = NSTextAlignment.right
            }
            
            let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                let dataSource = self.budgetTableViewDataSource[indexPath.row]
                if let budget = self.paymentBudgetList.filter({$0.id == dataSource.id}).first{
                    let realm = try!Realm()
                    try! realm.write{
                        budget.budgetPrice = Int(textFieldOnAlert.text!)!
                    }
                }
                
                self.budgetViewControllerDelegate!.updateList()
                self.updateList()
            })
            
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            
            alert.addAction(cancel)
            alert.addAction(edit)
            self.present(alert,animated: true, completion: nil)
        }else if tableView.tag == 1{
            _ = incomeBudgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
            
            var textFieldOnAlert = UITextField()
            alert.addTextField{textField in
                textFieldOnAlert = textField
                textField.placeholder = String(self.incomeBudgetTableViewDataSource[indexPath.row].price)
                textField.textAlignment = NSTextAlignment.right
            }
            let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                let dataSource = self.incomeBudgetTableViewDataSource[indexPath.row]
                if let budget = self.incomeBudgetList.filter({$0.id == dataSource.id}).first{
                    let realm = try!Realm()
                    try! realm.write{
                        budget.budgetPrice = Int(textFieldOnAlert.text!)!
                    }
                }
                self.budgetViewControllerDelegate?.updateList()
                self.updateList()
            })
            
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            alert.addAction(cancel)
            alert.addAction(edit)
            self.present(alert,animated: true, completion: nil)
        }
    }
}


extension BudgetViewController:BudgetConfigureViewControllerDelegate{
    func updateBudget(){
        setPaymentBudgetData()
        setCategoryData()
        budgetTableViewDataSource = []
        incomeBudgetTableViewDataSource = []
        setBudgetTableViewDataSourse()
        setIncomeBudgetTableViewDataSourse()
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}
