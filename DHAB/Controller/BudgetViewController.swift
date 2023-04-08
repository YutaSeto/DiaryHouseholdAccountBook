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
    @IBOutlet weak var incomeBudgetTableView: UITableView!
    @IBOutlet weak var dateBackButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePassButton: UIButton!
    @IBOutlet weak var budgetTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.debug("")
        
        budgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        incomeBudgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        dateLabel.text = util.monthDateFormatter.string(from: budgetViewModel.date)
        budgetTableView.delegate = self
        budgetTableView.dataSource = self
        incomeBudgetTableView.delegate = self
        incomeBudgetTableView.dataSource = self
        budgetViewModel.setPaymentBudgetData()
        budgetViewModel.setIncomeBudgetData()
        budgetViewModel.setCategoryData()
        budgetViewModel.setIncomeCategoryData()
        budgetViewModel.setBudgetTableViewDataSourse()
        budgetViewModel.setIncomeBudgetTableViewDataSourse()
        setNavigationBarButton()
        setStatusBarBackgroundColor(.flatPowderBlueColorDark())
        
        budgetTableView.reloadData()
        incomeBudgetTableView.reloadData()
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
        budgetConfigureViewController.forHouseholdAccountBookDelegate = forHouseholdAccountBookDelegate
        budgetConfigureViewController.delegate = self
        budgetConfigureViewController.budgetConfigureViewModel.date = budgetViewModel.date.zeroclock
    }
    
    @objc func tapBackButton(){
        dismiss(animated: true)
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapConfigureButton)
        let rightBarButton = UIBarButtonItem(title: "一括編集", style: .plain, target: self, action: buttonActionSelector)
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
        incomeBudgetTableView.reloadData()
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === budgetTableView{
            return "支出"
        }else if tableView === incomeBudgetTableView{
            return "収入"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === budgetTableView{
            return budgetViewModel.budgetTableViewDataSource.count
        }else if tableView === incomeBudgetTableView{
            return budgetViewModel.incomeBudgetTableViewDataSource.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === budgetTableView{
            let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = budgetViewModel.budgetTableViewDataSource[indexPath.row]
            cell.budgetCategoryLabel.text = item.name
            cell.budgetPriceLabel.text = String(item.price)
            return cell
        }else if tableView === incomeBudgetTableView{
            let cell = incomeBudgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = budgetViewModel.incomeBudgetTableViewDataSource[indexPath.row]
            cell.budgetCategoryLabel.text = item.name
            cell.budgetPriceLabel.text = String(item.price)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === budgetTableView{
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
        }else if tableView === incomeBudgetTableView{
            _ = incomeBudgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
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
        incomeBudgetTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}
