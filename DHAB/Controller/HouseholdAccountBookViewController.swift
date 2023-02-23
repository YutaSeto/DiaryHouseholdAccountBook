//
//  HouseholdAccountBookViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift
import UIKit
import Charts

protocol HouseholdAccountBookControllerDelegate{
    func updateList()
}

class HouseholdAccountBookViewController:UIViewController{
    
    private var date = Date()
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var householdAccountBookSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        incomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        dayLabel.text = monthDateFormatter.string(from:date)
        addSubView()
        addPaymentView()
        settingSubView()
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        configureInputButton()
        setPaymentData()
        setIncomeData()
        setPaymentBudgetData()
        setIncomeBudgetData()
        setIncomeCategoryData()
        setCategoryData()
        setPaymentTableViewDataSourse()
        setIncomeTableViewDataSourse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func householdAccountBookSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addPaymentView()
        case 1:
            addIncomeView()
        case 2:
            addSavingView()
        default:
            return
        }
    }
    
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
    }
    
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
    }
    
    func dayBack(){
        householdeAccountBookViewControllerDelegate = self
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        dayLabel.text = monthDateFormatter.string(from: date)
        self.householdeAccountBookViewControllerDelegate?.updateList()
        paymentTableView.reloadData()
    }
    
    func dayPass(){
        householdeAccountBookViewControllerDelegate = self
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        dayLabel.text = monthDateFormatter.string(from: date)
        self.householdeAccountBookViewControllerDelegate?.updateList()
        paymentTableView.reloadData()
    }
    
    
    private var monthDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    private var dayDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    //subView関連
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var savingView: UIView!
    
    func addSubView(){
        view.addSubview(paymentView)
        view.addSubview(incomeView)
        view.addSubview(savingView)
    }
    
    func addPaymentView(){
        savingView.isHidden = true
        incomeView.isHidden = true
        paymentView.isHidden = false
        
    }
    func addIncomeView(){
        savingView.isHidden = true
        paymentView.isHidden = true
        incomeView.isHidden = false
    }
    
    func addSavingView(){
        incomeView.isHidden = true
        paymentView.isHidden = true
        savingView.isHidden = false
    }
    
    func settingSubView(){
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.topAnchor.constraint(equalTo: householdAccountBookSegmentedControl.bottomAnchor,constant: 10).isActive = true
        paymentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        paymentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        paymentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        incomeView.translatesAutoresizingMaskIntoConstraints = false
        incomeView.topAnchor.constraint(equalTo: householdAccountBookSegmentedControl.bottomAnchor,constant: 10).isActive = true
        incomeView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        incomeView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        incomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        savingView.translatesAutoresizingMaskIntoConstraints = false
        savingView.topAnchor.constraint(equalTo: householdAccountBookSegmentedControl.bottomAnchor,constant: 10).isActive = true
        savingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        savingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        savingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //支出画面の設定
    private var paymentList:[PaymentModel] = []
    private var paymentBudgetList:[PaymentBudgetModel] = []
    private var categoryList:[CategoryModel] = []
    private var paymentTableViewDataSource: [HouseholdAccountBookTableViewCellItem] = []
    let realm = try! Realm()
    var householdeAccountBookViewControllerDelegate:HouseholdAccountBookControllerDelegate?
    
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var inputButton: UIButton!
    @IBAction func inputButton(_ sender: Any) {
        tapInputButton()
    }
    
    func setCategoryData(){
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentBudgetData(){
        let result = realm.objects(PaymentBudgetModel.self)
        paymentBudgetList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentData(){
        let result = realm.objects(PaymentModel.self)
        paymentList = Array(result)
        paymentTableView.reloadData()
    }
    
    func configureInputButton(){
        inputButton.layer.cornerRadius = inputButton.bounds.width / 2
        addIncomeButton.layer.cornerRadius = addIncomeButton.bounds.width / 2
    }
    
    func  tapInputButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
        inputViewController.inputViewControllerDelegate = self
        present(inputViewController,animated:true)
    }
    
    func setPaymentTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
        
        let dayCheckPayment = paymentList.filter({$0.date >= firstDay})
        let dayCheckPayment2 = dayCheckPayment.filter{$0.date <= lastDay}
        categoryList.forEach{ expense in
            if let budget:PaymentBudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).first{
                let sum = dayCheckPayment2.filter{$0.category == expense.name}.map{$0.price}.reduce(0){$0 + $1}
                
                let item = HouseholdAccountBookTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    paymentPrice:sum,
                    budgetPrice: budget.budgetPrice
                )
                paymentTableViewDataSource.append(item)
            } else {
                let data = PaymentBudgetModel()
                data.id = UUID().uuidString
                data.expenseID = expense.id
                data.budgetDate = date
                data.budgetPrice = 0
                try! realm.write { realm.add(data)}
                paymentBudgetList.append(data)
                
                let item = HouseholdAccountBookTableViewCellItem(
                    id:data.id,
                    name: expense.name,
                    budgetPrice: data.budgetPrice
                )
                paymentTableViewDataSource.append(item)
            }
            
            paymentTableView.reloadData()
        }
    }
    //収入画面の設定
    
    var incomeList:[IncomeModel] = []
    var incomeBudgetList:[IncomeBudgetModel] = []
    var incomeCategoryList:[IncomeCategoryModel] = []
    var incomeTableViewDataSource: [IncomeTableViewCellItem] = []
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBAction func addIncomeButton(_ sender: UIButton) {
        tapAddIncomeButton()
    }
    
    func tapAddIncomeButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
        inputViewController.inputViewControllerDelegate = self
        present(inputViewController,animated:true)
    }
    
    func setIncomeData(){
        let result = realm.objects(IncomeModel.self)
        incomeList = Array(result)
        incomeTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(IncomeCategoryModel.self)
        incomeCategoryList = Array(result)
    }
    
    func setIncomeBudgetData(){
        let result = realm.objects(IncomeBudgetModel.self)
        incomeBudgetList = Array(result)
    }
    
    func setIncomeTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        let dayCheckBudget = incomeBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
        
        let dayCheckPayment = incomeList.filter({$0.date >= firstDay})
        let dayCheckPayment2 = dayCheckPayment.filter{$0.date <= lastDay}
        incomeCategoryList.forEach{ expense in
            if let budget:IncomeBudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).first{
                let sum = dayCheckPayment2.filter{$0.category == expense.name}.map{$0.amount}.reduce(0){$0 + $1}
                
                let item = IncomeTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    incomePrice:sum,
                    incomeBudget: budget.budgetPrice
                )
                incomeTableViewDataSource.append(item)
            } else {
                let data = IncomeBudgetModel()
                data.id = UUID().uuidString
                data.expenseID = expense.id
                data.budgetDate = date
                data.budgetPrice = 0
                try! realm.write { realm.add(data)}
                incomeBudgetList.append(data)
                
                let item = IncomeTableViewCellItem(
                    id:data.id,
                    name: expense.name,
                    incomeBudget:data.budgetPrice
                )
                incomeTableViewDataSource.append(item)
            }
        }
        incomeTableView.reloadData()
    }
}

extension HouseholdAccountBookViewController:InputViewControllerDelegate{
    func updateCalendar() {
        return
    }
    
    func updatePayment() {
        setPaymentData()
        setCategoryData()
        setPaymentBudgetData()
        paymentTableViewDataSource = []
        setPaymentTableViewDataSourse()
    }
    
    func updateDiary() {
        return
    }
}

extension HouseholdAccountBookViewController:UITableViewDelegate,UITableViewDataSource{
    
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
            let cell = paymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            let item = paymentTableViewDataSource[indexPath.row]
            cell.data = item
            cell.expenceItemLabel.text = item.name
            cell.budgetLabel.text = String(item.budgetPrice)
            cell.priceLabel.text = String(item.paymentPrice)
            cell.balanceLabel.text = String(item.budgetPrice - item.paymentPrice)
            guard item.budgetPrice != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(item.budgetPrice - item.paymentPrice) / Float(item.budgetPrice)), animated: false)
            return cell
        }else if tableView.tag == 1{
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            let item = incomeTableViewDataSource[indexPath.row]
            cell.incomeData = item
            cell.expenceItemLabel.text = item.name
            cell.budgetLabel.text = String(item.incomeBudget)
            cell.priceLabel.text = String(item.incomePrice)
            cell.balanceLabel.text = String(item.incomeBudget - item.incomePrice)
            guard item.incomeBudget != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(item.incomeBudget - item.incomePrice) / Float(item.incomeBudget)), animated: false)
            return cell
        }
        return UITableViewCell()
    }
}

extension HouseholdAccountBookViewController:HouseholdAccountBookControllerDelegate{
    func updateList() {
        setPaymentData()
        setCategoryData()
        setPaymentBudgetData()
        paymentTableViewDataSource = []
        setPaymentTableViewDataSourse()
    }
}

extension HouseholdAccountBookViewController:ExpenseItemViewControllerDelegate{
    func updateCategory() {
        return
    }
    
    func updateBudget() {
        setPaymentData()
        setCategoryData()
        setPaymentBudgetData()
        paymentTableViewDataSource = []
        setPaymentTableViewDataSourse()
    }
    
    
}
