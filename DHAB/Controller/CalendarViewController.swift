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
import CalculateCalendarLogic

class CalendarViewController:UIViewController{
    
    let holiday = CalculateCalendarLogic()
    
    var date:Date = Date()
    var selectedDate:Date = Date()
    var displayDate:Date = Date()
    var sumPayment:Int = 0
    var isButtonPush:Bool = false
    var deleteIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    var income:JournalModel?
    var payment:JournalModel?
    
    private var monthPaymentModelList:[JournalModel] = []
    private var displayPaymentList:[JournalModel] = []
    private var monthIncomeModelList:[JournalModel] = []
    private var displayIncomeList:[JournalModel] = []
    private var diaryModelList:[DiaryModel] = []
    private var incomeModelList:[JournalModel] = []
    let util = Util()
    
    @IBOutlet weak var subDateLabel: UILabel!
    @IBOutlet weak var subPaymentLabel: UILabel!
    @IBOutlet weak var subIncomeLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var householdAccountBookTableView: UITableView!
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet var paymentView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var monthBackButton: UIButton!
    @IBOutlet weak var monthPassButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paymentTableViewFlowLayout: NSLayoutConstraint!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        householdAccountBookTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        incomeTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        calendarView.dataSource = self
        calendarView.delegate = self
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        householdAccountBookTableView.dataSource = self
        householdAccountBookTableView.delegate = self
        incomeTableView.dataSource = self
        incomeTableView.delegate = self
        configureButtonZIndex()
        addSubView()
        setTableView(selectedDate)
        setIncomeTableView(selectedDate)
        setDiaryData()
        showPaymentView()
        settingSubView()
        setMonthPaymentModelList()
        setMonthIncomeModelList()
        setSubLabel()
        setSum()
        dateLabel.text = util.monthDateFormatter.string(from: date)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if RecognitionChange.shared.updateCalendar == true{
            setDiaryData()
            setTableView(selectedDate)
            setMonthPaymentModelList()
            paymentLabel.text = getComma(setMonthPayment())
            incomeLabel.text = getComma(setMonthIncome())
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
            RecognitionChange.shared.updateCalendar = false
        }
        setSubLabel()
        setMonthPaymentModelList()
        setMonthIncomeModelList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        paymentTableViewFlowLayout.constant = CGFloat(householdAccountBookTableView.contentSize.height)
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
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
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
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
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
        let paymentList:[JournalModel] = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay!}.filter{$0.isPayment == true}
        monthPaymentModelList = paymentList
    }
    
    func setMonthIncomeModelList(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        
        let realm = try! Realm()
        let incomeList:[JournalModel] = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay!}.filter{$0.isPayment == false}
        monthIncomeModelList = incomeList
    }
    
    func sumPayment(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        let dayCheck = displayPaymentList.filter({$0.date >= (firstDay)}).filter{$0.isPayment == true}
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay!.zeroclock})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumIncome(_:Date) -> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)!.zeroclock
        let dayCheck = displayIncomeList.filter({$0.date >= firstDay}).filter{$0.date <= lastDay}
        let sum = dayCheck.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func setSum(){
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
    }
    
    func setSubLabel(){
        subDateLabel.text = util.dayDateFormatter.string(from: selectedDate)
        subPaymentLabel.text = getComma(sumPayment(selectedDate))
        subIncomeLabel.text = getComma(sumIncome(selectedDate))
    }
    
    func setMonthPayment()-> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        
        var sum:Int = 0
        let realm = try! Realm()
        let paymentList = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay!}.filter{$0.isPayment == true}
        paymentList.forEach{payment in
            sum += payment.price
        }
        return sum
    }
    
    func setMonthIncome()-> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        
        var sum:Int = 0
        let realm = try! Realm()
        let incomeList = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay!}.filter{$0.isPayment == false}
        incomeList.forEach{income in
            sum += income.price
        }
        return sum
    }
    
    func setTableView(_: Date){
        let realm = try! Realm()
        var result:[JournalModel] = []
        let paymentList = realm.objects(JournalModel.self).sorted(byKeyPath: "date",ascending: false).filter{$0.isPayment == true}
        paymentList.forEach{payment in
            if payment.date.zeroclock == selectedDate.zeroclock{
                result.append(payment)
            }
        }
        displayPaymentList = result
    }
    
    func setIncomeTableView(_: Date){
        let realm = try! Realm()
        var result:[JournalModel] = []
        let incomeList = realm.objects(JournalModel.self).sorted(byKeyPath: "date",ascending: false).filter{$0.isPayment == false}
        incomeList.forEach{income in
            if income.date.zeroclock == selectedDate.zeroclock{
                result.append(income)
            }
        }
        displayIncomeList = result
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
        if tableView === householdAccountBookTableView {
            return displayPaymentList.count
        }else if tableView === diaryTableView{
            return setDiaryTableView(selectedDate).count
        }else if tableView === incomeTableView{
            return displayIncomeList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === householdAccountBookTableView{
            let cell = householdAccountBookTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = displayPaymentList[indexPath.row]
            cell.budgetCategoryLabel.text = item.category
            cell.budgetPriceLabel.text = getComma(item.price)
            cell.memoLabel.text = item.memo
            return cell
        }else if tableView === diaryTableView{
            let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
            let item = setDiaryTableView(selectedDate)[indexPath.row]
            cell.cellDateLabel.text = util.dayDateFormatter.string(from: item.date)
            cell.cellTextLabel.text = item.text
            cell.cellTitleLabel.text = item.title
            return cell
        }else if tableView === incomeTableView{
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = displayIncomeList[indexPath.row]
            cell.budgetCategoryLabel.text = item.category
            cell.budgetPriceLabel.text = getComma(item.price)
            cell.memoLabel.text = item.memo
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            let targetItem = displayPaymentList[indexPath.row]
            let realm = try! Realm()
            if !targetItem.isInvalidated{
                displayPaymentList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                //idが一致しているmonthPaymentModelListの同じインデックス番号を削除
                let index:Int = monthPaymentModelList.firstIndex(where: {$0.id == targetItem.id})!
                monthPaymentModelList.remove(at: index)
                
                setSum()
                setSubLabel()
                calendarView.reloadData()
                
                try! realm.write{
                    realm.delete(targetItem)
                }
                RecognitionChange.shared.deletePayment = true
            }
        }else if tableView === diaryTableView{
            let targetItem = diaryModelList[indexPath.row]
            diaryModelList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let realm = try! Realm()
            try! realm.write{
                realm.delete(targetItem)
            }
            calendarView.reloadData()
        }else if tableView === incomeTableView{
            let targetItem = displayIncomeList[indexPath.row]
            let realm = try! Realm()
            if !targetItem.isInvalidated{
                displayIncomeList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                //idが一致しているmonthPaymentModelListの同じインデックス番号を削除
                let index:Int = monthIncomeModelList.firstIndex(where: {$0.id == targetItem.id})!
                monthIncomeModelList.remove(at: index)
                
                setSum()
                setSubLabel()
                calendarView.reloadData()
                
                try! realm.write{
                    realm.delete(targetItem)
                }
                RecognitionChange.shared.deletePayment = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            deleteIndexPath = indexPath
            payment = displayPaymentList[indexPath.row]
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            let inputCollectionViewCell = InputCollectionViewCell()
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.payment? = displayPaymentList[indexPath.row]
            inputViewController.isPayment = true
            inputViewController.setPaymentData(data: displayPaymentList[indexPath.row])
            inputCollectionViewCell.journal = payment
            present(inputViewController,animated:true)
            tableView.deselectRow(at: indexPath, animated: true)
        }else if tableView === diaryTableView{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.diary? = setDiaryTableView(selectedDate)[indexPath.row]
            inputViewController.setDiary(data: setDiaryTableView(selectedDate)[indexPath.row])
            present(inputViewController,animated:true)
            inputViewController.viewChangeSegmentedControl!.selectedSegmentIndex = 1
            inputViewController.addDiaryView()
            tableView.deselectRow(at: indexPath, animated: true)
        }else if tableView === incomeTableView{
            deleteIndexPath = indexPath
            income = displayIncomeList[indexPath.row]
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateInitialViewController() as? InputViewController else {return}
            inputViewController.inputViewControllerDelegate = self
            inputViewController.income? = displayPaymentList[indexPath.row]
            inputViewController.isPayment = false
            inputViewController.setIncomeData(data: displayIncomeList[indexPath.row])
            present(inputViewController,animated:true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension CalendarViewController:InputViewControllerDelegate{
    func changeFromPaymentToIncome() {
        //displayPaymentListをdelete,displayIncomeListをappend
        //削除
        displayPaymentList.remove(at: deleteIndexPath.row)
        householdAccountBookTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        let index:Int = monthPaymentModelList.firstIndex(where: {$0.id == payment!.id})!
        monthPaymentModelList.remove(at: index)

        displayIncomeList.append(payment!)
        incomeTableView.insertRows(at:[IndexPath(row: displayIncomeList.count - 1, section: 0)], with: .automatic)
        
        //monthIncomeModelListに追加
        monthIncomeModelList.append(payment!)
        
        householdAccountBookTableView.reloadData()
        incomeTableView.reloadData()
        payment = nil
        income = nil
    }
    
    func changeFromIncomeToPayment() {
        displayIncomeList.remove(at: deleteIndexPath.row)
        incomeTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        let index:Int = monthIncomeModelList.firstIndex(where: {$0.id == income!.id})!
        monthIncomeModelList.remove(at: index)
        displayPaymentList.append(income!)
        householdAccountBookTableView.insertRows(at: [IndexPath(row: displayPaymentList.count - 1, section: 0)], with: .automatic)
        monthPaymentModelList.append(income!)
        householdAccountBookTableView.reloadData()
        incomeTableView.reloadData()
        payment = nil
        income = nil
    }
    
    func didReceiveNotification() {
        return
    }
    
    func updateIncome() {
        setTableView(selectedDate)
        setIncomeTableView(selectedDate)
        setSubLabel()
        householdAccountBookTableView.reloadData()
        incomeTableView.reloadData()
    }
    
    func updatePayment() {
        setTableView(selectedDate)
        setIncomeTableView(selectedDate)
        setSubLabel()
        householdAccountBookTableView.reloadData()
        incomeTableView.reloadData()
    }
    
    func updateDiary() {
        setDiaryData()
        calendarView.reloadData()
        diaryTableView.reloadData()
    }
    
    func updateCalendar() {
        setTableView(selectedDate)
        setIncomeTableView(selectedDate)
        paymentLabel.text = getComma(sumPayment(selectedDate))
        incomeLabel.text = getComma(sumIncome(selectedDate))
        setSubLabel()
        calendarView.reloadData()
        householdAccountBookTableView.reloadData()
        incomeTableView.reloadData()
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
        setIncomeTableView(selectedDate)
        setMonthPaymentModelList()
        setMonthIncomeModelList()
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
        setSubLabel()
        dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
        householdAccountBookTableView.reloadData()
        incomeTableView.reloadData()
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
            setIncomeTableView(selectedDate)
            setSubLabel()
            setMonthPaymentModelList()
            setMonthIncomeModelList()
            paymentLabel.text = getComma(setMonthPayment())
            incomeLabel.text = getComma(setMonthIncome())
            householdAccountBookTableView.reloadData()
            incomeTableView.reloadData()
            calendarView.reloadData()
        }else{
            return
        }
    }
    


    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        let year = calendar.dateComponents([.year], from: date)
        let intYear = year.year!
        
        let month = calendar.dateComponents([.month], from: date)
        let intMonth = month.month!
        
        let day = calendar.dateComponents([.day], from: date)
        let intDay = day.day!
        
        var holidayArray:[Date] = []
        func judgeHoliday(year:Int,month:Int,day:Int){
            let result = holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
            if result == true{
                holidayArray.append(calendar.date(from:DateComponents(year:intYear,month:intMonth,day: intDay))!.zeroclock)
            }
        }
        judgeHoliday(year: intYear, month: intMonth, day: intDay)
        
        let targetMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))?.zeroclock
        let startOfMonth = calendar.date(byAdding: DateComponents(day: -1), to: targetMonth!)!.zeroclock
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: targetMonth!)!.zeroclock
        
        if holidayArray.contains(date.zeroclock) && date.zeroclock >= startOfMonth && date.zeroclock <= endOfMonth{
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
