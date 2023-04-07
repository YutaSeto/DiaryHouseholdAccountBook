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

protocol DeleteCategoryDelegate{
    func remakeViewController()
    func deleteTargetItem(data:Category,index:IndexPath,journal:[Journal],budget:[Budget])
    func remakeUIView()
}

class ExpenseItemViewController: UIViewController{
    
    let expenseItemViewModel = ExpenseItemViewModel()
    var expenseItemViewControllerDelegate:ExpenseItemViewControllerDelegate?
    var categoryViewControllerDelegate:CategoryViewControllerDelegate?
    var deleteCategoryDelegateForTabBar:DeleteCategoryDelegate?
    var deleteCategoryDelegateForHouseholdAccountBook:DeleteCategoryDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var expenseItemTableView: UITableView!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseItemViewModel.setCategoryData()
        expenseItemViewModel.setIncomeCategoryData()
        expenseItemTableView.delegate = self
        expenseItemTableView.dataSource = self
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        addSubView()
        addPaymentView()
        settingSubView()
        configureAddButton()
        categoryViewControllerDelegate?.updateHouseholdAccountBook()
        setNavigationBarButton()
        setStatusBarBackgroundColor(.flatPowderBlueColorDark())
        expenseItemTableView.reloadData()
        incomeTableView.reloadData()
        
        if expenseItemViewModel.isIncome == true{
            addIncomeView()
            segmentedControl.selectedSegmentIndex = 1
        }
    }
    
    @objc func tapBackButton(){
        dismiss(animated: true)
    }
    
    func setNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName:"xmark"), style: .plain,target: self,action: buttonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)
        
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
        
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) -> Void in
            guard let text = textFieldOnAlert.text else {return}
            if self.expenseItemViewModel.isValidNameLimit(name: text){
                self.showAlert(title: "カテゴリー名は8文字以内にしてください")
                return
            }
            if self.expenseItemViewModel.isValidTooManyPaymentCategories(){
                self.showAlert(title: "カテゴリー数は12個までにしてください")
                return
            }
            
            self.expenseItemViewModel.addNewCategory(value: text, isPayment: true)
            
            self.expenseItemViewControllerDelegate?.updateCategory()
            self.categoryViewControllerDelegate?.updateHouseholdAccountBook()
            self.expenseItemTableView.reloadData()
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
        
        let add = UIAlertAction(title:"追加する", style: .default,handler: {(action) -> Void in
            guard let text = textFieldOnAlert.text else {return}
            if self.expenseItemViewModel.isValidNameLimit(name: text){
                self.showAlert(title: "カテゴリー名は8文字以内にしてください")
                return
            }
            if self.expenseItemViewModel.isValidTooManyPaymentCategories(){
                self.showAlert(title: "カテゴリー数は12個までにしてください")
                return
            }
            
            self.expenseItemViewModel.addNewCategory(value: text, isPayment: false)
            self.expenseItemViewControllerDelegate?.updateCategory()
            self.categoryViewControllerDelegate?.updateIncome()
            self.incomeTableView.reloadData()
        })
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        
        alert.addAction(cancel)
        alert.addAction(add)
        
        self.present(alert,animated:true, completion: nil)
    }
    
    func showAlert(title:String){
        let alert = UIAlertController(title:title, message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension ExpenseItemViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === expenseItemTableView{
            return expenseItemViewModel.categoryList.count
        }else if tableView === incomeTableView{
            return expenseItemViewModel.incomeCategoryList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === expenseItemTableView{
            let cell = expenseItemTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = expenseItemViewModel.categoryList[indexPath.row].name
            return cell
        }else if tableView === incomeTableView{
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = expenseItemViewModel.incomeCategoryList[indexPath.row].name
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === expenseItemTableView{
            expenseItemViewControllerDelegate = self
            RecognitionChange.shared.updateHouseholdAccountBook = true
            let alert = UIAlertController(title: "\(expenseItemViewModel.categoryList[indexPath.row].name)のカテゴリー名を変更します", message: nil, preferredStyle: .alert)
            var textFieldOnAlert = UITextField()
            alert.addTextField{ textField in
                textFieldOnAlert = textField
                textField.placeholder = "新しいカテゴリーの名前を入力してください"
            }
            let add = UIAlertAction(title:"変更する", style: .default,handler: {(action) in
                guard let text = textFieldOnAlert.text else{return}
                if self.expenseItemViewModel.isValidNameLimit(name: text){
                    self.showAlert(title: "カテゴリー名は8文字以内にしてください")
                    return
                }
                self.expenseItemViewModel.overwriteCategory(value: text, indexPath: indexPath)
                self.categoryViewControllerDelegate?.updateHouseholdAccountBook()
                self.expenseItemViewControllerDelegate?.updateCategory()
                self.expenseItemViewControllerDelegate?.updatePayment()
                self.expenseItemTableView.reloadData()
                
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
            let alert = UIAlertController(title: "\(expenseItemViewModel.incomeCategoryList[indexPath.row].name)のカテゴリー名を変更します", message: nil, preferredStyle: .alert)
            var textFieldOnAlert = UITextField()
            alert.addTextField{ textField in
                textFieldOnAlert = textField
                textField.placeholder = "新しいカテゴリーの名前を入力してください"
            }
            
            let add = UIAlertAction(title:"変更する", style: .default,handler: {(action) in
                guard let text = textFieldOnAlert.text else {return}
                if self.expenseItemViewModel.isValidNameLimit(name: text){
                    self.showAlert(title: "カテゴリー名は8文字以内にしてください")
                    return
                }
                self.expenseItemViewModel.overwriteCategory(value: text, indexPath: indexPath)
                self.categoryViewControllerDelegate?.updateIncome()
                self.expenseItemViewControllerDelegate?.updateCategory()
                self.incomeTableView.reloadData()
                
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
                let realm = try! Realm()
                let targetItem = self.expenseItemViewModel.categoryList[indexPath.row]
                let targetJournal = Array(realm.objects(Journal.self).filter{$0.category == targetItem.name}.filter{$0.isPayment == true}) //消すべきジャーナル一覧
                let targetBudget = Array(realm.objects(Budget.self).filter{$0.expenseID == targetItem.id}.filter{$0.isPayment == true}) //消すべき予算一覧
                
                //このビューでのデータ配列の削除、テーブルビューセルの削除
                print("ここから開始")
                self.expenseItemViewModel.categoryList.remove(at: indexPath.row)
                self.expenseItemTableView.deleteRows(at: [indexPath], with: .automatic)
                
                print("expenseitemviewの削除が完了")
                //ここで家計簿画面の配列とテーブルビューから消す必要がある。
                self.deleteCategoryDelegateForHouseholdAccountBook!.deleteTargetItem(data: targetItem, index: indexPath,journal:targetJournal,budget: targetBudget)//データを持ってく&削除
                print("家計簿画面の削除が完了")
                
                self.expenseItemViewModel.deleteCategory(targetItem: targetItem, targetJournal: targetJournal, targetBudget: targetBudget)//ここで消している
                print("realmのデータ削除完了")
                
                self.deleteCategoryDelegateForHouseholdAccountBook?.remakeViewController()
                print("remakeviewControllerを実施")
                self.expenseItemViewModel.setCategoryData()
                print("setCategoryDataの実施")
                self.expenseItemTableView.reloadData()
                self.deleteCategoryDelegateForTabBar?.remakeViewController()
                self.deleteCategoryDelegateForHouseholdAccountBook?.remakeUIView()
            })
            
            let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
                return
            })
            
            alert.addAction(cancel)
            alert.addAction(warning)
            self.present(alert,animated:true, completion: nil)
            
            
        }else if tableView === incomeTableView{
            let realm = try! Realm()
            let targetItem = expenseItemViewModel.incomeCategoryList[indexPath.row]
            let targetJournal = Array(realm.objects(Journal.self).filter{$0.category == targetItem.name}.filter{$0.isPayment == false}) //消すべきジャーナル一覧
            let targetBudget = Array(realm.objects(Budget.self).filter{$0.expenseID == targetItem.id}.filter{$0.isPayment == false}) //消すべき予算一覧
            expenseItemViewModel.incomeCategoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.deleteCategoryDelegateForHouseholdAccountBook!.deleteTargetItem(data: targetItem, index: indexPath,journal:targetJournal,budget: targetBudget)
            
            self.expenseItemViewModel.deleteCategory(targetItem: targetItem, targetJournal: targetJournal, targetBudget: targetBudget)
            self.deleteCategoryDelegateForHouseholdAccountBook?.remakeViewController()
            self.expenseItemViewModel.setIncomeCategoryData()
            tableView.reloadData()
            categoryViewControllerDelegate?.updateIncome()
            self.deleteCategoryDelegateForTabBar?.remakeViewController()
            
        }
    }
}

extension ExpenseItemViewController:ExpenseItemViewControllerDelegate{
    func updateCategory() {
        expenseItemViewModel.setCategoryData()
        expenseItemViewModel.setIncomeCategoryData()
        expenseItemTableView.reloadData()
        incomeTableView.reloadData()
    }
    
    func updateBudget() {
        return
    }
    
    func updatePayment() {
        return
    }
}
