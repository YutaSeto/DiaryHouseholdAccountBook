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
    private var paymentModelList:[PaymentModel] = []
    private var diaryModelList:[DiaryModel] = []
    private var incomeModelList:[IncomeModel] = []
    private var dayDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日hh時mm分"
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
        setPaymentData()
        setDiaryData()
        showPaymentView()
        settingSubView()
        setSubLabel()
        setSum()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if RecognitionChange.shared.updateCalendar == true{
            setPaymentData()
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
    
    func sumPayment(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        let dayCheck = paymentModelList.filter({$0.date >= (firstDay)})
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay!})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumDayPayment(_: Date) -> Int{
        let sum = paymentModelList.filter{$0.date.zeroclock == selectedDate.zeroclock}.map{$0.price}.reduce(0){$0 + $1}
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
        print(firstDay)
        print(lastDay)
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
    
    func setTableView(_: Date)-> [PaymentModel]{
        var result:[PaymentModel] = []
        paymentModelList.forEach{payment in
            if payment.date.zeroclock == selectedDate.zeroclock{
                result.append(payment)
            }
        }
        return result
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
    

    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentModel.self).sorted(byKeyPath: "date",ascending: false)
        paymentModelList = Array(result)
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
            return setTableView(selectedDate).count
        }else if tableView.tag == 1{
            return setDiaryTableView(selectedDate).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let cell = householdAccountBookTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = setTableView(selectedDate)[indexPath.row]
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
            let targetItem = setTableView(selectedDate)[indexPath.row]
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            if !targetItem.isInvalidated{
                paymentModelList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                setSum()
                setSubLabel()
                calendarView.reloadData()
            }
        }else if tableView.tag == 1{
            let targetItem = diaryModelList[indexPath.row]
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            diaryModelList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            calendarView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.payment? = setTableView(selectedDate)[indexPath.row]
            inputViewController.setPaymentData(data: setTableView(selectedDate)[indexPath.row])
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
        }
//        }else if tableView.tag == 2{
//            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
//            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
//            inputViewController.inputViewControllerDelegate = self
//            inputViewController.income? = setIncomeTableView(selectedDate)[indexPath.row]
//            inputViewController.setIncomeData(data: setIncomeTableView(selectedDate)[indexPath.row])
//            present(inputViewController,animated:true)
//        }
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
        setPaymentData()
        calendarView.reloadData()
        householdAccountBookTableView.reloadData()
//        incomeTableView.reloadData()
    }
    
    
}

extension CalendarViewController:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateList = paymentModelList.map({$0.date.zeroclock})
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
        paymentLabel.text = String(sumPayment(selectedDate))
        setSubLabel()
        householdAccountBookTableView.reloadData()
        diaryTableView.reloadData()
    }
}

