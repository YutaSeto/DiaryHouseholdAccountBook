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

class HouseholdAccountBookViewController:UIViewController{
        
    private var date = Date()
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var householdAccountBookSegmentedControl: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let util = Util()
    
    //subView関連
    var isMonth = true
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var savingView: UIView!
    
    //支出画面の設定
    var sumPayment:HouseholdAccountBookTableViewCellItem = HouseholdAccountBookTableViewCellItem()
    private var paymentList:[JournalModel] = []
    private var paymentBudgetList:[BudgetModel] = []
    private var categoryList:[CategoryModel] = []
    private var paymentTableViewDataSource: [HouseholdAccountBookTableViewCellItem] = []
    
    @IBOutlet weak var sumPaymentTableView: UITableView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var paymentPieGraphView: PieChartView!
    @IBOutlet weak var sumPaymentTableViewHeight: NSLayoutConstraint!
    
    //収入画面関連
    var sumIncome:IncomeTableViewCellItem = IncomeTableViewCellItem()
    var incomeList:[JournalModel] = []
    var incomeBudgetList:[BudgetModel] = []
    var incomeCategoryList:[CategoryModel] = []
    var incomeTableViewDataSource: [IncomeTableViewCellItem] = []
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var incomePieGraphView: PieChartView!
    var targetItem:CategoryModel?
    var targetIndex:IndexPath?
    var targetJournal:[JournalModel]?
    var targetBudget:[BudgetModel]?
    
    //slideMenu画面関連
    let menuList = ["カテゴリーの設定","予算の設定"]
    var isExpanded:Bool = false
    @IBOutlet var slideMenuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    var deleteCategoryDelegateForTabBar:DeleteCategoryDelegate?
    
    //推移画面関連
    var sumPaymentList: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
    var sumYearPayment: Int = 0
    var sumIncomeList: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
    var sumYearIncome: Int = 0
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var resultSumTableView: UITableView!
    
    @IBOutlet weak var resultSumTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        setNib()
        dayLabel.text = util.monthDateFormatter.string(from:date)
        addSubView()
        addPaymentView()
        settingSubView()
        setDelegateAndDataSource()
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
        tableViewScroll()
        
        setChartView()
        chartView.data = setData()
        setIncomePieGraphView()
        incomePieGraphView.data = setIncomePieGraphData()
        setNavigationBarButton()
        
        if sumPayment(date) == 0{
            return
        }else{
            setPaymentPieGraphView()
            paymentPieGraphView.data = setPaymentPieGraphData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if RecognitionChange.shared.updateHouseholdAccountBook == true{
            setPaymentData()
            setIncomeData()
            setCategoryData()
            setIncomeCategoryData()
            setPaymentBudgetData()
            setIncomeBudgetData()
            paymentTableViewDataSource = []
            setPaymentTableViewDataSourse()
            incomeTableViewDataSource = []
            setIncomeTableViewDataSourse()
            paymentTableView.reloadData()
            sumPaymentTableView.reloadData()
            incomeTableView.reloadData()
            sumIncomeTableView.reloadData()
            RecognitionChange.shared.updateHouseholdAccountBook = false
        }
        
        if RecognitionChange.shared.deletePayment == true{
            setPaymentData()
            setIncomeData()
            setSumPaymentData()
            setSumIncomeData()
            paymentTableViewDataSource = []
            incomeTableViewDataSource = []
            setPaymentTableViewDataSourse()
            setIncomeTableViewDataSourse()
            setMonthSumPayment()
            setMonthSumIncome()
            paymentTableView.reloadData()
            sumPaymentTableView.reloadData()
            incomeTableView.reloadData()
            sumIncomeTableView.reloadData()
            RecognitionChange.shared.deletePayment = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sumPaymentTableViewHeight.constant = CGFloat(sumPaymentTableView.contentSize.height)
        sumIncomeTableViewHeight.constant = CGFloat(sumIncomeTableView.contentSize.height)
        resultSumTableViewHeight.constant = CGFloat(resultSumTableView.contentSize.height)
    }
    
    func tableViewScroll(){
        sumPaymentTableView.isScrollEnabled = false
        sumIncomeTableView.isScrollEnabled = false
        resultSumTableView.isScrollEnabled = false
    }
    
    func setNib(){
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        incomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        sumPaymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        sumIncomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        resultTableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        resultSumTableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
    }
    
    func setDelegateAndDataSource(){
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
        resultSumTableView.delegate = self
        resultSumTableView.dataSource = self
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
        
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
        
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    func dayBack(){
        if isMonth{
            date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
            dayLabel.text = util.monthDateFormatter.string(from: date)
        }else{
            date = Calendar.current.date(byAdding: .year, value: -1, to: date)!
            dayLabel.text = util.yearDateFormatter.string(from: date)
        }
        resetSumYearPaymentAndIncome()
        setMonthSumPayment()
        setMonthSumIncome()
        updateList()
        updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    func dayPass(){
        if isMonth{
            date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
            dayLabel.text = util.monthDateFormatter.string(from: date)
        }else{
            date = Calendar.current.date(byAdding: .year, value: 1, to: date)!
            dayLabel.text = util.yearDateFormatter.string(from: date)
        }
        resetSumYearPaymentAndIncome()
        setMonthSumPayment()
        setMonthSumIncome()
        updateList()
        updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    //subView関連
    func addSubView(){
        view.addSubview(incomeView)
        view.addSubview(paymentView)
        view.addSubview(savingView)
        view.addSubview(slideMenuView)
    }
    
    func addPaymentView(){
        savingView.isHidden = true
        incomeView.isHidden = true
        paymentView.isHidden = false
        dayLabel.text = util.monthDateFormatter.string(from: date)
    }
    func addIncomeView(){
        savingView.isHidden = true
        paymentView.isHidden = true
        incomeView.isHidden = false
        dayLabel.text = util.monthDateFormatter.string(from: date)
    }
    
    func addSavingView(){
        incomeView.isHidden = true
        paymentView.isHidden = true
        savingView.isHidden = false
        dayLabel.text = util.yearDateFormatter.string(from: date)
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
        
        slideMenuView.translatesAutoresizingMaskIntoConstraints = false
        slideMenuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        slideMenuView.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        slideMenuView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //支出画面関連
    
    func setCategoryData(){
        let realm = try! Realm()
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == true}
        categoryList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentBudgetData(){
        let realm = try! Realm()
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == true}
        paymentBudgetList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(JournalModel.self).filter{$0.isPayment == true}
        paymentList = Array(result)
        paymentTableView.reloadData()
    }
    
    func setPaymentPieGraphView(){
        paymentPieGraphView.highlightPerTapEnabled = false
        paymentPieGraphView.legend.enabled = false
        paymentPieGraphView.drawHoleEnabled = false
        paymentPieGraphView.rotationEnabled = false
        paymentPieGraphView.noDataTextColor = .black
    }
    
    private func setPaymentPieGraphData() -> PieChartData {
        // データの配列を作成する
        var dataEntries:[PieChartDataEntry] = []
        
        //こうすると項目の数が有限になってしまう
        let colors:[UIColor] = [.red, .blue, .green, .yellow, .gray, .brown, .cyan, .purple, .orange]
        for i in 0 ..< paymentTableViewDataSource.count{
            dataEntries.append(PieChartDataEntry(value: Double(paymentTableViewDataSource[i].paymentPrice), label: paymentTableViewDataSource[i].name))
        }
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "支出")
        dataSet.colors = colors
        dataSet.sliceSpace = 0.0
        let data = PieChartData(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        return data
    }
    
    private func updatePaymentPieGraph(){
        if sumPayment(date) == 0{
            paymentPieGraphView.data = nil
            paymentPieGraphView.notifyDataSetChanged()
            return
        }else{
            setPaymentPieGraphView()
            paymentPieGraphView.data = setPaymentPieGraphData()
        }
    }
    
    func setPaymentTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let add = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!.zeroclock
        let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay}).filter{$0.budgetDate < lastDay}
        
        let dayCheckPayment = paymentList.filter({$0.date >= firstDay}).filter{$0.date < lastDay}
        categoryList.forEach{ expense in
            if let budget:BudgetModel = dayCheckBudget.filter({$0.expenseID == expense.id}).first{
                let sum = dayCheckPayment.filter{$0.category == expense.name}.map{$0.price}.reduce(0){$0 + $1}
                
                let item = HouseholdAccountBookTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    paymentPrice:sum,
                    budgetPrice: budget.budgetPrice
                )
                paymentTableViewDataSource.append(item)
            } else {
                let sumPayment = dayCheckPayment.filter{$0.category == expense.name}.map{$0.price}.reduce(0, {$0 + $1})
                let data = BudgetModel()
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
                    paymentPrice: sumPayment,
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

    
    func setIncomeData(){
        let realm = try! Realm()
        let result = realm.objects(JournalModel.self).filter{$0.isPayment == false}
        incomeList = Array(result)
        incomeTableView.reloadData()
    }
    
    func setIncomeCategoryData(){
        let realm = try! Realm()
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
    }
    
    func setIncomeBudgetData(){
        let realm = try! Realm()
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == false}
        incomeBudgetList = Array(result)
    }
    
    func setSumIncomeData(){
        sumIncome.name = "合計"
        sumIncome.incomePrice = sumIncome(date)
        sumIncome.incomeBudget = sumIncomeBudget(date)
    }
    
    func setIncomeTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let add = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!.zeroclock
        let dayCheckBudget = incomeBudgetList.filter({$0.budgetDate >= firstDay}).filter{$0.budgetDate < lastDay}
        
        let dayCheckIncome = incomeList.filter({$0.date >= firstDay}).filter{$0.date < lastDay}
        incomeCategoryList.forEach{ expense in
            if let budget:BudgetModel = dayCheckBudget.filter({$0.expenseID == expense.id}).first{ //予算に入力がある時
                let sum = dayCheckIncome.filter{$0.category == expense.name}.map{$0.price}.reduce(0){$0 + $1}

                let item = IncomeTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    incomePrice:sum,
                    incomeBudget: budget.budgetPrice
                )
                incomeTableViewDataSource.append(item)
            }else{ //予算が入力されていなくて、priceに入力がない時
                let sumPrice = dayCheckIncome.filter{$0.category == expense.name}.map{$0.price}.reduce(0, {$0 + $1})
                let data = BudgetModel()
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
                    incomePrice: sumPrice,
                    incomeBudget:data.budgetPrice
                )
                incomeTableViewDataSource.append(item)
            }
        }
        //カテゴリーの数だけデータを返す。これは正しい
        //budgetではなくてpriceでデータを集約する。ケースはpriceが0の時、
        
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
        let sum = dayCheck2.filter{$0.isPayment == false}.map{$0.price}.reduce(0){$0 + $1}
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
        let sum = dayCheck2.filter{$0.isPayment == false}.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    
    func setIncomePieGraphView(){
        incomePieGraphView.highlightPerTapEnabled = false
        incomePieGraphView.legend.enabled = false
        incomePieGraphView.drawHoleEnabled = false
        incomePieGraphView.rotationEnabled = false
        incomePieGraphView.noDataTextColor = .black
    }
    
    private func setIncomePieGraphData() -> PieChartData {
        // データの配列を作成する
        var dataEntries:[PieChartDataEntry] = []
        
        //こうすると項目の数が有限になる
        let colors:[UIColor] = [.red, .blue, .green, .yellow, .gray, .brown, .cyan, .purple, .orange]
        for i in 0 ..< incomeTableViewDataSource.count{
            dataEntries.append(PieChartDataEntry(value: Double(incomeTableViewDataSource[i].incomePrice), label: incomeTableViewDataSource[i].name))
        }
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "支出")
        dataSet.colors = colors
        let data = PieChartData(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        return data
    }
    
    private func updateIncomePieGraph(){
        if sumIncome(date) == 0{
            incomePieGraphView.data = nil
            incomePieGraphView.notifyDataSetChanged()
            return
        }else{
            setIncomePieGraphView()
            incomePieGraphView.data = setIncomePieGraphData()
        }
    }
    
    //slidemenu関連
    func setNavigationBarButton(){
        let buttonActionSelector: Selector = #selector(showMenuButton)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: buttonActionSelector)
        
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.title = "家計簿"
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let leftButtonActionSelector: Selector = #selector(showInputView)
        let leftBarButton = UIBarButtonItem(image:UIImage(systemName: "plus"),style: .plain, target: self, action: leftButtonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func showInputView(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
        let navigationController = UINavigationController(rootViewController: inputViewController)
        inputViewController.inputViewControllerDelegate = self
        self.present(navigationController,animated:true)
    }
    
    @objc func showMenuButton(){
        showMenu(shouldExpand: isExpanded)
    }
    
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
    
    func returnView0Second(){
        UIView.animate(
            withDuration: 0.2,
            delay: 1,
            options: .curveEaseIn,
            animations:  {
                self.slideMenuView.frame.origin.x = self.slideMenuView.frame.width - 10
            },
            completion: nil
        )
    }
    
    //推移画面関連
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
            sumPaymentList[i] = Double(Int(dayCheckSumPayment2.map{$0.price}.reduce(0){$0 + $1}))
            sumYearPayment += Int(sumPaymentList[i])
        }
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    func resetSumYearPaymentAndIncome(){
        sumYearPayment = 0
        sumYearIncome = 0
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
            sumIncomeList[i] = Double(dayCheckSumPayment2.map{$0.price}.reduce(0){$0 + $1})
            sumYearIncome += Int(sumIncomeList[i])
        }
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    private func setChartView() {
        chartView.highlightPerTapEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = false
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1.0
    }
    
    private func updateChartView(){
        if sumYearPayment == 0{
            chartView.data = nil
            chartView.notifyDataSetChanged()
        }else{
            chartView.data = setData()
            chartView.notifyDataSetChanged()
        }
    }
    

    // チャートのデータを設定するメソッド
    private func setData() -> BarChartData {
        // データの配列を作成する
        
        var colors: [UIColor] = []
        var dataEntries:[BarChartDataEntry] = []
        for i in 0 ..< 12{
            dataEntries.append(BarChartDataEntry(x: Double(i), y: sumIncomeList[i] - sumPaymentList[i]))
            if sumIncomeList[i] - sumPaymentList[i] <= 0 {
                colors.append(.red)
            } else {
                colors.append(.blue)
            }
        }
        
        // データセットを作成する
        let dataSet = BarChartDataSet(entries: dataEntries, label: "収支")
        dataSet.colors = colors
        
        // チャートデータを作成する
        let data = BarChartData(dataSets: [dataSet])
        data.barWidth = 0.6
        
        return data
    }
    
    func updateList() {
        setPaymentData()
        setIncomeData()
        setCategoryData()
        setIncomeCategoryData()
        setPaymentBudgetData()
        setIncomeBudgetData()
        paymentTableViewDataSource = []
        incomeTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setIncomeTableViewDataSourse()
        setSumPaymentData()
        setSumIncomeData()
        sumPaymentTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
}
        

extension HouseholdAccountBookViewController:InputViewControllerDelegate{
    func changeFromPaymentToIncome() {
        return()
    }
    
    func changeFromIncomeToPayment() {
        return
    }
    
    func didReceiveNotification() {
        return
    }
    
    func updateCalendar() {
        return
    }
    
    func updatePayment() {
        setPaymentData()
        setIncomeData()
        setCategoryData()
        setIncomeCategoryData()
        setPaymentBudgetData()
        setIncomeBudgetData()
        paymentTableViewDataSource = []
        incomeTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setIncomeTableViewDataSourse()
        setSumPaymentData()
        setSumIncomeData()
        setMonthSumPayment()
        setMonthSumIncome()
        
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
        
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultSumTableView.reloadData()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
    }
    
    func updateDiary() {
        return
    }
    
    
}

extension HouseholdAccountBookViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === paymentTableView{
            return categoryList.count
        }else if tableView === incomeTableView{
            return incomeCategoryList.count
        }else if tableView === sumPaymentTableView{
            return 1
        }else if tableView === sumIncomeTableView{
            return 1
        }else if tableView === menuTableView{
            return menuList.count
        }else if tableView === resultTableView{
            return 12
        }else if tableView === resultSumTableView{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === paymentTableView{
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
        }else if tableView === incomeTableView{
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
        }else if tableView === sumPaymentTableView{
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
        }else if tableView === sumIncomeTableView{
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
        }else if tableView === menuTableView{
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = menuList[indexPath.row]
            return cell
        }else if tableView === resultTableView{
            let cell = resultTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ResultTableViewCell
            cell.selectionStyle = .none
            cell.dateLabel.text = "\(String(indexPath.row + 1))月"
            cell.paymentLabel.text = String(Int(sumPaymentList[indexPath.row]))
            cell.incomeLabel.text = String(Int(sumIncomeList[indexPath.row]))
            cell.resultLabel.text = String(Int(sumIncomeList[indexPath.row] - sumPaymentList[indexPath.row]))
            return cell
        }else if tableView === resultSumTableView{
            let cell = resultSumTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ResultTableViewCell
            cell.selectionStyle = .none
            cell.dateLabel.text = "累計"
            cell.paymentLabel.text = String(sumYearPayment)
            cell.incomeLabel.text = String(sumYearIncome)
            cell.resultLabel.text = String(sumYearIncome - sumYearPayment)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === menuTableView{
            switch indexPath.row{
            case 0:
                if householdAccountBookSegmentedControl.selectedSegmentIndex == 1{
                    let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController") as! ExpenseItemViewController
                    expenseItemViewController.categoryViewControllerDelegate = self
                    expenseItemViewController.deleteCategoryDelegateForTabBar = deleteCategoryDelegateForTabBar
                    expenseItemViewController.deleteCategoryDelegateForHouseholdAccountBook = self
                    navigationController.pushViewController(expenseItemViewController, animated: true)
                    present(navigationController,animated: true)
                    expenseItemViewController.segmentedControl!.selectedSegmentIndex = 1
                    expenseItemViewController.addIncomeView()
                    returnView0Second()
                    isExpanded = false
                }else{
                    let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController") as! ExpenseItemViewController
                    expenseItemViewController.categoryViewControllerDelegate = self
                    expenseItemViewController.deleteCategoryDelegateForTabBar = deleteCategoryDelegateForTabBar
                    expenseItemViewController.deleteCategoryDelegateForHouseholdAccountBook = self
                    navigationController.pushViewController(expenseItemViewController, animated: true)
                    present(navigationController,animated: true)
                    returnView0Second()
                    isExpanded = false
                }
            case 1:
                let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                let budgetViewController = storyboard.instantiateViewController(withIdentifier: "BudgetViewController") as! BudgetViewController
                budgetViewController.forHouseholdAccountBookDelegate = self
                budgetViewController.budgetViewControllerDelegate = self
                navigationController.pushViewController(budgetViewController, animated: true)
                
                present(navigationController,animated: true)
                returnView0Second()
                isExpanded = false
            default:
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }else{
            if isExpanded == true{
                returnView()
            }
        }
        return
    }
}


extension HouseholdAccountBookViewController:CategoryViewControllerDelegate{
    func deletePayment() {
        setPaymentData()
        setIncomeData()
        setSumPaymentData()
        setSumIncomeData()
        paymentTableViewDataSource = []
        incomeTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setIncomeTableViewDataSourse()
        setMonthSumPayment()
        setMonthSumIncome()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    func deleteIncome() {
        return
    }
    
    func updateHouseholdAccountBook() {
        setPaymentData()
        setCategoryData()
        setPaymentBudgetData()
        paymentTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setSumPaymentData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    func updateIncome() {
        setIncomeData()
        setIncomeBudgetData()
        setIncomeCategoryData()
        incomeTableViewDataSource = []
        setIncomeTableViewDataSourse()
        setSumIncomeData()
        setMonthSumIncome()
        incomeTableView.reloadData()
        resultSumTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
}

extension HouseholdAccountBookViewController:DeleteCategoryDelegate{
    func setTargetItem(data:CategoryModel,index:IndexPath,journal:[JournalModel],budget:[BudgetModel]){
        targetItem = data
        targetIndex = index
        targetJournal = journal
        targetBudget = budget
    }
    
    func remakeViewController() {
        //カテゴリーについて
        if targetItem?.isPayment == true{
            categoryList.remove(at: targetIndex!.row)
            paymentTableView.deleteRows(at: [targetIndex!], with: .automatic)
        }else if targetItem?.isPayment == false{
            incomeCategoryList.remove(at: targetIndex!.row)
            incomeTableView.deleteRows(at: [targetIndex!], with: .automatic)
        }
        //Journalについて paymentlist,incomelist, struct2種
        if targetItem?.isPayment == true{
            targetJournal!.forEach{target in
                let index = paymentList.firstIndex(where: {$0.id == target.id})
                paymentList.remove(at: index!)
            }
        }else if targetItem?.isPayment == false{
            targetJournal!.forEach{target in
                let index = incomeList.firstIndex(where: {$0.id == target.id})
                incomeList.remove(at: index!)
            }
        }
        //Budgetについて paymentBudgetList,incomeBudgetList, struct2種類
        if targetItem?.isPayment == true{
            targetBudget!.forEach{target in
                let index = paymentBudgetList.firstIndex(where: {$0.id == target.id})
                paymentBudgetList.remove(at: index!)
            }
        }else if targetItem?.isPayment == false{
            targetBudget!.forEach{target in
                let index = incomeBudgetList.firstIndex(where: {$0.id == target.id})
                incomeBudgetList.remove(at: index!)
            }
        }
    }
    
    func remakeUIView(){
        print("デリゲートを実行")
        guard let tab = self.tabBarController as? TabBarController else {return}
        tab.remakeViewController()
    }
}

extension HouseholdAccountBookViewController:ForHouseholdAccountBookDeleagte,BudgetViewControllerDelegate{
    func updateHouseholdAccountBookView() {
        setPaymentData()
        setIncomeData()
        setSumPaymentData()
        setSumIncomeData()
        paymentTableViewDataSource = []
        incomeTableViewDataSource = []
        setPaymentTableViewDataSourse()
        setIncomeTableViewDataSourse()
        setMonthSumPayment()
        setMonthSumIncome()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
}
