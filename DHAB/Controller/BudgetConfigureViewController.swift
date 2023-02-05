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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        budgetConfigureTableView.register(UINib(nibName: "BudgetConfigureTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        budgetConfigureTableView.delegate = self
        budgetConfigureTableView.dataSource = self
        setCategoryData()
        setPaymentBudgetData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = budgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
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
            print(self.budgetTableViewDataSource)
        })
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(edit)
        alert.addAction(cancel)
        self.present(alert,animated: true, completion: nil)
    }
}
