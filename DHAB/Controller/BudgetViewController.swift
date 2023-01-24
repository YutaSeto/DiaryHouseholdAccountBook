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
    var expenceItemList:[ExpenceItemModel] = []
    var expenceItemViewDelegate:ExpenceItemViewControllerDelegate?
    var paymentBudgetList:[PaymentBudgetModel] = []
    var budgetViewControllerDelegate:BudgetViewControllerDelegate?
    
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
        dateFormatter.dateFormat = "yy年MM月"
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
        let realm = try! Realm()
        let result = realm.objects(ExpenceItemModel.self)
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
        cell.budgetExpenceItemLabel.text = expenceItemList[indexPath.row].category
        
        let realm = try! Realm()
        let paymentBudgetData = realm.objects(PaymentBudgetModel.self)
        for i in 0 ..< paymentBudgetList.count{
            if dateFormatter.string(from: paymentBudgetData[i].budgetDate) == dateFormatter.string(from: date) && paymentBudgetData[i].budgetExpenceItem == cell.budgetExpenceItemLabel.text{
                cell.budgetPriceLabel.text! = String(paymentBudgetData[i].budgetPrice)
                break
            } else {
                cell.budgetPriceLabel.text = "0"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expenceItemCell = expenceItemList[indexPath.row]
        budgetViewControllerDelegate = self
        
        let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
        var textFieldOnAlert = UITextField()
        alert.addTextField{textField in
            textFieldOnAlert = textField
            textField.placeholder = "0"
        }
        
        let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        if cell.budgetPriceLabel.text! == "0"{
            let add = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                let realm = try! Realm()
                let budgetData = PaymentBudgetModel()
                try! realm.write{
                    budgetData.budgetExpenceItem = expenceItemCell.category
                    budgetData.budgetPrice = Int(textFieldOnAlert.text!)!
                    budgetData.budgetDate = self.date
                    realm.add(budgetData)
                    print(budgetData)
                }
                self.budgetViewControllerDelegate?.updateList()
                self.budgetTableView.reloadData()
            })
            
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                print("ミスしてます")
                return
            })
            
            alert.addAction(add)
            alert.addAction(cancel)
            
            self.present(alert,animated: true, completion: nil)
        }else{
            let add = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                let realm = try! Realm()
                let budgetData = PaymentBudgetModel()//ここが違う
                try! realm.write{
                    budgetData.budgetExpenceItem = expenceItemCell.category
                    budgetData.budgetPrice = Int(textFieldOnAlert.text!)!
                    budgetData.budgetDate = self.date
                }
                self.budgetViewControllerDelegate?.updateList()
                self.budgetTableView.reloadData()
            })
            
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            
            alert.addAction(add)
            alert.addAction(cancel)
            
            self.present(alert,animated: true, completion: nil)
        }
    }
}

extension BudgetViewController:BudgetViewControllerDelegate{
    func updateList(){
        setPaymentData()
        setExpenceItemData()
    }
}
