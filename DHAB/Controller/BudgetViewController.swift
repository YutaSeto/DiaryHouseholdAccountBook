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
        cell.budgetExpenceItemLabel.text = expenceItemList[indexPath.row]
        
        let realm = try! Realm()
        let paymentBudgetData = realm.objects(PaymentBudgetModel.self)
        for i in 0 ..< paymentBudgetList.count{
            if dateFormatter.string(from: paymentBudgetData[i].budgetDate) == dateFormatter.string(from: date) && paymentBudgetData[i].budgetExpenceItem == cell.budgetExpenceItemLabel.text{
                cell.budgetPriceLabel.text! = String(paymentBudgetData[i].budgetPrice)
                print("何を保存しているのか\(cell.budgetPriceLabel.text!)")
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = budgetTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        print(cell.budgetPriceLabel.text!)
        _ = expenceItemList[indexPath.row]
        
        cell.budgetExpenceItemLabel.text = expenceItemList[indexPath.row]
        budgetViewControllerDelegate = self
        
        let realm = try! Realm()
        let paymentBudgetData = realm.objects(PaymentBudgetModel.self)
        
        let alert = UIAlertController(title:"予算を変更します", message: nil, preferredStyle: .alert)
        
        var textFieldOnAlert = UITextField()
        alert.addTextField{textField in
            textFieldOnAlert = textField
            textField.placeholder = "0"
        }
        
        var isDateAndExpenceItemSame:Bool = false
        func dateAndExpenceItemEqual(){
            for i in 0 ..< paymentBudgetList.count{
                if dateFormatter.string(from: paymentBudgetData[i].budgetDate) == dateFormatter.string(from: date) && paymentBudgetData[i].budgetExpenceItem == cell.budgetExpenceItemLabel.text && paymentBudgetData[i].budgetPrice == Int(cell.budgetPriceLabel.text!){
                    isDateAndExpenceItemSame = true
                }
            }
            return
        }
        
        var isDateOrExpenceItemNotSame:Bool = false
        func dateOrExpenceItemNotEqual(){
            for i in 0 ..< paymentBudgetList.count{
                if dateFormatter.string(from: paymentBudgetData[i].budgetDate) != dateFormatter.string(from: date) && paymentBudgetData[i].budgetExpenceItem != cell.budgetExpenceItemLabel.text{
                    isDateOrExpenceItemNotSame = true
                }
            }
        }
        
        if isDateAndExpenceItemSame{
            let edit = UIAlertAction(title:"修正する",style: .default, handler:{(action) ->Void in
                let realm = try! Realm()
                let budgetData = realm.objects(PaymentBudgetModel.self).filter("budgetExpenceItem CONTAINS %@" ,self.expenceItemList[indexPath.row])
                try! realm.write{
                    budgetData[0].budgetExpenceItem = self.expenceItemList[indexPath.row]
                    budgetData[0].budgetPrice = Int(textFieldOnAlert.text!)!
                    budgetData[0].budgetDate = self.date
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
            
            print(dateAndExpenceItemEqual())
            print(dateOrExpenceItemNotEqual())
            
            
        }else if isDateOrExpenceItemNotSame{
            let add = UIAlertAction(title:"追加する",style: .default, handler:{(action) ->Void in
                let realm = try! Realm()
                let budgetData = PaymentBudgetModel()
                try! realm.write{
                    budgetData.budgetExpenceItem = self.expenceItemList[indexPath.row]
                    budgetData.budgetPrice = Int(textFieldOnAlert.text!)!
                    budgetData.budgetDate = self.date
                    realm.add(budgetData)
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
            
        }else{
            print("その他")
        }
    }
}

extension BudgetViewController:BudgetViewControllerDelegate{
    func updateList(){
        setPaymentData()
        setExpenceItemData()
    }
}
