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
    var expenceItemList = [""]
    var expenceItemViewDelegate:ExpenceItemViewControllerDelegate?
    var paymentBudgetList:[PaymentBudgetModel] = []
    var budgetViewControllerDelegate:BudgetViewControllerDelegate?
    
    @IBOutlet weak var budgetTableView: UITableView!
    @IBOutlet weak var dateBackButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePassButton: UIButton!
    
    @IBAction func dateBackButton(_ sender: UIButton) {
        dayBack()
        monthSame(targetMonth: date)
    }
    
    @IBAction func datePassButton(_ sender: UIButton) {
        dayPass()
        monthSame(targetMonth: date)
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
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        budgetTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        dateLabel.text = dateFormatter.string(from: date)
        budgetTableView.delegate = self
        budgetTableView.dataSource = self
        setPaymentData()
        setExpenceItemData()
        setNavigationBarButton()
    }
    
    func setExpenceItemData(){
        _ = try! Realm()
        let result = Array(Set(paymentBudgetList.map({$0.budgetExpenceItem})))
        expenceItemList = Array(result)
        budgetTableView.reloadData()
    }
    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentBudgetModel.self)
        paymentBudgetList = Array(result)
    }
    
}

extension BudgetViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenceItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        let paymentBudgetModel:PaymentBudgetModel = paymentBudgetList[indexPath.row]
        cell.budgetPriceLabel.text = String(paymentBudgetModel.budgetPrice)
        cell.budgetExpenceItemLabel.text = paymentBudgetModel.budgetExpenceItem
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        budgetViewControllerDelegate = self
        
        let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
        
        var textFieldOnAlert = UITextField()
        alert.addTextField{textField in
            textFieldOnAlert = textField
            textField.placeholder = "0"
        }
        
        let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
            let budgetData = self.paymentBudgetList[indexPath.row]
            let realm = try! Realm()
            try! realm.write{
                budgetData.budgetExpenceItem = self.expenceItemList[indexPath.row]
                budgetData.budgetPrice = Int(textFieldOnAlert.text!)!
                budgetData.budgetDate = self.date
            }
            self.budgetViewControllerDelegate?.updateList()
            self.budgetTableView.reloadData()
        })
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(edit)
        alert.addAction(cancel)
        self.present(alert,animated: true, completion: nil)
    }
}

extension BudgetViewController:BudgetViewControllerDelegate{
    func updateList(){
        setPaymentData()
        setExpenceItemData()
    }
}
