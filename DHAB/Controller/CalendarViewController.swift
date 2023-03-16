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
    var displayDate:Date = Date()
    var sumPayment:Int = 0
    var isButtonPush:Bool = false
    private var monthPaymentModelList:[PaymentModel] = []
    private var displayPaymentList:[PaymentModel] = []
    private var diaryModelList:[DiaryModel] = []
    private var incomeModelList:[IncomeModel] = []
    let util = Util()
    
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
    @IBOutlet weak var monthBackButton: UIButton!
    @IBOutlet weak var monthPassButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
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
        configureButtonZIndex()
        addSubView()
        setTableView(selectedDate)
        setDiaryData()
        showPaymentView()
        settingSubView()
        setSubLabel()
        setMonthPaymentModelList()
        setSum()
        dateLabel.text = util.monthDateFormatter.string(from: date)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if RecognitionChange.shared.updateCalendar == true{
            setDiaryData()
            setTableView(selectedDate)
            setMonthPaymentModelList()
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
            RecognitionChange.shared.updateCalendar = false
        }
        setSubLabel()
        setMonthPaymentModelList()
    }
    
    @IBAction func monthBackButton(_ sender: UIButton) {
        isButtonPush = true
        let currentPage = calendarView.currentPage
        let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentPage)!
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
        calendarView.select(selectedDate)
        setTableView(selectedDate)
        setSubLabel()
        setMonthPaymentModelList()
        paymentLabel.text = String(setMonthPayment())
        calendarView.setCurrentPage(prevMonth, animated: true)
        isButtonPush = false
    }
    
    @IBAction func monthPassButton(_ sender: UIButton) {
        isButtonPush = true
        let currentPage = calendarView.currentPage
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentPage)!
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
        calendarView.select(selectedDate)
        setTableView(selectedDate)
        setSubLabel()
        setMonthPaymentModelList()
        paymentLabel.text = String(setMonthPayment())
        calendarView.setCurrentPage(nextMonth, animated: true)
        isButtonPush = false
    }
    
    func configureButtonZIndex(){
        monthBackButton.layer.zPosition = calendarView.layer.zPosition + 1
        monthPassButton.layer.zPosition = calendarView.layer.zPosition + 1
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
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(sumIncome(selectedDate))
    }
    
    func setSubLabel(){
        subDateLabel.text = util.dayDateFormatter.string(from: selectedDate)
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
            cell.cellDateLabel.text = util.dayDateFormatter.string(from: item.date)
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
                
                //idが一致しているmonthPaymentModelListの同じインデックス番号を削除
                let index = monthPaymentModelList.firstIndex(where: {$0.id == targetItem.id})
                monthPaymentModelList.remove(at: index!)
                
                setSum()
                setSubLabel()
                calendarView.reloadData()
                
                try! realm.write{
                    realm.delete(targetItem)
                }
                RecognitionChange.shared.deletePayment = true
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
        setTableView(selectedDate)
        setSubLabel()
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
//        if monthPosition == .previous || monthPosition == .next {
//            calendar.setCurrentPage(date, animated: true)
//        }
        selectedDate = date
        setTableView(selectedDate)
        setMonthPaymentModelList()
        paymentLabel.text = String(setMonthPayment())
        setSubLabel()
        dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
        householdAccountBookTableView.reloadData()
        diaryTableView.reloadData()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if isButtonPush == false{
            displayDate = calendar.currentPage.zeroclock
            dateLabel.text = util.monthDateFormatter.string(from: displayDate)
            selectedDate = displayDate
            
            dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
            calendarView.select(selectedDate)
            setTableView(selectedDate)
            setSubLabel()
            setMonthPaymentModelList()
            paymentLabel.text = String(setMonthPayment())
            calendarView.reloadData()
        }else{
            return
        }
    }
    


    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        
        //毎月の1日の曜日を取得
        let year = calendar.dateComponents([.year], from: selectedDate)
        let intYear = year.year!
        let month = calendar.dateComponents([.month], from: selectedDate)
        let intMonth = month.month!
        
        let holiday:[Date] = [
            calendar.date(from: DateComponents(year:intYear,month:1,day:1))!.zeroclock,//元旦
            calendar.date(from: DateComponents(year:intYear,month:1, weekday:2, weekdayOrdinal: 2))!.zeroclock,//成人の日
            calendar.date(from:DateComponents(year:intYear, month:2, day:11))!.zeroclock,//建国記念日
            calendar.date(from:DateComponents(year:intYear, month:2, day:23))!.zeroclock,//天皇誕生日
            calendar.date(from:DateComponents(year:intYear, month:3, day:20))!.zeroclock,//春分の日
            calendar.date(from:DateComponents(year:intYear, month:4, day:29))!.zeroclock,//昭和の日
            calendar.date(from:DateComponents(year:intYear, month:5, day:3))!.zeroclock,//憲法記念日
            calendar.date(from:DateComponents(year:intYear, month:5, day:4))!.zeroclock,//みどりの日
            calendar.date(from:DateComponents(year:intYear, month:5, day:5))!.zeroclock,//こどもの日
            calendar.date(from: DateComponents(year:intYear,month:7, weekday:2, weekdayOrdinal: 3))!.zeroclock,//海の日
            calendar.date(from:DateComponents(year:intYear, month:8, day:11))!.zeroclock,//山の日
            calendar.date(from: DateComponents(year:intYear,month:9, weekday:2, weekdayOrdinal: 3))!.zeroclock,//敬老の日
            calendar.date(from:DateComponents(year:intYear, month:9, day:22))!.zeroclock,//秋分の日
            calendar.date(from: DateComponents(year:intYear,month:10, weekday:2, weekdayOrdinal: 2))!.zeroclock,//体育の日
            calendar.date(from:DateComponents(year:intYear, month:5, day:3))!.zeroclock,//文化の日
            calendar.date(from:DateComponents(year:intYear, month:5, day:3))!.zeroclock,//勤労感謝の日
        ]
        
        let targetMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))?.zeroclock
        let startOfMonth = calendar.date(byAdding: DateComponents(day: -1), to: targetMonth!)!.zeroclock
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: targetMonth!)!.zeroclock
        //      祝日かどうかを判定する処理を追加する必要あり
        print(date.zeroclock)
        if holiday.contains(date.zeroclock) && date >= startOfMonth && date <= endOfMonth{
            return UIColor.red
        }else if weekday == 7 && date >= startOfMonth && date <= endOfMonth{
            return UIColor.blue
        }else if weekday == 1 && date >= startOfMonth && date <= endOfMonth{ // 日曜日または祝日
            return UIColor.red
        }else if date >= startOfMonth && date <= endOfMonth{
            return appearance.titleDefaultColor
        }else{
            return UIColor.lightGray
        }
    }
}

