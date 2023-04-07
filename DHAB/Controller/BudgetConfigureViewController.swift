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

protocol ForHouseholdAccountBookDeleagte{
    func updateHouseholdAccountBookView()
}

class BudgetConfigureViewController: UIViewController{
    
    let util = Util()
    let budgetConfigureViewModel = BudgetConfigureViewModel()
    var delegate:BudgetConfigureViewControllerDelegate?
    var forHouseholdAccountBookDelegate:ForHouseholdAccountBookDeleagte?
    
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
        budgetConfigureViewModel.setCategoryData()
        budgetConfigureViewModel.setIncomeCategoryData()
        budgetConfigureViewModel.setPaymentBudgetData()
        budgetConfigureViewModel.setIncomeBudgetData()
        budgetConfigureViewModel.setBudgetTableViewDataSourse()
        budgetConfigureViewModel.setIncomeBudgetTableViewDataSourse()
        dateLabel.text = util.monthDateFormatter.string(from:budgetConfigureViewModel.date)
        configureNavigationBarButton()
        setStatusBarBackgroundColor(.flatBlue())
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
        budgetConfigureViewModel.overwritePaymentBudget()
        budgetConfigureViewModel.overwriteIncomeBudget()
        delegate?.updateBudget()
        forHouseholdAccountBookDelegate?.updateHouseholdAccountBookView()
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
            return budgetConfigureViewModel.budgetTableViewDataSource.count
        }else if tableView === incomeBudgetConfigureTableView{
            return budgetConfigureViewModel.incomeBudgetTableViewDataSource.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === budgetConfigureTableView{
            let cell = budgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
            var item = budgetConfigureViewModel.budgetTableViewDataSource[indexPath.row]
            cell.data = item
            cell.categoryLabel.text = item.name
            cell.priceTextField.text = String(item.price)
            item.price = cell.price
            cell.delegate = self
            return cell
        }else if tableView === incomeBudgetConfigureTableView{
            let cell = incomeBudgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
            var item = budgetConfigureViewModel.incomeBudgetTableViewDataSource[indexPath.row]
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
        if let index = budgetConfigureViewModel.incomeBudgetTableViewDataSource.firstIndex(where: {$0.id == data.id}){
            budgetConfigureViewModel.incomeBudgetTableViewDataSource[index].price = incomeData!.price
        }
    }
    
    func tableViewCell(didChngeText text: String, data: BudgetTableViewCellItem?) {
        guard let data = data else {return}
        if let index = budgetConfigureViewModel.budgetTableViewDataSource.firstIndex(where: {$0.id == data.id}){
            budgetConfigureViewModel.budgetTableViewDataSource[index].price = data.price
        }
    }
    
}
