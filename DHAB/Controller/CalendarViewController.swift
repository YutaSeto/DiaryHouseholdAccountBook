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
    let realm = try! Realm()
    var date:Date = Date()
    var selectedDate:Date = Date()
    var swipeDate:Date = Date()
    var sumPayment:Int = 0
    var isButtonPush:Bool = false
    var deleteIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    var displayTableViewIndexPath:IndexPath?
    var income:JournalModel?
    var payment:JournalModel?
    
    private var monthPaymentModelList:[JournalModel] = []
    private var displayPaymentList:[JournalModel] = []
    private var monthIncomeModelList:[JournalModel] = []
    private var displayIncomeList:[JournalModel] = []
    private var diaryModelList:[DiaryModel] = []
    private var incomeModelList:[JournalModel] = []
    let util = Util()
    
    private var displayJournalList:[JournalModel] = []
    
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var householdAccountBookTableView: UITableView!
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet var paymentView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var monthBackButton: UIButton!
    @IBOutlet weak var monthPassButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paymentTableViewFlowLayout: NSLayoutConstraint!
    
    
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad(){
        super.viewDidLoad()
        calendarView.dataSource = self
        calendarView.delegate = self
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        householdAccountBookTableView.dataSource = self
        householdAccountBookTableView.delegate = self
        householdAccountBookTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        diaryTableView.register(UINib(nibName: "DiaryTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        calendarView.collectionView.register(UINib(nibName: "FSCalendarCustomCell", bundle: nil),forCellWithReuseIdentifier: "FSCalendarCustomCell")
        configureButtonZIndex()
        addSubView()
        setTableView(selectedDate)
        setDisplayJournalList(selectedDate)
        setDiaryData()
        showPaymentView()
        settingSubView()
        setMonthPaymentModelList()
        setMonthIncomeModelList()
        setSum()
        dateLabel.text = util.monthDateFormatter.string(from: date)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if RecognitionChange.shared.updateCalendar == true{
            setDiaryData()
            setTableView(selectedDate)
            setDisplayJournalList(selectedDate)
            setMonthPaymentModelList()
            paymentLabel.text = getComma(setMonthPayment())
            incomeLabel.text = getComma(setMonthIncome())
            balanceLabel.text = getComma(Int(setMonthIncome() - setMonthPayment()))
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
            view.layoutIfNeeded()
            view.updateConstraints()
            RecognitionChange.shared.updateCalendar = false
        }
        setMonthPaymentModelList()
        setMonthIncomeModelList()
        
        if RecognitionChange.shared.deleteDiaryByDiary == true{
            calendarView.reloadData()
            setDiaryData()
            diaryTableView.reloadData()
            RecognitionChange.shared.deleteDiaryByDiary = false
        }
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
        setDisplayJournalList(selectedDate)
        setMonthPaymentModelList()
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
        balanceLabel.text = getComma(Int(setMonthIncome() - setMonthPayment()))
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
        setDisplayJournalList(selectedDate)
        setMonthPaymentModelList()
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
        balanceLabel.text = getComma(Int(setMonthIncome() - setMonthPayment()))
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
        let paymentList:[JournalModel] = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay!}.filter{$0.isPayment == true}
        monthPaymentModelList = paymentList
    }
    
    func setMonthIncomeModelList(){
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
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
        balanceLabel.text = getComma(Int(setMonthIncome() - setMonthPayment()))
    }
    
    
    func setMonthPayment()-> Int{
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: comps)!.zeroclock
        let addMonth = DateComponents(month: 1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay)?.zeroclock
        
        var sum:Int = 0
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
        let incomeList = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay!}.filter{$0.isPayment == false}
        incomeList.forEach{income in
            sum += income.price
        }
        return sum
    }
    
    func setTableView(_: Date){
        var result:[JournalModel] = []
        let paymentList = realm.objects(JournalModel.self).sorted(byKeyPath: "date",ascending: false).filter{$0.isPayment == true}
        paymentList.forEach{payment in
            if payment.date.zeroclock == selectedDate.zeroclock{
                result.append(payment)
            }
        }
        displayPaymentList = result
    }
    
    func setDisplayJournalList(_: Date){
        var result:[JournalModel] = []
        let journalList = realm.objects(JournalModel.self).sorted(byKeyPath: "date",ascending: false)
        journalList.forEach{journal in
            if journal.date.zeroclock == selectedDate.zeroclock{
                result.append(journal)
            }
        }
        displayJournalList = result
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
        let result = realm.objects(DiaryModel.self)
        diaryModelList = Array(result)
        diaryTableView.reloadData()
    }
}


extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === householdAccountBookTableView {
            return displayJournalList.count
        }else if tableView === diaryTableView{
            return setDiaryTableView(selectedDate).count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === householdAccountBookTableView{
            let cell = householdAccountBookTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = displayJournalList[indexPath.row]
            cell.budgetCategoryLabel.text = item.category
            cell.budgetPriceLabel.text = getComma(item.price)
            cell.memoLabel.text = item.memo
            return cell
        }else if tableView === diaryTableView{
            let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
            let item = setDiaryTableView(selectedDate)[indexPath.row]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let attributedText = NSAttributedString(string:item.text,attributes:[.font:cell.cellTextLabel.font!,.paragraphStyle: paragraphStyle])
            
            cell.cellDateLabel.text = util.onliDayDateFormatter.string(from: item.date)
            cell.dayOfWeekLabel.text = util.dayOfWeekDateFormatter.string(from: item.date)
            cell.cellTextLabel.attributedText = attributedText
            cell.cellTextLabel.sizeToFit()
            cell.cellTitleLabel.text = item.title
            
            
            
            if item.pictureList.count != 0{
                cell.thumbnailImageView.image = UIImage(data: item.pictureList[0])
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            let targetItem = displayJournalList[indexPath.row]
            if !targetItem.isInvalidated{
                displayJournalList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if targetItem.isPayment == true{
                    let index:Int = monthPaymentModelList.firstIndex(where: {$0.id == targetItem.id})!
                    monthPaymentModelList.remove(at: index)
                }else if targetItem.isPayment == false{
                    let index:Int = monthIncomeModelList.firstIndex(where: {$0.id == targetItem.id})!
                    monthIncomeModelList.remove(at: index)
                }
                try! realm.write{
                    realm.delete(targetItem)
                }
                setMonthPaymentModelList()
                setMonthIncomeModelList()
                setSum()
                calendarView.reloadData()
                
                RecognitionChange.shared.deletePayment = true
            }
        }else if tableView === diaryTableView{
            let targetItem = setDiaryTableView(selectedDate)[indexPath.row]
            if let index = diaryModelList.firstIndex(where: {$0.id == targetItem.id}){
                diaryModelList.remove(at: index)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            try! realm.write{
                realm.delete(targetItem)
            }
            calendarView.reloadData()
            RecognitionChange.shared.deleteDiaryByCalendar = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            deleteIndexPath = indexPath
            let journal = displayJournalList[indexPath.row]
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            let inputCollectionViewCell = InputCollectionViewCell()
            guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
            let navigationController = UINavigationController(rootViewController: inputViewController)
            inputViewController.inputViewControllerDelegate = self
            inputViewController.inputViewModel.journal? = displayJournalList[indexPath.row]
            if journal.isPayment == false{
                income = journal
                inputViewController.inputViewModel.isPayment = false
                inputViewController.setPaymentData(data: displayJournalList[indexPath.row])
                inputCollectionViewCell.journal = journal
                present(navigationController,animated:true)
                tableView.deselectRow(at: indexPath, animated: true)
            }else if journal.isPayment == true{
                payment = journal
                inputViewController.setPaymentData(data: displayJournalList[indexPath.row])
                inputCollectionViewCell.journal = journal
                present(navigationController,animated:true)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }else if tableView === diaryTableView{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
            let navigationController = UINavigationController(rootViewController: inputViewController)
            inputViewController.inputViewControllerDelegate = self
            inputViewController.inputViewModel.diary? = setDiaryTableView(selectedDate)[indexPath.row]
            inputViewController.setDiary(data: setDiaryTableView(selectedDate)[indexPath.row])
            present(navigationController,animated:true)
            inputViewController.addDiaryView()
            inputViewController.inputViewModel.isDiary = true
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //色は要調整
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            let item = displayJournalList[indexPath.row]
            let cell = cell as? BudgetTableViewCell
            if item.isPayment == true{
                cell!.backgroundColor = .red
            }else{
                cell!.backgroundColor = .blue
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === diaryTableView{
            return 120.0
        }
        return UITableView.automaticDimension
    }
    
}

extension CalendarViewController:InputViewControllerDelegate{
    
    func changeFromPaymentToIncome() {
        displayJournalList.remove(at: deleteIndexPath.row)
        householdAccountBookTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        let index:Int = monthPaymentModelList.firstIndex(where: {$0.id == payment!.id})!
        monthPaymentModelList.remove(at: index)

        displayIncomeList.append(payment!)
        monthIncomeModelList.append(payment!)
        
        householdAccountBookTableView.reloadData()
        view.layoutIfNeeded()
        view.updateConstraints()
        payment = nil
        income = nil
    }
    
    func changeFromIncomeToPayment() {
        displayJournalList.remove(at: deleteIndexPath.row)
        householdAccountBookTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        let index:Int = monthIncomeModelList.firstIndex(where: {$0.id == income!.id})!
        monthIncomeModelList.remove(at: index)
        
        displayPaymentList.append(income!)
        monthPaymentModelList.append(income!)
        householdAccountBookTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
        payment = nil
        income = nil
    }
    
    func didReceiveNotification() {
        return
    }
    
    func updateIncome() {
        setTableView(selectedDate)
        setDisplayJournalList(selectedDate)
        householdAccountBookTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func updatePayment() {
        setTableView(selectedDate)
        setDisplayJournalList(selectedDate)
        householdAccountBookTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func updateDiary() {
        setDiaryData()
        calendarView.reloadData()
        diaryTableView.reloadData()
    }
    
    func updateCalendar() {
        setTableView(selectedDate)
        setDisplayJournalList(selectedDate)
        paymentLabel.text = getComma(sumPayment(selectedDate))
        incomeLabel.text = getComma(sumIncome(selectedDate))
        balanceLabel.text = getComma(Int(setMonthIncome() - setMonthPayment()))
        calendarView.reloadData()
        householdAccountBookTableView.reloadData()
        view.layoutIfNeeded()
        view.updateConstraints()
    }
}

extension CalendarViewController:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = .red
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = .blue
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = .black
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = .black
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = .black
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = .black
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = .black
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor?{
        return UIColor.clear
    }
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.visibleCells()
            .map{$0 as? FSCalendarCustomCell}
            .compactMap{$0}
            .filter{$0._isSelected}
            .forEach{ customCell in
                customCell.deselect()
            }
        
        if let cell = calendar.cell(for:date, at: monthPosition) as? FSCalendarCustomCell{
            cell.select()
        }
        
        if monthPosition != .current{
            calendar.setCurrentPage(date, animated: true)
        }
        
        selectedDate = date
        setDisplayJournalList(selectedDate)
        setMonthPaymentModelList()
        setMonthIncomeModelList()
        setSum()
        dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
        householdAccountBookTableView.reloadData()
        diaryTableView.reloadData()
        
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCustomCell", for: date, at: position) as! FSCalendarCustomCell
        cell.dayLabel.text = util.onliDayDateFormatter.string(from: date)
        cell.labelsDate = date
        cell.paymentLabel.text = getComma(realm.objects(JournalModel.self).filter{$0.isPayment == true}.filter{$0.date.zeroclock == date.zeroclock}.map{$0.price}.reduce(0){$0 + $1})
        cell.incomeLabel.text = getComma(realm.objects(JournalModel.self).filter{$0.isPayment == false}.filter{$0.date.zeroclock == date.zeroclock}.map{$0.price}.reduce(0){$0 + $1})
        
        if date.zeroclock == selectedDate.zeroclock{
            cell.select()
        }else{
            cell.deselect()
        }
        
        //祝日判定
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
        
        //テキストの色変更
        if cell.paymentLabel.text != "0"{
            cell.paymentLabel.textColor = .red
        }else{
            cell.paymentLabel.textColor = .clear
        }
        if cell.incomeLabel.text != "0"{
            cell.incomeLabel.textColor = .blue
        }else{
            cell.incomeLabel.textColor = .clear
        }
        
        //日付の色変更+当月外のテキストの色変更
        if holidayArray.contains(date.zeroclock) && date.zeroclock >= startOfMonth && date.zeroclock <= endOfMonth{
            cell.dayLabel.textColor = .red
        }else if weekday == 7 && date >= startOfMonth && date <= endOfMonth{
            cell.dayLabel.textColor = UIColor.blue
        }else if weekday == 1 && date >= startOfMonth && date <= endOfMonth{ // 日曜日または祝日
            cell.dayLabel.textColor = UIColor.red
        }else if date >= startOfMonth && date <= endOfMonth{
            cell.dayLabel.textColor = UIColor.black
        }else{
            cell.dayLabel.textColor = UIColor.lightGray
            cell.paymentLabel.textColor = UIColor.lightGray
            cell.incomeLabel.textColor = UIColor.lightGray
            
            if cell.paymentLabel.text == "0"{
                cell.paymentLabel.textColor = .clear
            }
            if cell.incomeLabel.text == "0"{
                cell.incomeLabel.textColor = .clear
            }
        }
        
        let isEqualDate = diaryModelList.contains(where: {$0.date.zeroclock == date.zeroclock})
        if isEqualDate{
            cell.backgroundColor = .orange
        }else{
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if isButtonPush == false{
            let calendar = Calendar(identifier: .gregorian)
            let currentPage = calendarView.currentPage //現在表示しているページの日付
            let minus = DateComponents(month: -1)
            let add = DateComponents(month: 1)
            
            let lastDay = calendar.date(byAdding: add, to: currentPage)!.zeroclock
            let comparePrevDay = calendar.date(byAdding: minus, to: selectedDate.zeroclock)
            let compareNextDay = calendar.date(byAdding: add, to: selectedDate.zeroclock)
            
            if comparePrevDay! >= currentPage && comparePrevDay! <= lastDay{//先月に移動した場合
                selectedDate = calendar.date(byAdding: minus, to: selectedDate)!
                
                
            }else if compareNextDay! >= currentPage && compareNextDay! <= lastDay{//翌月に移動した場合
                selectedDate = calendar.date(byAdding: add, to: selectedDate)!
            }
            dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
            calendarView.select(selectedDate)
            setTableView(selectedDate)
            setDisplayJournalList(selectedDate)
            setMonthPaymentModelList()
            paymentLabel.text = getComma(setMonthPayment())
            incomeLabel.text = getComma(setMonthIncome())
            balanceLabel.text = getComma(Int(setMonthIncome() - setMonthPayment()))
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
        }
    }
}
