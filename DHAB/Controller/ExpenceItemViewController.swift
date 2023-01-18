//
//  ExpenceItemViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/16.
//

import Foundation
import UIKit

class ExpenceItemViewController: UIViewController{
    
    public var userDefaults = UserDefaults.standard
    public var expenceItemList = ["食費","衣類","通信費","保険"]
    
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
        expenceItemTableView.delegate = self
        expenceItemTableView.dataSource = self
        configureAddButton()
        userDefaults.set(expenceItemList, forKey: "キー")
    }
    
    @objc func tapAddButton(){
        var textField = UITextField()
        let alert = UIAlertController(title: "新しい項目の追加", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "追加", style: .default){ (action) in
            var getUserDefaults:[String] = self.userDefaults.array(forKey: "キー") as! [String]
            getUserDefaults.append(textField.text!)
            self.userDefaults.set(getUserDefaults,forKey: "キー")
            self.expenceItemTableView.reloadData()
            print(self.userDefaults.array(forKey:"キー") as! [String])
            print(getUserDefaults)
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "項目を入力"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ExpenceItemViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenceItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenceItemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = userDefaults.array(forKey: "キー")?[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
