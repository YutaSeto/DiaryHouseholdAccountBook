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
    @IBOutlet weak var menuButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        incomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        sumPaymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        sumIncomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        dayLabel.text = monthDateFormatter.string(from:date)
        addSubView()
        addPaymentView()
        settingSubView()
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        sumPaymentTableView.delegate = self
        sumPaymentTableView.dataSource = self
        sumIncomeTableView.delegate = self
        sumIncomeTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.dataSource = self
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
        if RecognitionChange.shared.updateHouseholdAccountBook == true{
            setPaymentData()
            setCategoryData()
            setPaymentBudgetData()
            paymentTableViewDataSource = []
            setPaymentTableViewDataSourse()
            paymentTableView.reloadData()
            incomeTableView.reloadData()
            RecognitionChange.shared.updateHouseholdAccountBook = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sumPaymentTableViewHeight.constant = CGFloat(sumPaymentTableView.contentSize.height)
        sumIncomeTableViewHeight.constant = CGFloat(sumIncomeTableView.contentSize.height)
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
        view.addSubview(slideMenuView)
    }
    
    func addPaymentView(){
        savingView.isHidden = true
        incomeView.isHidden = true
        paymentView.isHidden = false
        if isExpanded == true{
            returnView()
        }
        
    }
    func addIncomeView(){
        savingView.isHidden = true
        paymentView.isHidden = true
        incomeView.isHidden = false
        if isExpanded == true{
            returnView()
        }
    }
    
    func addSavingView(){
        incomeView.isHidden = true
        paymentView.isHidden = true
        savingView.isHidden = false
        if isExpanded == true{
            returnView()
        }
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
//
        slideMenuView.translatesAutoresizingMaskIntoConstraints = false
        slideMenuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        slideMenuView.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        slideMenuView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        slideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //支出画面の設定
    var sumPayment:HouseholdAccountBookTableViewCellItem = HouseholdAccountBookTableViewCellItem()
    private var paymentList:[PaymentModel] = []
    private var paymentBudgetList:[PaymentBudgetModel] = []
    private var categoryList:[CategoryModel] = []
    private var paymentTableViewDataSource: [HouseholdAccountBookTableViewCellItem] = []
    let realm = try! Realm()
    var householdeAccountBookViewControllerDelegate:HouseholdAccountBookControllerDelegate?
    
    @IBOutlet weak var sumPaymentTableView: UITableView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var inputButton: UIButton!
    
    @IBOutlet weak var sumPaymentTableViewHeight: NSLayoutConstraint!
    
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
    
    func sumPayment(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let day = calendar.date(from: comps)!
        let addDay = DateComponents(day: 1)
        let firstDay = calendar.date(byAdding: addDay, to: day)
        let addMonth = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay!)!
        let dayCheck = paymentList.filter({$0.date >= firstDay!})
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumPaymentBudget(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let day = calendar.date(from: comps)!
        let addDay = DateComponents(day: 1)
        let firstDay = calendar.date(byAdding: addDay, to: day)
        let addMonth = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay!)!
        let dayCheck = paymentBudgetList.filter({$0.budgetDate >= firstDay!})
        let dayCheck2 = dayCheck.filter({$0.budgetDate <= lastDay})
        let sum = dayCheck2.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    
    func setSumPaymentData(){
        sumPayment.name = "合計"
        sumPayment.paymentPrice = sumPayment(date)
        sumPayment.budgetPrice = sumPaymentBudget(date)
        
    }
    //収入画面の設定
    
    var incomeList:[IncomeModel] = []
    var incomeBudgetList:[IncomeBudgetModel] = []
    var incomeCategoryList:[IncomeCategoryModel] = []
    var incomeTableViewDataSource: [IncomeTableViewCellItem] = []
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableView: UITableView!
    
    @IBOutlet weak var sumIncomeTableViewHeight: NSLayoutConstraint!
    
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
    
    func sumIncome(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let day = calendar.date(from: comps)!
        let addDay = DateComponents(day: 1)
        let firstDay = calendar.date(byAdding: addDay, to: day)
        let addMonth = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay!)!
        let dayCheck = incomeList.filter({$0.date >= firstDay!})
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay})
        let sum = dayCheck2.map{$0.amount}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumIncomeBudget(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let day = calendar.date(from: comps)!
        let addDay = DateComponents(day: 1)
        let firstDay = calendar.date(byAdding: addDay, to: day)
        let addMonth = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay!)!
        let dayCheck = incomeBudgetList.filter({$0.budgetDate >= firstDay!})
        let dayCheck2 = dayCheck.filter({$0.budgetDate <= lastDay})
        let sum = dayCheck2.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    
    //slideMenu画面関連
    let menuList = ["カテゴリーの設定","予算の設定"]
    var isExpanded:Bool = false
    @IBOutlet var slideMenuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        showMenu(shouldExpand: isExpanded)
    }
    
    func showMenu(shouldExpand:Bool){
        if shouldExpand{
            returnView()
            isExpanded = false
        }else{
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: {
                    self.slideMenuView.frame.origin.x = self.view.frame.width - self.slideMenuView.frame.width
            }, completion: nil)
            isExpanded = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches{
            if touch.view?.tag == 4{
                return
            }else{
                returnView()
                isExpanded = true
            }
        }
    }
    
    func returnView(){
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations:  {
                self.slideMenuView.frame.origin.x = self.view.frame.width + self.slideMenuView.frame.width
            },
            completion: nil
        )
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
        setSumPaymentData()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
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
        }else if tableView.tag == 2{
            return 1
        }else if tableView.tag == 3{
            return 1
        }else if tableView.tag == 4{
            return menuList.count
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
        }else if tableView.tag == 2{
            let cell = sumPaymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            cell.expenceItemLabel.text = "合計"
            cell.budgetLabel.text = String(sumPaymentBudget(_:date))
            cell.priceLabel.text = String(sumPayment(_:date))
            cell.balanceLabel.text = String(sumPaymentBudget(date) - sumPayment(date))
            guard sumPaymentBudget(date) != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(sumPaymentBudget(date) - sumPayment(date)) / Float(sumPaymentBudget(date))), animated: false)
            return cell
        }else if tableView.tag == 3{
            let cell = sumIncomeTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            cell.expenceItemLabel.text = "合計"
            cell.budgetLabel.text = String(sumIncomeBudget(_:date))
            cell.priceLabel.text = String(sumIncome(_:date))
            cell.balanceLabel.text = String(sumIncomeBudget(date) - sumIncome(date))
            guard sumIncomeBudget(date) != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(sumIncomeBudget(date) - sumIncome(date)) / Float(sumIncomeBudget(date))), animated: false)
            return cell
        }else if tableView.tag == 4{
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = menuList[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 4{
            switch indexPath.row{
            case 0:
                if householdAccountBookSegmentedControl.selectedSegmentIndex == 1{
                    let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
                    let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController") as! ExpenseItemViewController
                    expenseItemViewController.categoryViewControllerDelegate = self
                    present(expenseItemViewController,animated: true)
                    expenseItemViewController.segmentedControl!.selectedSegmentIndex = 1
                    expenseItemViewController.addIncomeView()
                    returnView()
                }else{
                    let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
                    let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController") as! ExpenseItemViewController
                    expenseItemViewController.categoryViewControllerDelegate = self
                    present(expenseItemViewController,animated: true)
                    returnView()
                }
            case 1:
                let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                present(navigationController,animated: true)
                returnView()
            default:
                return
            }
        }else{
            if isExpanded == true{
                returnView()
            }
        }
        return
    }
}

extension HouseholdAccountBookViewController:HouseholdAccountBookControllerDelegate{
    func updateList() {
        setPaymentData()
        setCategoryData()
        setPaymentBudgetData()
        paymentTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setSumPaymentData()
        sumPaymentTableView.reloadData()
    }
}

extension HouseholdAccountBookViewController:CategoryViewControllerDelegate{
    func updateHouseholdAccountBook() {
        setPaymentData()
        setCategoryData()
        setPaymentBudgetData()
        paymentTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setSumPaymentData()
        sumPaymentTableView.reloadData()
    }
    
    func updateIncome() {
        setIncomeData()
        setIncomeBudgetData()
        setIncomeCategoryData()
        incomeTableViewDataSource = []
        setIncomeTableViewDataSourse()
    }
}
