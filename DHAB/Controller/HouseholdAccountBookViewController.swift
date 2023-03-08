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
    func updateIncome()
}

class HouseholdAccountBookViewController:UIViewController {
    
    private var date = Date()
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var householdAccountBookSegmentedControl: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //subView関連
    var isMonth = true
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var savingView: UIView!
    
    //支出画面の設定
    var sumPayment:HouseholdAccountBookTableViewCellItem = HouseholdAccountBookTableViewCellItem()
    private var paymentList:[PaymentModel] = []
    private var paymentBudgetList:[PaymentBudgetModel] = []
    private var categoryList:[CategoryModel] = []
    private var paymentTableViewDataSource: [HouseholdAccountBookTableViewCellItem] = []
    var householdeAccountBookViewControllerDelegate:HouseholdAccountBookControllerDelegate?
    
    @IBOutlet weak var sumPaymentTableView: UITableView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var inputButton: UIButton!
    
    @IBOutlet weak var sumPaymentTableViewHeight: NSLayoutConstraint!
    
    //収入画面関連
    var sumIncome:IncomeTableViewCellItem = IncomeTableViewCellItem()
    var incomeList:[IncomeModel] = []
    var incomeBudgetList:[IncomeBudgetModel] = []
    var incomeCategoryList:[IncomeCategoryModel] = []
    var incomeTableViewDataSource: [IncomeTableViewCellItem] = []
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableViewHeight: NSLayoutConstraint!
    
    //slideMenu画面関連
    let menuList = ["カテゴリーの設定","予算の設定"]
    var isExpanded:Bool = false
    @IBOutlet var slideMenuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    
    //推移画面関連
    @IBOutlet weak var resultTableView: UITableView!
    var sumPaymentList:[Int] = [0,0,0,0,0,0,0,0,0,0,0,0]
    var sumIncomeList:[Int] = [0,0,0,0,0,0,0,0,0,0,0,0]
    
    
    func setMonthSumPayment(){
        for i in 0 ..< 12{
            let calendar = Calendar(identifier: .gregorian)
            let comps = calendar.dateComponents([.year], from: date)
            let day = calendar.date(from: comps)!
            let addIMonth = DateComponents(month: i)
            let add2Month = DateComponents(month: i + 1)
            let firstDay = calendar.date(byAdding: addIMonth, to: day)?.zeroclock
            let lastDay = calendar.date(byAdding: add2Month, to: day)!.zeroclock
            let dayCheckSumPayment = paymentList.filter({$0.date >= firstDay!})
            let dayCheckSumPayment2 = dayCheckSumPayment.filter({$0.date < lastDay})
            sumPaymentList[i] = dayCheckSumPayment2.map{$0.price}.reduce(0){$0 + $1}
        }
        resultTableView.reloadData()
    }
    
    func setMonthSumIncome(){
        for i in 0 ..< 12{
            let calendar = Calendar(identifier: .gregorian)
            let comps = calendar.dateComponents([.year], from: date)
            let day = calendar.date(from: comps)!
            let addIMonth = DateComponents(month: i)
            let add2Month = DateComponents(month: i + 1)
            let firstDay = calendar.date(byAdding: addIMonth, to: day)?.zeroclock
            let lastDay = calendar.date(byAdding: add2Month, to: day)!.zeroclock
            let dayCheckSumPayment = incomeList.filter({$0.date >= firstDay!})
            let dayCheckSumPayment2 = dayCheckSumPayment.filter({$0.date < lastDay})
            sumIncomeList[i] = dayCheckSumPayment2.map{$0.amount}.reduce(0){$0 + $1}
        }
        resultTableView.reloadData()
    }
    
    override func viewDidLoad() {
        setNib()
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
        resultTableView.delegate = self
        resultTableView.dataSource = self
        configureInputButton()
        setPaymentData()
        setIncomeData()
        setPaymentBudgetData()
        setIncomeBudgetData()
        setIncomeCategoryData()
        setCategoryData()
        setPaymentTableViewDataSourse()
        setIncomeTableViewDataSourse()
        setMonthSumPayment()
        setMonthSumIncome()
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
    
    func setNib(){
            paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
            incomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
            sumPaymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
            sumIncomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
            resultTableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
    }
    
    
    @IBAction func householdAccountBookSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addPaymentView()
            isMonth = true
        case 1:
            addIncomeView()
            isMonth = true
        case 2:
            addSavingView()
            isMonth = false
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
        if isMonth{
            date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
            dayLabel.text = monthDateFormatter.string(from: date)
        }else{
            date = Calendar.current.date(byAdding: .year, value: -1, to: date)!
            dayLabel.text = yearDateFormatter.string(from: date)
        }
        setMonthSumPayment()
        setMonthSumIncome()
        self.householdeAccountBookViewControllerDelegate?.updateList()
        self.householdeAccountBookViewControllerDelegate?.updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
    }
    
    func dayPass(){
        householdeAccountBookViewControllerDelegate = self
        if isMonth{
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
            dayLabel.text = monthDateFormatter.string(from: date)
        }else{
            date = Calendar.current.date(byAdding: .year, value: 1, to: date)!
            dayLabel.text = yearDateFormatter.string(from: date)
        }
        setMonthSumPayment()
        setMonthSumIncome()
        self.householdeAccountBookViewControllerDelegate?.updateList()
        self.householdeAccountBookViewControllerDelegate?.updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
    }
    
    private var yearDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    private var monthDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    private var dayDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    //subView関連
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
        dayLabel.text = monthDateFormatter.string(from: date)
    }
    func addIncomeView(){
        savingView.isHidden = true
        paymentView.isHidden = true
        incomeView.isHidden = false
        dayLabel.text = monthDateFormatter.string(from: date)
    }
    
    func addSavingView(){
        incomeView.isHidden = true
        paymentView.isHidden = true
        savingView.isHidden = false
        dayLabel.text = yearDateFormatter.string(from: date)
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
        slideMenuView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //支出画面関連
    @IBAction func inputButton(_ sender: Any) {
        tapInputButton()
    }
    
    func setCategoryData(){
        let realm = try! Realm()
        let result = realm.objects(CategoryModel.self)
        categoryList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentBudgetData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentBudgetModel.self)
        paymentBudgetList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentData(){
        let realm = try! Realm()
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
        let firstDay = calendar.date(from: comps)!.zeroclock
        let add = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!.zeroclock
        let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate < lastDay})
        
        let dayCheckPayment = paymentList.filter({$0.date >= firstDay})
        let dayCheckPayment2 = dayCheckPayment.filter{$0.date < lastDay}
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
                let realm = try! Realm()
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
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!.zeroclock
        let dayCheck = paymentList.filter({$0.date >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.date < lastDay})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumPaymentBudget(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!.zeroclock
        let dayCheck = paymentBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.budgetDate < lastDay})
        let sum = dayCheck2.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    
    func setSumPaymentData(){
        sumPayment.name = "合計"
        sumPayment.paymentPrice = sumPayment(date)
        sumPayment.budgetPrice = sumPaymentBudget(date)
    }
    
    func getComma(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let number = "\(formatter.string(from: NSNumber(value: num)) ?? "")"
        return number
    }
    
    
    //収入画面関連
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
        let realm = try! Realm()
        let result = realm.objects(IncomeModel.self)
        incomeList = Array(result)
        incomeTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let realm = try! Realm()
        let result = realm.objects(IncomeCategoryModel.self)
        incomeCategoryList = Array(result)
    }
    
    func setIncomeBudgetData(){
        let realm = try! Realm()
        let result = realm.objects(IncomeBudgetModel.self)
        incomeBudgetList = Array(result)
    }
    
    func setSumIncomeData(){
        sumIncome.name = "合計"
        sumIncome.incomePrice = sumPayment(date)
        sumIncome.incomeBudget = sumPaymentBudget(date)
    }
    
    func setIncomeTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let add = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!.zeroclock
        let dayCheckBudget = incomeBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate < lastDay})
        
        let dayCheckPayment = incomeList.filter({$0.date >= firstDay})
        let dayCheckPayment2 = dayCheckPayment.filter{$0.date < lastDay}
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
                let realm = try! Realm()
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
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!.zeroclock
        let dayCheck = incomeList.filter({$0.date >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.date < lastDay})
        let sum = dayCheck2.map{$0.amount}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumIncomeBudget(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!.zeroclock
        let dayCheck = incomeBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.budgetDate < lastDay})
        let sum = dayCheck2.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    

    
    //slidemenu関連
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
        setMonthSumPayment()
        
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
        }else if tableView.tag == 5{
            return 12
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = paymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            let item = paymentTableViewDataSource[indexPath.row]
            cell.data = item
            cell.expenceItemLabel.text = item.name
            cell.budgetLabel.text = getComma(item.budgetPrice)
            cell.priceLabel.text = getComma(item.paymentPrice)
            cell.balanceLabel.text = getComma(item.budgetPrice - item.paymentPrice)
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
            cell.budgetLabel.text = getComma(item.incomeBudget)
            cell.priceLabel.text = getComma(item.incomePrice)
            cell.balanceLabel.text = getComma(item.incomeBudget - item.incomePrice)
            guard item.incomeBudget != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(item.incomeBudget - item.incomePrice) / Float(item.incomeBudget)), animated: false)
            return cell
        }else if tableView.tag == 2{
            let cell = sumPaymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            cell.expenceItemLabel.text = "合計"
            cell.budgetLabel.text = getComma(sumPaymentBudget(_:date))
            cell.priceLabel.text = getComma(sumPayment(_:date))
            cell.balanceLabel.text = getComma(sumPaymentBudget(date) - sumPayment(date))
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
        }else if tableView.tag == 5{
            let cell = resultTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ResultTableViewCell
            cell.dateLabel.text = "\(String(indexPath.row + 1))月"
            cell.paymentLabel.text = String(sumPaymentList[indexPath.row])
            cell.incomeLabel.text = String(sumIncomeList[indexPath.row])
            cell.resultLabel.text = String(sumIncomeList[indexPath.row] - sumPaymentList[indexPath.row])
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
                // メニュー > 予算
                let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
                let budgetViewController = storyboard.instantiateViewController(withIdentifier: "BudgetViewController") as! BudgetViewController
                budgetViewController.budgetViewControllerDelegate = self
                
                let nav = UINavigationController(rootViewController: budgetViewController)
                present(nav,animated: true)
                
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
        sumIncomeTableView.reloadData()
    }
    
    func updateIncome() {
        setIncomeData()
        setIncomeBudgetData()
        setIncomeCategoryData()
        incomeTableViewDataSource = []
        setIncomeTableViewDataSourse()
        setSumIncomeData()
        setMonthSumIncome()
    }
}

extension HouseholdAccountBookViewController: BudgetViewControllerDelegate {
    func budgetViewControllerDidChangeBudget() {
        print("hkr updateList")
    }
}
