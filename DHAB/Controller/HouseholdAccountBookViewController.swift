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
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var householdAccountBookSegmentedControl: UISegmentedControl!
    
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
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        dayLabel.text = monthDateFormatter.string(from: date)
        paymentTableView.reloadData()
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        dayLabel.text = monthDateFormatter.string(from: date)
        paymentTableView.reloadData()
    }
    
    private var date = Date()
    
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
    
    func setMonthFirstAndEnd(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        var firstDay = calendar.date(from: comps)!
        let add = DateComponents(day:1)
        let addMonth = DateComponents(month: 1, day: -1)
        firstDay = calendar.date(byAdding: add, to: firstDay)!
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!
    }
    
    //subView関連
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var savingView: UIView!
    
    func addPaymentView(){
        incomeView.removeFromSuperview()
        savingView.removeFromSuperview()
        self.view.addSubview(paymentView)
    }
    func addIncomeView(){
        paymentView.removeFromSuperview()
        savingView.removeFromSuperview()
        self.view.addSubview(incomeView)
    }
    
    func addSavingView(){
        paymentView.removeFromSuperview()
        incomeView.removeFromSuperview()
        self.view.addSubview(savingView)
    }
    
    func settingSubView(){
        paymentView.frame = CGRect(x: 0,
                                   y: householdAccountBookSegmentedControl.frame.minY + householdAccountBookSegmentedControl.frame.height,
                                   width: self.view.frame.width,
                                   height: (self.view.frame.height - householdAccountBookSegmentedControl.frame.minY))
        incomeView.frame = CGRect(x: 0,
                                  y: householdAccountBookSegmentedControl.frame.minY + householdAccountBookSegmentedControl.frame.height,
                                  width: self.view.frame.width,
                                  height: (self.view.frame.height - householdAccountBookSegmentedControl.frame.minY))
        savingView.frame = CGRect(x: 0,
                                  y: householdAccountBookSegmentedControl.frame.minY + householdAccountBookSegmentedControl.frame.height,
                                  width: self.view.frame.width,
                                  height: (self.view.frame.height - householdAccountBookSegmentedControl.frame.minY))
    }
    
    override func viewDidLoad() {
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        dayLabel.text = monthDateFormatter.string(from:date)
        addPaymentView()
        settingSubView()
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        configureInputButton()
        setPaymentData()
        setPaymentBudgetData()
        setCategoryData()
        setBudgetTableViewDataSourse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //支出画面の設定
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var inputButton: UIButton!
    
    @IBAction func inputButton(_ sender: Any) {
        tapInputButton()
    }
    
    private var paymentList:[PaymentModel] = []
    private var paymentBudgetList:[PaymentBudgetModel] = []
    private var categoryList:[CategoryModel] = []
    private var paymentTableViewDataSource: [HouseholdAccountBookTableViewCellItem] = []
    let realm = try! Realm()
    
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
    }
    
    func  tapInputButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
        inputViewController.inputViewControllerDelegate = self
        present(inputViewController,animated:true)
    }
    
    func setBudgetTableViewDataSourse(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: comps)!
        let add = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: add, to: firstDay)!
        let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheckBudget2 = dayCheckBudget.filter({$0.budgetDate <= lastDay})
        
        let dayCheckPayment = paymentList.filter({$0.date >= firstDay})
        let dayCheckPayment2 = dayCheckPayment.filter{$0.date <= lastDay}
        let sum = dayCheckPayment2.map{$0.price}.reduce(0){$0 + $1}

        
        categoryList.forEach{ expense in
            if let budget:PaymentBudgetModel = dayCheckBudget2.filter({$0.expenseID == expense.id}).first{
                
//                dayCheckPayment2のcategoryとexpenseのnameが一致しているpriceを全て取得する
                var sum = dayCheckPayment2.filter{$0.category == expense.name}.map{$0.price}.reduce(0){$0 + $1}
                
                
                let item = HouseholdAccountBookTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    paymentPrice:String(sum),
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
    
//    func sumPrices(){
//        //重複しない費目の配列
//        var uniqueExpenceItems = Array(Set(paymentModelList.map({$0.expenceItem})))
//        var sumPrice:Int = 0
//
//        let realm = try! Realm()
//        let result = realm.objects(PaymentModel.self).sorted(byKeyPath: "date",ascending: false)
//        for i in 0 ..< result.count{
//            if result[i].expenceItem == "食費" {
//                sumPrice += result[i].price
//            }
//        }
//        print(sumPrice)
//
//    }
}

extension HouseholdAccountBookViewController:InputViewControllerDelegate{
    func updatePayment() {
        setPaymentData()
    }
    
    func updateDiary() {
        return
    }
}

extension HouseholdAccountBookViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = paymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
        let item = paymentTableViewDataSource[indexPath.row]
        cell.expenceItemLabel.text = item.name
        cell.budgetLabel.text = String(item.budgetPrice)
        cell.priceLabel.text = item.paymentPrice
        return cell
    }
}
