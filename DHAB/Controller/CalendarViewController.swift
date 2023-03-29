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
    
    private var displayJournalList:[JournalModel] = []
    
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
        setIncomeTableView(selectedDate)
        setDisplayJournalList(selectedDate)
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
            setDisplayJournalList(selectedDate)
            setMonthPaymentModelList()
            paymentLabel.text = getComma(setMonthPayment())
            incomeLabel.text = getComma(setMonthIncome())
            calendarView.reloadData()
            householdAccountBookTableView.reloadData()
            diaryTableView.reloadData()
            view.layoutIfNeeded()
            view.updateConstraints()
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
        setDisplayJournalList(selectedDate)
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
        setDisplayJournalList(selectedDate)
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
    
    func setIncomeTableView(_: Date){
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
            cell.cellDateLabel.text = util.dayDateFormatter.string(from: item.date)
            cell.cellTextLabel.text = item.text
            cell.cellTitleLabel.text = item.title
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
            try! realm.write{
                realm.delete(targetItem)
            }
            calendarView.reloadData()
            RecognitionChange.shared.deleteDiary = true
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
            inputViewController.journal? = displayJournalList[indexPath.row]
            if journal.isPayment == false{
                inputViewController.isPayment = false
                inputViewController.setPaymentData(data: displayJournalList[indexPath.row])
                inputCollectionViewCell.journal = journal
                present(navigationController,animated:true)
                tableView.deselectRow(at: indexPath, animated: true)
            }else if journal.isPayment == true{
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
            inputViewController.diary? = setDiaryTableView(selectedDate)[indexPath.row]
            inputViewController.setDiary(data: setDiaryTableView(selectedDate)[indexPath.row])
            present(navigationController,animated:true)
            inputViewController.addDiaryView()
            inputViewController.isDiary = true
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
}

extension CalendarViewController:InputViewControllerDelegate{
    func changeFromPaymentToIncome() {
        displayPaymentList.remove(at: deleteIndexPath.row)
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
        displayIncomeList.remove(at: deleteIndexPath.row)
        let index:Int = monthIncomeModelList.firstIndex(where: {$0.id == income!.id})!
        monthIncomeModelList.remove(at: index)
        displayPaymentList.append(income!)
        householdAccountBookTableView.insertRows(at: [IndexPath(row: displayPaymentList.count - 1, section: 0)], with: .automatic)
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
        setIncomeTableView(selectedDate)
        setSubLabel()
        householdAccountBookTableView.reloadData()
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func updatePayment() {
        setTableView(selectedDate)
        setDisplayJournalList(selectedDate)
        setIncomeTableView(selectedDate)
        setSubLabel()
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
        setIncomeTableView(selectedDate)
        paymentLabel.text = getComma(sumPayment(selectedDate))
        incomeLabel.text = getComma(sumIncome(selectedDate))
        setSubLabel()
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
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor?{
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.visibleCells()
            .map { $0 as? FSCalendarCustomCell } // カスタムセルに変換する
            .compactMap { $0 } // nilを削除
            .filter { $0._isSelected } // 選択中のセルのみ取り出す
            .forEach { customCell in
                customCell.deselect()
            }
        
        if let cell = calendar.cell(for: date, at: monthPosition) as? FSCalendarCustomCell {
            cell.select()
        }
        
        selectedDate = date
        
        setDisplayJournalList(selectedDate)
        setIncomeTableView(selectedDate)
        setMonthPaymentModelList()
        setMonthIncomeModelList()
        paymentLabel.text = getComma(setMonthPayment())
        incomeLabel.text = getComma(setMonthIncome())
        setSubLabel()
        dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
        householdAccountBookTableView.reloadData()
        diaryTableView.reloadData()
        
        
        view.layoutIfNeeded()
        view.updateConstraints()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCustomCell", for: date, at: position) as! FSCalendarCustomCell
        cell.dayLabel.text = util.onliDayDateFormatter.string(from: date)
        cell.paymentLabel.text = getComma(realm.objects(JournalModel.self).filter{$0.isPayment == true}.filter{$0.date.zeroclock == date.zeroclock}.map{$0.price}.reduce(0){$0 + $1})
        cell.incomeLabel.text = getComma(realm.objects(JournalModel.self).filter{$0.isPayment == false}.filter{$0.date.zeroclock == date.zeroclock}.map{$0.price}.reduce(0){$0 + $1})
        
        if date.zeroclock == selectedDate.zeroclock {
            cell.select()
        } else {
            cell.deselect()
        }
        
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
        
        
        
        return cell
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if isButtonPush == false{
            displayDate = calendar.currentPage.zeroclock
            dateLabel.text = util.monthDateFormatter.string(from: displayDate)
            selectedDate = displayDate
            
            dateLabel.text = util.monthDateFormatter.string(from: selectedDate)
            calendarView.select(selectedDate)
            setTableView(selectedDate)
            setDisplayJournalList(selectedDate)
            setIncomeTableView(selectedDate)
            setSubLabel()
            setMonthPaymentModelList()
            setMonthIncomeModelList()
            paymentLabel.text = getComma(setMonthPayment())
            incomeLabel.text = getComma(setMonthIncome())
            householdAccountBookTableView.reloadData()
            view.layoutIfNeeded()
            view.updateConstraints()
            calendarView.reloadData()
        }else{
            return
        }
    }
    
    
}
