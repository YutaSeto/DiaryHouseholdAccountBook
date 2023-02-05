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
    var categoryViewControllerDelegate:ExpenseItemViewControllerDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var expenseItemTableView: UITableView!
    
    @IBAction func addButton(_ sender: UIButton) {
        tapAddButton()
    }
    
    func configureAddButton(){
        addButton.layer.cornerRadius = addButton.bounds.width / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCategoryData()
        expenseItemTableView.delegate = self
        expenseItemTableView.dataSource = self
        configureAddButton()
    }
    
    @objc func tapAddButton(){
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
        
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert,animated:true, completion: nil)
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
        expenseItemTableView.reloadData()
    }
    

}

extension ExpenseItemViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenseItemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = categoryList[indexPath.row].name
        return cell
    }

    
    
    //あとで変更必要
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let targetItem = categoryList[indexPath.row]
        let realm = try! Realm()
        try! realm.write{
            realm.delete(targetItem)
        }
        categoryList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension ExpenseItemViewController:ExpenseItemViewControllerDelegate{
    func updateCategory() {
        setCategoryData()
    }
}
