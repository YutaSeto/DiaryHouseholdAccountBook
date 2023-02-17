//
//  ExpenceItemViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/16.
//

import Foundation
import UIKit
import RealmSwift

protocol ExpenseItemViewControllerDelegate{
    func updateCategory()
}

class ExpenseItemViewController: UIViewController{
    
    let realm = try! Realm()
    var categoryList:[CategoryModel] = []
    var incomeCategoryList:[IncomeCategoryModel] = []
    var categoryViewControllerDelegate:ExpenseItemViewControllerDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var expenseItemTableView: UITableView!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCategoryData()
        setIncomeCategoryData()
        settingSubView()
        expenseItemTableView.delegate = self
        expenseItemTableView.dataSource = self
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        addPaymentView()
        configureAddButton()
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addPaymentView()
        case 1:
            addIncomeView()
        default:
            return
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        tapAddPaymentButton()
    }
    
    @IBAction func addIncomeButton(_ sender: UIButton) {
        tapAddIncomeButton()
    }
    
    func configureAddButton(){
        addButton.layer.cornerRadius = addButton.bounds.width / 2
        addIncomeButton.layer.cornerRadius = addIncomeButton.bounds.width / 2
    }
    
    func addPaymentView(){
        incomeView.removeFromSuperview()
        self.view.addSubview(paymentView)
    }
    func addIncomeView(){
        paymentView.removeFromSuperview()
        self.view.addSubview(incomeView)
    }
    
    func settingSubView(){
        paymentView.frame = CGRect(x: 0,
                                                y: segmentedControl.frame.minY,
                                                width: self.view.frame.width,
                                                height: (self.view.frame.height - segmentedControl.frame.minY))
        incomeView.frame = CGRect(x: 0,
                                 y: segmentedControl.frame.minY,
                                 width: self.view.frame.width,
                                 height: (self.view.frame.height - segmentedControl.frame.minY))
    }
    
    @objc func tapAddPaymentButton(){
        categoryViewControllerDelegate = self
        let alert = UIAlertController(title: "カテゴリーを追加します", message: nil, preferredStyle: .alert)
        var textFieldOnAlert = UITextField()
        alert.addTextField{ textField in
            textFieldOnAlert = textField
            textField.placeholder = "カテゴリーの名前を入力してください"
        }
        
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) -> Void in
            let categoryModel = CategoryModel()
            let realm = try!Realm()
            try! realm.write{
                categoryModel.name = textFieldOnAlert.text!
                realm.add(categoryModel)
                self.categoryViewControllerDelegate?.updateCategory()
                self.expenseItemTableView.reloadData()
            }
        })
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        
        alert.addAction(cancel)
        alert.addAction(add)
        
        self.present(alert,animated:true, completion: nil)
    }
    
    @objc func tapAddIncomeButton(){
        categoryViewControllerDelegate = self
        let alert = UIAlertController(title: "カテゴリーを追加します", message: nil, preferredStyle: .alert)
        var textFieldOnAlert = UITextField()
        alert.addTextField{ textField in
            textFieldOnAlert = textField
            textField.placeholder = "カテゴリーの名前を入力してください"
        }
        
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) -> Void in
            let incomeCategoryModel = IncomeCategoryModel()
            let realm = try!Realm()
            try! realm.write{
                incomeCategoryModel.name = textFieldOnAlert.text!
                realm.add(incomeCategoryModel)
                self.categoryViewControllerDelegate?.updateCategory()
                self.incomeTableView.reloadData()
            }
        })
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        
        alert.addAction(cancel)
        alert.addAction(add)
        
        self.present(alert,animated:true, completion: nil)
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
        expenseItemTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(IncomeCategoryModel.self)
        incomeCategoryList = Array(result)
        incomeTableView.reloadData()
    }
    

}

extension ExpenseItemViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return categoryList.count
        }else if tableView.tag == 1{
            return incomeCategoryList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = expenseItemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = categoryList[indexPath.row].name
            return cell
        }else if tableView.tag == 1{
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = incomeCategoryList[indexPath.row].name
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            categoryViewControllerDelegate = self
            let alert = UIAlertController(title: "\(categoryList[indexPath.row].name)のカテゴリー名を変更します", message: nil, preferredStyle: .alert)
            var textFieldOnAlert = UITextField()
            alert.addTextField{ textField in
                textFieldOnAlert = textField
                textField.placeholder = "新しいカテゴリーの名前を入力してください"
            }
            
            let add = UIAlertAction(title:"変更する", style: .default,handler: {(action) -> Void in
                let realm = try!Realm()
                try! realm.write{
                    self.categoryList[indexPath.row].name = textFieldOnAlert.text!
                    self.categoryViewControllerDelegate?.updateCategory()
                }
            })
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            alert.addAction(cancel)
            alert.addAction(add)
            self.present(alert,animated:true, completion: nil)
        }else if tableView.tag == 1{
            let alert = UIAlertController(title: "\(incomeCategoryList[indexPath.row].name)のカテゴリー名を変更します", message: nil, preferredStyle: .alert)
            var textFieldOnAlert = UITextField()
            alert.addTextField{ textField in
                textFieldOnAlert = textField
                textField.placeholder = "新しいカテゴリーの名前を入力してください"
            }
            
            let add = UIAlertAction(title:"変更する", style: .default,handler: {(action) -> Void in
                let realm = try!Realm()
                try! realm.write{
                    self.incomeCategoryList[indexPath.row].name = textFieldOnAlert.text!
                    self.categoryViewControllerDelegate?.updateCategory()
                }
            })
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            alert.addAction(cancel)
            alert.addAction(add)
            self.present(alert,animated:true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            let targetItem = categoryList[indexPath.row]
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            categoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }else if tableView.tag == 1{
            let targetItem = incomeCategoryList[indexPath.row]
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            incomeCategoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ExpenseItemViewController:ExpenseItemViewControllerDelegate{
    func updateCategory() {
        setCategoryData()
        setIncomeCategoryData()
    }
}
