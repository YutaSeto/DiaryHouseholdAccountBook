//
//  ExpenceItemViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/16.
//

import Foundation
import UIKit
import RealmSwift

protocol ExpenceItemViewControllerDelegate{
    func updateExpenceItem()
}

class ExpenceItemViewController: UIViewController{
    
    var expenceItemList:[ExpenceItemModel] = []
    var expenceItemViewDelegate:ExpenceItemViewControllerDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var expenceItemTableView: UITableView!
    
    @IBAction func addButton(_ sender: UIButton) {
        tapAddButton()
    }
    
    func configureAddButton(){
        addButton.layer.cornerRadius = addButton.bounds.width / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setExpenceItemData()
        expenceItemTableView.delegate = self
        expenceItemTableView.dataSource = self
        configureAddButton()
    }
    
    @objc func tapAddButton(){
        expenceItemViewDelegate = self
        let alert = UIAlertController(title: "カテゴリーを追加します", message: nil, preferredStyle: .alert)
        var textFieldOnAlert = UITextField()
        alert.addTextField{ textField in
            textFieldOnAlert = textField
            textField.placeholder = "カテゴリーの名前を入力してください"
        }
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) -> Void in
            let realm = try! Realm()
            try! realm.write{
                let expenceItemModel = ExpenceItemModel()
                expenceItemModel.category = textFieldOnAlert.text!
                realm.add(expenceItemModel)
            }
            self.expenceItemViewDelegate?.updateExpenceItem()
            self.expenceItemTableView.reloadData()
        })
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert,animated:true, completion: nil)
    }
    
    func setExpenceItemData(){
        let realm = try! Realm()
        let result = realm.objects(ExpenceItemModel.self)
        expenceItemList = Array(result)
        expenceItemTableView.reloadData()
    }
}

extension ExpenceItemViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenceItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenceItemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = expenceItemList[indexPath.row].category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    
    //あとで変更必要
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let targetItem = expenceItemList[indexPath.row]
        let realm = try! Realm()
        try! realm.write{
            realm.delete(targetItem)
        }
        expenceItemList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension ExpenceItemViewController:ExpenceItemViewControllerDelegate{
    func updateExpenceItem() {
        setExpenceItemData()
    }
}

