//
//  BudgetConfigureView.swift
//  DHAB
//
//  Created by setoon on 2023/01/19.
//

import Foundation
import RealmSwift
import UIKit

protocol BudgetConfigureViewControllerDelegate{
    func updateBudget()
}

protocol ForHouseholdAccountBookDeleagte{
    func updateHouseholdAccountBookView()
}

class BudgetConfigureViewController: UIViewController{
    
    let util = Util()
    let budgetConfigureViewModel = BudgetConfigureViewModel()
    var delegate:BudgetConfigureViewControllerDelegate?
    var forHouseholdAccountBookDelegate:ForHouseholdAccountBookDeleagte?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var budgetConfigureTableView: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        budgetConfigureTableView.register(UINib(nibName: "BudgetConfigureTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        budgetConfigureTableView.delegate = self
        budgetConfigureTableView.dataSource = self
        budgetConfigureViewModel.setCategoryData()
        budgetConfigureViewModel.setIncomeCategoryData()
        budgetConfigureViewModel.setPaymentBudgetData()
        budgetConfigureViewModel.setIncomeBudgetData()
        budgetConfigureViewModel.setBudgetTableViewDataSourse()
        budgetConfigureViewModel.setIncomeBudgetTableViewDataSourse()
        dateLabel.text = util.monthDateFormatter.string(from:budgetConfigureViewModel.date)
        configureNavigationBarButton()
        changeNavigationBarColor()
        configureButton()
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        tapSaveButton()
        navigationController?.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
    
    func tapSaveButton(){
        budgetConfigureViewModel.overwritePaymentBudget()
        budgetConfigureViewModel.overwriteIncomeBudget()
        delegate?.updateBudget()
        forHouseholdAccountBookDelegate?.updateHouseholdAccountBookView()
    }
    
    @objc func tapBackButton(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureNavigationBarButton(){
        let buttonActionSelector:Selector = #selector(tapBackButton)
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName:"chevron.left"), style: .plain
                                            ,target: self,action: buttonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)
    }
    
    func configureButton(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        cancelButton.backgroundColor = themeColor.color
        cancelButton.titleLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
        saveButton.backgroundColor = themeColor.color
        saveButton.titleLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
    }
    
    func changeNavigationBarColor(){
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        appearance.backgroundColor = themeColor.color
        
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true) ?? .black]
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        navigationController?.popToViewController(navigationController!.viewControllers[0], animated: true)
    }
}

extension BudgetConfigureViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "支出"
        }else{
            return "収入"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return budgetConfigureViewModel.categoryList.count
        }else{
            return budgetConfigureViewModel.incomeCategoryList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = budgetConfigureTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetConfigureTableViewCell
        if indexPath.section == 0{
            var item = budgetConfigureViewModel.budgetTableViewDataSource[indexPath.row]
            cell.data = item
            cell.categoryLabel.text = item.name
            cell.priceTextField.text = String(item.price)
            item.price = cell.price
            cell.delegate = self
            return cell
        }else{
            var item = budgetConfigureViewModel.incomeBudgetTableViewDataSource[indexPath.row]
            cell.incomeData = item
            cell.categoryLabel.text = item.name
            cell.priceTextField.text = String(item.price)
            item.price = cell.price
            cell.delegate = self
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension BudgetConfigureViewController: BudgetConfigureTableViewCellDelegate{
    func tableViewCell(didChangeTextIncome text: String, incomeData: IncomeBudgetTableViewCellItem?) {
        guard let data = incomeData else {return}
        if let index = budgetConfigureViewModel.incomeBudgetTableViewDataSource.firstIndex(where: {$0.id == data.id}){
            budgetConfigureViewModel.incomeBudgetTableViewDataSource[index].price = incomeData!.price
        }
    }
    
    func tableViewCell(didChngeText text: String, data: BudgetTableViewCellItem?) {
        guard let data = data else {return}
        if let index = budgetConfigureViewModel.budgetTableViewDataSource.firstIndex(where: {$0.id == data.id}){
            budgetConfigureViewModel.budgetTableViewDataSource[index].price = data.price
        }
    }
    
}
