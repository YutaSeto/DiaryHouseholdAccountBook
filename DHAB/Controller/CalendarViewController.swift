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
    
    let util = Util()
    let calendarViewModel = CalendarViewModel()
    let holiday = CalculateCalendarLogic()
    
    
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
        calendarViewModel.setTableView()
        calendarViewModel.setDisplayJournalList()
        calendarViewModel.setDiaryData()
        diaryTableView.reloadData()
        showPaymentView()
        settingSubView()
        calendarViewModel.setMonthPaymentModelList()
        calendarViewModel.setMonthIncomeModelList()
        setSum()
        dateLabel.text = util.monthDateFormatter.string(from: calendarViewModel.date)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if RecognitionChange.shared.updateCalendar == true{
            calendarViewModel.setDiaryData()
            calendarViewModel.setTableView()
            calendarViewModel.setDisplayJournalList()
            calendarViewModel.setMonthPaymentModelList()
            paymentLabel.text = util.getComma(calendarViewModel.setMonthPayment())
            incomeLabel.text = util.getComma(calendarViewModel.setMonthIncome())
            balanceLabel.text = util.getComma(Int(calendarViewModel.setMonthIncome() - calendarViewModel.setMonthPayment()))
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
            view.layoutIfNeeded()
            view.updateConstraints()
            RecognitionChange.shared.updateCalendar = false
        }
        calendarViewModel.setMonthPaymentModelList()
        calendarViewModel.setMonthIncomeModelList()
        
        if RecognitionChange.shared.deleteDiaryByDiary == true{
            calendarView.reloadData()
            calendarViewModel.setDiaryData()
            diaryTableView.reloadData()
            RecognitionChange.shared.deleteDiaryByDiary = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        paymentTableViewFlowLayout.constant = CGFloat(householdAccountBookTableView.contentSize.height)
    }
    
    @IBAction func monthBackButton(_ sender: UIButton) {
        calendarViewModel.isButtonPush = true
        let currentPage = calendarView.currentPage
        let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentPage)!
        calendarViewModel.selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: calendarViewModel.selectedDate)!
        dateLabel.text = util.monthDateFormatter.string(from: calendarViewModel.selectedDate)
        calendarView.select(calendarViewModel.selectedDate)
        calendarViewModel.setTableView()
        calendarViewModel.setDisplayJournalList()
        calendarViewModel.setMonthPaymentModelList()
        paymentLabel.text = util.getComma(calendarViewModel.setMonthPayment())
        incomeLabel.text = util.getComma(calendarViewModel.setMonthIncome())
        balanceLabel.text = util.getComma(Int(calendarViewModel.setMonthIncome() - calendarViewModel.setMonthPayment()))
        calendarView.setCurrentPage(prevMonth, animated: true)
        calendarViewModel.isButtonPush = false
    }
    
    @IBAction func monthPassButton(_ sender: UIButton) {
        calendarViewModel.isButtonPush = true
        let currentPage = calendarView.currentPage
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentPage)!
        calendarViewModel.selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: calendarViewModel.selectedDate)!
        dateLabel.text = util.monthDateFormatter.string(from: calendarViewModel.selectedDate)
        calendarView.select(calendarViewModel.selectedDate)
        calendarViewModel.setTableView()
        calendarViewModel.setDisplayJournalList()
        calendarViewModel.setMonthPaymentModelList()
        paymentLabel.text = util.getComma(calendarViewModel.setMonthPayment())
        incomeLabel.text = util.getComma(calendarViewModel.setMonthIncome())
        balanceLabel.text = util.getComma(Int(calendarViewModel.setMonthIncome() - calendarViewModel.setMonthPayment()))
        calendarView.setCurrentPage(nextMonth, animated: true)
        calendarViewModel.isButtonPush = false
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
    
    func setSum(){
        paymentLabel.text = util.getComma(calendarViewModel.setMonthPayment())
        incomeLabel.text = util.getComma(calendarViewModel.setMonthIncome())
        balanceLabel.text = util.getComma(Int(calendarViewModel.setMonthIncome() - calendarViewModel.setMonthPayment()))
    }
}


extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === householdAccountBookTableView {
            return calendarViewModel.displayJournalList.count
        }else if tableView === diaryTableView{
            return calendarViewModel.setDiaryTableView().count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === householdAccountBookTableView{
            let cell = householdAccountBookTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
            let item = calendarViewModel.displayJournalList[indexPath.row]
            cell.budgetCategoryLabel.text = item.category
            cell.budgetPriceLabel.text = util.getComma(item.price)
            cell.memoLabel.text = item.memo
            return cell
        }else if tableView === diaryTableView{
            let cell = diaryTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! DiaryTableViewCell
            let item = calendarViewModel.setDiaryTableView()[indexPath.row]
            
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
            calendarViewModel.deleteHouseholdAccountBookTableViewCell(tableView: householdAccountBookTableView, indexPath: indexPath)
            calendarView.reloadData()
            setSum()
            RecognitionChange.shared.deletePayment = true
        }else if tableView === diaryTableView{
            calendarViewModel.deleteDiaryTableViewCell(tableView: diaryTableView, indexPath: indexPath)
            calendarView.reloadData()
            RecognitionChange.shared.deleteDiaryByCalendar = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            calendarViewModel.deleteIndexPath = indexPath
            let journal = calendarViewModel.displayJournalList[indexPath.row]
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            let inputCollectionViewCell = InputCollectionViewCell()
            guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
            let navigationController = UINavigationController(rootViewController: inputViewController)
            inputViewController.inputViewControllerDelegate = self
            inputViewController.inputViewModel.journal? = calendarViewModel.displayJournalList[indexPath.row]
            if journal.isPayment == false{
                calendarViewModel.income = journal
                inputViewController.inputViewModel.isPayment = false
                inputViewController.setPaymentData(data: calendarViewModel.displayJournalList[indexPath.row])
                inputCollectionViewCell.journal = journal
                present(navigationController,animated:true)
                tableView.deselectRow(at: indexPath, animated: true)
            }else if journal.isPayment == true{
                calendarViewModel.payment = journal
                inputViewController.setPaymentData(data: calendarViewModel.displayJournalList[indexPath.row])
                inputCollectionViewCell.journal = journal
                present(navigationController,animated:true)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }else if tableView === diaryTableView{
            let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
            guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
            let navigationController = UINavigationController(rootViewController: inputViewController)
            inputViewController.inputViewControllerDelegate = self
            inputViewController.inputViewModel.diary? = calendarViewModel.setDiaryTableView()[indexPath.row]
            inputViewController.setDiary(data: calendarViewModel.setDiaryTableView()[indexPath.row])
            present(navigationController,animated:true)
            inputViewController.addDiaryView()
            inputViewController.inputViewModel.isDiary = true
            RecognitionChange.shared.updateDiaryByCalendar = true
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //色は要調整
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView === householdAccountBookTableView{
            let item = calendarViewModel.displayJournalList[indexPath.row]
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
        calendarViewModel.removePaymentAddIncome(tableView: householdAccountBookTableView)
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func changeFromIncomeToPayment() {
        calendarViewModel.removeIncomeAddPayment(tableView: householdAccountBookTableView)
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func didReceiveNotification() {
        return
    }
    
    func updateIncome() {
        calendarViewModel.setTableView()
        calendarViewModel.setDisplayJournalList()
        householdAccountBookTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func updatePayment() {
        calendarViewModel.setTableView()
        calendarViewModel.setDisplayJournalList()
        householdAccountBookTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func updateDiary() {
        calendarViewModel.setDiaryData()
        calendarView.reloadData()
        diaryTableView.reloadData()
    }
    
    func updateCalendar() {
        calendarViewModel.setTableView()
        calendarViewModel.setDisplayJournalList()
        paymentLabel.text = util.getComma(calendarViewModel.setSumPayment())
        incomeLabel.text = util.getComma(calendarViewModel.setSumIncome())
        balanceLabel.text = util.getComma(Int(calendarViewModel.setMonthIncome() - calendarViewModel.setMonthPayment()))
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
        
        calendarViewModel.selectedDate = date
        calendarViewModel.setDisplayJournalList()
        calendarViewModel.setMonthPaymentModelList()
        calendarViewModel.setMonthIncomeModelList()
        setSum()
        dateLabel.text = util.monthDateFormatter.string(from: calendarViewModel.selectedDate)
        householdAccountBookTableView.reloadData()
        diaryTableView.reloadData()
        
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCustomCell", for: date, at: position) as! FSCalendarCustomCell
        cell.dayLabel.text = util.onliDayDateFormatter.string(from: date)
        cell.labelsDate = date
        cell.paymentLabel.text = calendarViewModel.setSumPaymentForCalendarCell(date: date)
        cell.incomeLabel.text = calendarViewModel.setSumIncomeForCalendarCell(date: date)
        
        if date.zeroclock == calendarViewModel.selectedDate.zeroclock{
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
        
        let targetMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: calendarViewModel.selectedDate))?.zeroclock
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
        
        let isEqualDate = calendarViewModel.diaryModelList.contains(where: {$0.date.zeroclock == date.zeroclock})
        if isEqualDate{
            cell.backgroundColor = .orange
        }else{
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if calendarViewModel.isButtonPush == false{
            let calendar = Calendar(identifier: .gregorian)
            let currentPage = calendarView.currentPage //現在表示しているページの日付
            let minus = DateComponents(month: -1)
            let add = DateComponents(month: 1)
            
            let lastDay = calendar.date(byAdding: add, to: currentPage)!.zeroclock
            let comparePrevDay = calendar.date(byAdding: minus, to: calendarViewModel.selectedDate.zeroclock)
            let compareNextDay = calendar.date(byAdding: add, to: calendarViewModel.selectedDate.zeroclock)
            
            if comparePrevDay! >= currentPage && comparePrevDay! <= lastDay{//先月に移動した場合
                calendarViewModel.selectedDate = calendar.date(byAdding: minus, to: calendarViewModel.selectedDate)!
                
                
            }else if compareNextDay! >= currentPage && compareNextDay! <= lastDay{//翌月に移動した場合
                calendarViewModel.selectedDate = calendar.date(byAdding: add, to: calendarViewModel.selectedDate)!
            }
            dateLabel.text = util.monthDateFormatter.string(from: calendarViewModel.selectedDate)
            calendarView.select(calendarViewModel.selectedDate)
            calendarViewModel.setTableView()
            calendarViewModel.setDisplayJournalList()
            calendarViewModel.setMonthPaymentModelList()
            paymentLabel.text = util.getComma(calendarViewModel.setMonthPayment())
            incomeLabel.text = util.getComma(calendarViewModel.setMonthIncome())
            balanceLabel.text = util.getComma(Int(calendarViewModel.setMonthIncome() - calendarViewModel.setMonthPayment()))
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
        }
    }
}
