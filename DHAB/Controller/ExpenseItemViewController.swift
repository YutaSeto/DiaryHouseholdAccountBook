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
    func updateBudget()
    func updatePayment()
}

protocol CategoryViewControllerDelegate{
    func updateHouseholdAccountBook()
    func updateIncome()
    func deletePayment()
    func deleteIncome()
}

class ExpenseItemViewController: UIViewController{
    
    let realm = try! Realm()
    var categoryList:[CategoryModel] = []
    var incomeCategoryList:[CategoryModel] = []
    var expenseItemViewControllerDelegate:ExpenseItemViewControllerDelegate?
    var categoryViewControllerDelegate:CategoryViewControllerDelegate?
    
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
        expenseItemTableView.delegate = self
        expenseItemTableView.dataSource = self
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        addSubView()
        addPaymentView()
        settingSubView()
        configureAddButton()
        categoryViewControllerDelegate?.updateHouseholdAccountBook()
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
    
    func addSubView(){
        view.addSubview(paymentView)
        view.addSubview(incomeView)
    }
    
    func addPaymentView(){
        incomeView.isHidden = true
        paymentView.isHidden = false
    }
    func addIncomeView(){
        incomeView.isHidden = false
        paymentView.isHidden = true
    }
    
    func settingSubView(){
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,constant: 10).isActive = true
        paymentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        paymentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        paymentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        incomeView.translatesAutoresizingMaskIntoConstraints = false
        incomeView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,constant: 10).isActive = true
        incomeView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        incomeView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        incomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func tapAddPaymentButton(){
        expenseItemViewControllerDelegate = self
        RecognitionChange.shared.updateHouseholdAccountBook = true
        let alert = UIAlertController(title: "カテゴリーを追加します", message: nil, preferredStyle: .alert)
        var textFieldOnAlert = UITextField()
        alert.addTextField{ textField in
            textFieldOnAlert = textField
            textField.placeholder = "カテゴリーの名前を入力してください"
        }
        
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) in
            guard let text = textFieldOnAlert.text else {return}
            do{
                let categoryModel = try CategoryModel(name: text,isPayment: true)
                let realm = try Realm()
                try realm.write{
                    realm.add(categoryModel)
                }
                self.expenseItemViewControllerDelegate?.updateCategory()
                self.categoryViewControllerDelegate?.updateHouseholdAccountBook()
                self.expenseItemTableView.reloadData()
                
            }catch CategoryModel.ValidationError.invalidNameLength{
                print("文字数が8文字を超えています")
                return
            }catch{
                print("エラーが発生しました")
                return
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
        expenseItemViewControllerDelegate = self
        RecognitionChange.shared.updateHouseholdAccountBook = true
        let alert = UIAlertController(title: "カテゴリーを追加します", message: nil, preferredStyle: .alert)
        var textFieldOnAlert = UITextField()
        alert.addTextField{ textField in
            textFieldOnAlert = textField
            textField.placeholder = "カテゴリーの名前を入力してください"
        }
        
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) in
            guard let text = textFieldOnAlert.text else {return}
            do{
                let categoryModel = try CategoryModel(name: text, isPayment: false)
                let realm = try Realm()
                try realm.write{
                    realm.add(categoryModel)
                }
                self.expenseItemViewControllerDelegate?.updateCategory()
                self.categoryViewControllerDelegate?.updateIncome()
                self.incomeTableView.reloadData()
            } catch CategoryModel.ValidationError.invalidNameLength{
                print("8文字を超えています")
                return
            } catch{
                print("予期せぬエラーが発生")
                return
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
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == true}
        categoryList = Array(result)
        expenseItemTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
        incomeTableView.reloadData()
    }
}

extension ExpenseItemViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === expenseItemTableView{
            return categoryList.count
        }else if tableView === incomeTableView{
            return incomeCategoryList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === expenseItemTableView{
            let cell = expenseItemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = categoryList[indexPath.row].name
            return cell
        }else if tableView === incomeTableView{
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = incomeCategoryList[indexPath.row].name
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === expenseItemTableView{
            expenseItemViewControllerDelegate = self
            RecognitionChange.shared.updateHouseholdAccountBook = true
            let alert = UIAlertController(title: "\(categoryList[indexPath.row].name)のカテゴリー名を変更します", message: nil, preferredStyle: .alert)
            var textFieldOnAlert = UITextField()
            alert.addTextField{ textField in
                textFieldOnAlert = textField
                textField.placeholder = "新しいカテゴリーの名前を入力してください"
            }
            let add = UIAlertAction(title:"変更する", style: .default,handler: {(action) in
                do{
                    guard let text = textFieldOnAlert.text else{return}
                    let categoryModel = try CategoryModel(name: text, isPayment: true)
                    let realm = try!Realm()
                    try! realm.write{
                        self.categoryList[indexPath.row] = categoryModel
                    }
                    self.categoryViewControllerDelegate?.updateHouseholdAccountBook()
                    self.expenseItemViewControllerDelegate?.updateCategory()
                    self.expenseItemViewControllerDelegate?.updatePayment()
                    self.expenseItemTableView.reloadData()
                    print(self.categoryList[indexPath.row])
                }catch CategoryModel.ValidationError.invalidNameLength{
                    print("8文字を超えています")
                }catch{
                    print("予期せぬエラーが発生しています")
                }
            })
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            alert.addAction(cancel)
            alert.addAction(add)
            self.present(alert,animated:true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }else if tableView === incomeTableView{
            RecognitionChange.shared.updateHouseholdAccountBook = true
            let alert = UIAlertController(title: "\(incomeCategoryList[indexPath.row].name)のカテゴリー名を変更します", message: nil, preferredStyle: .alert)
            var textFieldOnAlert = UITextField()
            alert.addTextField{ textField in
                textFieldOnAlert = textField
                textField.placeholder = "新しいカテゴリーの名前を入力してください"
            }
            
            let add = UIAlertAction(title:"変更する", style: .default,handler: {(action) in
                guard let text = textFieldOnAlert.text else {return}
                do{
                    let categoryModel = try CategoryModel(name: text, isPayment: false)
                        let realm = try Realm()
                        try realm.write{
                            self.incomeCategoryList[indexPath.row] = categoryModel
                        }
                        self.categoryViewControllerDelegate?.updateIncome()
                        self.expenseItemViewControllerDelegate?.updateCategory()
                        self.incomeTableView.reloadData()
                }catch CategoryModel.ValidationError.invalidNameLength{
                    print("8文字を超えています")
                }catch{
                    print("予期せぬエラーが発生")
                }
            })
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            alert.addAction(cancel)
            alert.addAction(add)
            self.present(alert,animated:true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView === expenseItemTableView{
            let alert = UIAlertController(title: "関連する支出・収入・予算の履歴が\n全て削除されます。\nよろしいでしょうか", message: nil, preferredStyle: .alert)
            
            let warning = UIAlertAction(title:"理解した上で削除する",style: .default, handler:{(action) -> Void in
                let targetItem = self.categoryList[indexPath.row]
                let realm = try! Realm()
                let targetJornal = realm.objects(JournalModel.self).filter{$0.category == targetItem.name}.filter{$0.isPayment == true}
                let targetBudget = realm.objects(BudgetModel.self).filter{$0.expenseID == targetItem.id}.filter{$0.isPayment == true}
                
                self.categoryList.remove(at: indexPath.row)
                self.expenseItemTableView.deleteRows(at: [indexPath], with: .automatic)
//                try! realm.write{
//                    realm.delete(targetItem)
//                    realm.delete(targetJornal)
//                    realm.delete(targetBudget)
//                }
                self.setCategoryData()
                self.expenseItemTableView.reloadData()
                self.categoryViewControllerDelegate?.deletePayment()
                //ここについて修正が必要　家計簿画面のテーブルの修正、インプット画面のコレクションビュー、予算画面のカテゴリーリスト、カレンダー画面のほぼ全ての配列の修正を伝える必要がある。何か良い方法はある？
            })
            
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            
            alert.addAction(cancel)
            alert.addAction(warning)
            self.present(alert,animated:true, completion: nil)
            
            
        }else if tableView === incomeTableView{
            let targetItem = incomeCategoryList[indexPath.row]
            incomeCategoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            tableView.reloadData()
            categoryViewControllerDelegate?.updateIncome()
        }
    }
}

extension ExpenseItemViewController:ExpenseItemViewControllerDelegate{
    func updateCategory() {
        setCategoryData()
        setIncomeCategoryData()
    }
    
    func updateBudget() {
        return
    }
    
    func updatePayment() {
        return
    }
}
