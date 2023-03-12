//
//  CalendarViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import FSCalendar
import RealmSwift
import UIKit

class CalendarViewController:UIViewController{
    var date:Date = Date()
    var selectedDate:Date = Date()
    var sumPayment:Int = 0
    private var monthPaymentModelList:[PaymentModel] = []
    private var displayPaymentList:[PaymentModel] = []
    
    private var diaryModelList:[DiaryModel] = []
    private var incomeModelList:[IncomeModel] = []
    private var dayDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    @IBOutlet weak var subDateLabel: UILabel!
    @IBOutlet weak var subPaymentLabel: UILabel!
    @IBOutlet weak var subIncomeLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var householdAccountBookTableView: UITableView!
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet var paymentView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        householdAccountBookTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        calendarView.dataSource = self
        calendarView.delegate = self
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        householdAccountBookTableView.dataSource = self
        householdAccountBookTableView.delegate = self
        addSubView()
        setTableView(selectedDate)
        setDiaryData()
        showPaymentView()
        settingSubView()
        setSubLabel()
        setSum()
        setMonthPaymentModelList()
        paymentLabel.text = String(setMonthPayment())
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if RecognitionChange.shared.updateCalendar == true{
            setDiaryData()
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
            RecognitionChange.shared.updateCalendar = false
        }
        setSubLabel()
        setSum()
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            showPaymentView()
        case 1:
            showDiaryView()
        default:
            return
        }
    }
    
    func addSubView(){
        view.addSubview(paymentView)
        view.addSubview(diaryView)
    }
    
    func showPaymentView(){
        diaryView.isHidden = true
        paymentView.isHidden = false
    }
    
    func showDiaryView(){
        paymentView.isHidden = true
        diaryView.isHidden = false
    }
    
    func settingSubView(){
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,constant: 10).isActive = true
        paymentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        paymentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        paymentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        diaryView.translatesAutoresizingMaskIntoConstraints = false
        diaryView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,constant: 10).isActive = true
        diaryView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        diaryView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        diaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func getComma(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let number = "\(formatter.string(from: NSNumber(value: num)) ?? "")"
        return number
    }
    
    func setMonthPaymentModelList(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        
        let realm = try! Realm()
        let paymentList:[PaymentModel] = realm.objects(PaymentModel.self).filter{($0.date >= firstDay)}
        let paymentList2:[PaymentModel] = paymentList.filter{($0.date <= lastDay!)}
        monthPaymentModelList = paymentList2
    }
    
    func sumPayment(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        let dayCheck = displayPaymentList.filter({$0.date >= (firstDay)})
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay!.zeroclock})
        print(dayCheck2)
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumDayPayment(_: Date) -> Int{
        let sum = displayPaymentList.filter{$0.date.zeroclock == selectedDate.zeroclock}.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumIncome(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!.zeroclock
        let dayCheck = incomeModelList.filter({$0.date >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay})
        let sum = dayCheck2.map{$0.amount}.reduce(0){$0 + $1}
        return sum
    }
    
    func setSum(){
        paymentLabel.text = getComma(sumPayment(selectedDate))
        incomeLabel.text = getComma(sumIncome(selectedDate))
    }
    
    func setSubLabel(){
        subDateLabel.text = dayDateFormatter.string(from: selectedDate)
        subPaymentLabel.text = String(sumDayPayment(selectedDate))
        subIncomeLabel.text = String(0)
    }
    
    func setMonthPayment()-> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        
        var sum:Int = 0
        let realm = try! Realm()
        let paymentList = realm.objects(PaymentModel.self).filter{($0.date >= firstDay)}
        let paymentList2 = paymentList.filter{($0.date <= lastDay!)}
        paymentList2.forEach{payment in
            sum += payment.price
        }
        return sum
    }
    
    func setTableView(_: Date){
        let realm = try! Realm()
        var result:[PaymentModel] = []
        let paymentList = realm.objects(PaymentModel.self).sorted(byKeyPath: "date",ascending: false)
        paymentList.forEach{payment in
            if payment.date.zeroclock == selectedDate.zeroclock{
                result.append(payment)
            }
        }
        displayPaymentList = result
    }
    
    func setIncomeTableView(_: Date) -> [IncomeModel]{
        var result:[IncomeModel] = []
        incomeModelList.forEach{income in
            if income.date.zeroclock == selectedDate.zeroclock{
                result.append(income)
            }
        }
        return result
    }
    
    func setDiaryTableView(_ : Date)-> [DiaryModel]{
        var result:[DiaryModel] = []
        diaryModelList.forEach{diary in
            if diary.date.zeroclock == selectedDate.zeroclock{
                result.append(diary)
            }
        }
        return result
    }
    
    func setDiaryData(){
        let realm = try! Realm()
        let result = realm.objects(DiaryModel.self)
        diaryModelList = Array(result)
        diaryTableView.reloadData()
    }
}


extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return displayPaymentList.count
        }else if tableView.tag == 1{
            return setDiaryTableView(selectedDate).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = householdAccountBookTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = displayPaymentList[indexPath.row]
            cell.budgetCategoryLabel.text = item.category
            cell.budgetPriceLabel.text = getComma(item.price)
            cell.memoLabel.text = item.memo
            return cell
        }else if tableView.tag == 1{
            let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
            let item = setDiaryTableView(selectedDate)[indexPath.row]
            cell.cellDateLabel.text = dayDateFormatter.string(from: item.date)
            cell.cellTextLabel.text = item.text
            cell.cellTitleLabel.text = item.title
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            let targetItem = displayPaymentList[indexPath.row]
            let realm = try! Realm()
            if !targetItem.isInvalidated{
                displayPaymentList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                setSum()
                setSubLabel()
                calendarView.reloadData()
                
                try! realm.write{
                    realm.delete(targetItem)
                }
            }
        }else if tableView.tag == 1{
            let targetItem = diaryModelList[indexPath.row]
            diaryModelList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            calendarView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.payment? = displayPaymentList[indexPath.row]
            inputViewController.setPaymentData(data: displayPaymentList[indexPath.row])
            present(inputViewController,animated:true)
        }else if tableView.tag == 1{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.diary? = setDiaryTableView(selectedDate)[indexPath.row]
            inputViewController.setDiary(data: setDiaryTableView(selectedDate)[indexPath.row])
            present(inputViewController,animated:true)
            inputViewController.viewChangeSegmentedControl!.selectedSegmentIndex = 1
            inputViewController.addDiaryView()
        }else if tableView.tag == 2{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.income? = setIncomeTableView(selectedDate)[indexPath.row]
            inputViewController.setIncomeData(data: setIncomeTableView(selectedDate)[indexPath.row])
            present(inputViewController,animated:true)
        }
    }
}

extension CalendarViewController:InputViewControllerDelegate{
    func updateIncome() {
        return
    }
    
    func updatePayment() {
        return
    }
    
    func updateDiary() {
        setDiaryData()
        calendarView.reloadData()
        diaryTableView.reloadData()
    }
    
    func updateCalendar() {
        calendarView.reloadData()
        householdAccountBookTableView.reloadData()
    }
    
    
}

extension CalendarViewController:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateList = monthPaymentModelList.map({$0.date.zeroclock})
        let isEqualDate = dateList.contains(date.zeroclock)
        return isEqualDate ? 1 : 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor?{
        let dateList = diaryModelList.map({$0.date.zeroclock})
        let isEqualDate = dateList.contains(date.zeroclock)
        return isEqualDate ? UIColor.orange : .none
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        setTableView(selectedDate)
        paymentLabel.text = String(setMonthPayment())
        setSubLabel()
        householdAccountBookTableView.reloadData()
        diaryTableView.reloadData()
    }
}

