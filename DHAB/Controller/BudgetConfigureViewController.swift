//
//  BudgetConfigureView.swift
//  DHAB
//
//  Created by setoon on 2023/01/19.
//

import Foundation
import RealmSwift
import UIKit

protocol BudgetConfigureViewControllerDelegate{
    func updateBudget()
}

class BudgetConfigureViewController: UIViewController{
    
    let util = Util()
    let realm = try! Realm()
    var date: Date = Date()
    var delegate:BudgetConfigureViewControllerDelegate?
    var categoryList:[CategoryModel] = []
    var incomeCategoryList:[CategoryModel] = []
    var paymentBudgetList:[BudgetModel] = []
    var incomeBudgetList:[BudgetModel] = []
    var budgetTableViewDataSource: [BudgetTableViewCellItem] = []
    var incomeBudgetTableViewDataSource: [IncomeBudgetTableViewCellItem] = []
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var budgetConfigureTableView: UITableView!
    @IBOutlet weak var incomeBudgetConfigureTableView: UITableView!
    @IBOutlet weak var budgetTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        budgetConfigureTableView.register(UINib(nibName: "BudgetConfigureTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        incomeBudgetConfigureTableView.register(UINib(nibName: "BudgetConfigureTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        budgetConfigureTableView.delegate = self
        budgetConfigureTableView.dataSource = self
        incomeBudgetConfigureTableView.delegate = self
        incomeBudgetConfigureTableView.dataSource = self
        setCategoryData()
        setIncomeCategoryData()
        setPaymentBudgetData()
        setIncomeBudgetData()
        setBudgetTableViewDataSourse()
        setIncomeBudgetTableViewDataSourse()
        dateLabel.text = util.monthDateFormatter.string(from:date)
        configureNavigationBarButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        budgetTableViewHeight.constant = CGFloat(budgetConfigureTableView.contentSize.height)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        tapSaveButton()
        navigationController?.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
    
    func tapSaveButton(){
        budgetTableViewDataSource.forEach{ data in
            if let index = paymentBudgetList.firstIndex(where: {$0.id == data.id}){
                try! realm.write{
                    paymentBudgetList[index].budgetPrice = data.price
                }
            }
        }
        incomeBudgetTableViewDataSource.forEach{ data in
            if let index = incomeBudgetList.firstIndex(where: {$0.id == data.id}){
                try! realm.write{
                    incomeBudgetList[index].budgetPrice = data.price
                }
            }
        }
        delegate?.updateBudget()
    }
    
    @objc func tapBackButton(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName:"arrow.uturn.backward"), style: .plain
                                            ,target: self,action: buttonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        navigationController?.popToViewController(navigationController!.viewControllers[0], animated: true)
    }

    func setPaymentBudgetData(){
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == true}
        paymentBudgetList = Array(result)
        budgetConfigureTableView.reloadData()
    }
    
    func setIncomeBudgetData(){
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == false}
        incomeBudgetList = Array(result)
        incomeBudgetConfigureTableView.reloadData()
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == true}
        categoryList = Array(result)
        budgetConfigureTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
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
    
    func setIncomeBudgetTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        incomeCategoryList.forEach{ expense in
            let dayCheckBudget = incomeBudgetList.filter({$0.budgetDate >= firstDay})
            let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
            if let budget:BudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).first{
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
                budget.budgetDate = date
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
            incomeBudgetConfigureTableView.reloadData()
        }
    }
}

extension BudgetConfigureViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === budgetConfigureTableView{
            return "支出"
        }else if tableView === incomeBudgetConfigureTableView{
            return "収入"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === budgetConfigureTableView{
            return budgetTableViewDataSource.count
        }else if tableView === incomeBudgetConfigureTableView{
            return incomeBudgetTableViewDataSource.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === budgetConfigureTableView{
            let cell = budgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
            var item = budgetTableViewDataSource[indexPath.row]
            cell.data = item
            cell.categoryLabel.text = item.name
            cell.priceTextField.text = String(item.price)
            item.price = cell.price
            cell.delegate = self
            return cell
        }else if tableView === incomeBudgetConfigureTableView{
            let cell = incomeBudgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
            var item = incomeBudgetTableViewDataSource[indexPath.row]
            cell.incomeData = item
            cell.categoryLabel.text = item.name
            cell.priceTextField.text = String(item.price)
            item.price = cell.price
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
}

extension BudgetConfigureViewController: BudgetConfigureTableViewCellDelegate{
    func tableViewCell(didChangeTextIncome text: String, incomeData: IncomeBudgetTableViewCellItem?) {
        guard let data = incomeData else {return}
        if let index = incomeBudgetTableViewDataSource.firstIndex(where: {$0.id == data.id}){
            incomeBudgetTableViewDataSource[index].price = incomeData!.price
        }
    }
    
    func tableViewCell(didChngeText text: String, data: BudgetTableViewCellItem?) {
        guard let data = data else {return}
        if let index = budgetTableViewDataSource.firstIndex(where: {$0.id == data.id}){
            budgetTableViewDataSource[index].price = data.price
        }
    }
    
}
