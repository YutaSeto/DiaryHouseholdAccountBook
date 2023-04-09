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
    let budgetViewModel = BudgetViewModel()
    
    var budgetViewControllerDelegate:BudgetViewControllerDelegate?
    var forHouseholdAccountBookDelegate:ForHouseholdAccountBookDeleagte?
    var inputViewControllerDelegate:InputViewControllerDelegate?
    
    @IBOutlet weak var budgetTableView: UITableView!
    @IBOutlet weak var dateBackButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePassButton: UIButton!
    @IBOutlet var menuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        dateLabel.text = util.monthDateFormatter.string(from: budgetViewModel.date)
        budgetTableView.delegate = self
        budgetTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.dataSource = self
        budgetViewModel.setPaymentBudgetData()
        budgetViewModel.setIncomeBudgetData()
        budgetViewModel.setCategoryData()
        budgetViewModel.setIncomeCategoryData()
        budgetViewModel.setBudgetTableViewDataSourse()
        budgetViewModel.setIncomeBudgetTableViewDataSourse()
        setNavigationBarButton()
        setStatusBarBackgroundColor(.flatPowderBlueColorDark())
        addSubView()
        setMenuView()
    }
    
    @IBAction func dateBackButton(_ sender: UIButton) {
        dayBack()
        budgetViewModel.isExpanded = false
    }
    
    @IBAction func datePassButton(_ sender: UIButton) {
        dayPass()
        budgetViewModel.isExpanded = false
    }
    
    func addSubView(){
        view.addSubview(menuView)
    }
    
    func setMenuView(){
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.topAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -10).isActive = true
        menuView.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func returnView(){
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations:  {
                self.menuView.frame.origin.x = self.view.frame.width + self.menuView.frame.width
            },
            completion: nil
        )
        budgetViewModel.isExpanded = false
    }
    
    func showMenu(shouldExpand:Bool){
        if shouldExpand{
            returnView()
            budgetViewModel.isExpanded = false
        }else{
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: {
                    self.menuView.frame.origin.x = self.view.frame.width - self.menuView.frame.width
                }, completion: nil)
            budgetViewModel.isExpanded = true
        }
    }
    
    @objc func tapMenuButton(){
        showMenu(shouldExpand: budgetViewModel.isExpanded)
    }
        
    @objc func tapBackButton(){
        dismiss(animated: true)
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapMenuButton)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
        
        let buttonActionSelector2:Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName:"xmark"), style: .plain,target: self,action: buttonActionSelector2)
        navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)
        
    }
    
    func dayBack(){
        budgetViewModel.date = Calendar.current.date(byAdding: .month, value: -1, to:budgetViewModel.date)!
        dateLabel.text = util.monthDateFormatter.string(from: budgetViewModel.date)
        updateList()
        budgetTableView.reloadData()
    }
    
    func dayPass(){
        budgetViewModel.date = Calendar.current.date(byAdding: .month, value: 1, to:budgetViewModel.date)!
        dateLabel.text = util.monthDateFormatter.string(from: budgetViewModel.date)
        updateList()
        budgetTableView.reloadData()
    }
    
    func updateList(){
        budgetViewModel.setPaymentBudgetData()
        budgetViewModel.setCategoryData()
        budgetViewModel.budgetTableViewDataSource = []
        budgetViewModel.incomeBudgetTableViewDataSource = []
        budgetViewModel.setBudgetTableViewDataSourse()
        budgetViewModel.setIncomeBudgetTableViewDataSourse()
        budgetTableView.reloadData()
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === budgetViewModel && section == 0{
            return "支出"
        }else if tableView === budgetViewModel && section == 1{
            return "収入"
        }
        else{
            return nil
        }
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === budgetTableView{
            if section == 0{
                return budgetViewModel.categoryList.count
            }else{
                return budgetViewModel.incomeCategoryList.count
            }
        }else if tableView === menuTableView{
            return budgetViewModel.menuList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === budgetTableView{
            let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            if indexPath.section == 0{
                let item = budgetViewModel.budgetTableViewDataSource[indexPath.row]
                cell.budgetCategoryLabel.text = item.name
                cell.budgetPriceLabel.text = String(item.price)
                return cell
            }else{
                let item = budgetViewModel.incomeBudgetTableViewDataSource[indexPath.row]
                cell.budgetCategoryLabel.text = item.name
                cell.budgetPriceLabel.text = String(item.price)
                return cell
            }
        }else if tableView === menuTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath)
            cell.textLabel!.text = budgetViewModel.menuList[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === budgetTableView{
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === budgetTableView{
            if indexPath.section == 0{
                _ = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
                
                let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
                
                var textFieldOnAlert = UITextField()
                alert.addTextField{textField in
                    textFieldOnAlert = textField
                    textField.placeholder = String(self.budgetViewModel.budgetTableViewDataSource[indexPath.row].price)
                    textField.textAlignment = NSTextAlignment.right
                }
                
                let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                    let dataSource = self.budgetViewModel.budgetTableViewDataSource[indexPath.row]
                    if let budget = self.budgetViewModel.paymentBudgetList.filter({$0.id == dataSource.id}).first{
                        let realm = try!Realm()
                        try! realm.write{
                            budget.budgetPrice = Int(textFieldOnAlert.text!)!
                        }
                    }
                    self.updateList()
                    self.budgetViewControllerDelegate?.updateList()
                })
                
                let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                    return
                })
                
                alert.addAction(cancel)
                alert.addAction(edit)
                self.present(alert,animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }else{
                _ = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
                let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
                
                var textFieldOnAlert = UITextField()
                alert.addTextField{textField in
                    textFieldOnAlert = textField
                    textField.placeholder = String(self.budgetViewModel.incomeBudgetTableViewDataSource[indexPath.row].price)
                    textField.textAlignment = NSTextAlignment.right
                }
                let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                    let dataSource = self.budgetViewModel.incomeBudgetTableViewDataSource[indexPath.row]
                    if let budget = self.budgetViewModel.incomeBudgetList.filter({$0.id == dataSource.id}).first{
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
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }else if tableView === menuTableView{
            if indexPath.row == 0{
                let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
                let budgetConfigureViewController = storyboard.instantiateViewController(identifier: "BudgetConfigureViewController") as! BudgetConfigureViewController
                navigationController?.pushViewController(budgetConfigureViewController, animated: true)
                budgetConfigureViewController.forHouseholdAccountBookDelegate = forHouseholdAccountBookDelegate
                budgetConfigureViewController.delegate = self
                budgetConfigureViewController.budgetConfigureViewModel.date = budgetViewModel.date.zeroclock
            }else{
                let calendar = Calendar(identifier: .gregorian)
                let comps = calendar.dateComponents([.year, .month], from: budgetViewModel.date.zeroclock)
                let minusMonth = DateComponents(month: -1)
                let thisMonth = calendar.date(from:comps)!.zeroclock
                let lastMonth = calendar.date(byAdding: minusMonth, to: thisMonth)?.zeroclock
                let nextMonth = util.setLastDay(date: budgetViewModel.date.zeroclock)
                let lastPaymentBudgetList = budgetViewModel.paymentBudgetList.filter{$0.budgetDate >= lastMonth!}.filter{$0.budgetDate < thisMonth}
                let lastIncomeBudgetList = budgetViewModel.incomeBudgetList.filter{$0.budgetDate >= lastMonth!}.filter{$0.budgetDate < thisMonth}
                let thisMonthPaymentBudget:[Budget] = self.budgetViewModel.paymentBudgetList.filter{$0.budgetDate >= thisMonth}.filter{$0.budgetDate < nextMonth}//今月の予算一覧
                let thisMonthIncomeBudget:[Budget] = self.budgetViewModel.incomeBudgetList.filter{$0.budgetDate >= thisMonth}.filter{$0.budgetDate < nextMonth}
                let alert = UIAlertController(title: "\(util.monthDateFormatter.string(from:lastMonth!))の予算をコピーします", message: nil, preferredStyle: .alert)
                let copy = UIAlertAction(title:"コピーする", style: .default,handler: {(action) -> Void in
                    
                    thisMonthPaymentBudget.forEach{budget in
                        if let target = lastPaymentBudgetList.first(where: {$0.expenseID == budget.expenseID}){
                            let realm = try! Realm()
                            try! realm.write{
                                budget.budgetPrice = target.budgetPrice
                            }
                        }
                    }
                    
                    thisMonthIncomeBudget.forEach{budget in
                        if let target = lastIncomeBudgetList.first(where: {$0.expenseID == budget.expenseID}){
                            let realm = try! Realm()
                            try! realm.write{
                                budget.budgetPrice = target.budgetPrice
                            }
                        }
                    }
                    self.updateList()
                    self.budgetViewControllerDelegate?.updateList()
                })
                let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                    return
                })
                
                
                alert.addAction(cancel)
                alert.addAction(copy)
                
                self.present(alert,animated:true, completion: nil)
            }
                //alertを表示、先月の予算をforEach文で予算をコピー
        }
        budgetViewModel.isExpanded = false
    }
}


extension BudgetViewController:BudgetConfigureViewControllerDelegate{
    func updateBudget(){
        budgetViewModel.setPaymentBudgetData()
        budgetViewModel.setIncomeCategoryData()
        budgetViewModel.setCategoryData()
        budgetViewModel.budgetTableViewDataSource = []
        budgetViewModel.incomeBudgetTableViewDataSource = []
        budgetViewModel.setBudgetTableViewDataSourse()
        budgetViewModel.setIncomeBudgetTableViewDataSourse()
        budgetTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}
