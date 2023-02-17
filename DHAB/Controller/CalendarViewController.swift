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

protocol CalendarViewDelegate{
    
}

class CalendarViewController:UIViewController{
    var date:Date = Date()
    var selectedDate:Date = Date()
    private var paymentModelList:[PaymentModel] = []
    private var diaryModelList:[DiaryModel] = []
    private var dayDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
        
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var householdAccountBookTableView: UITableView!
    @IBOutlet var paymentView: UIView!
    @IBOutlet var diaryView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        householdAccountBookTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        calendarView.dataSource = self
        calendarView.delegate = self
        householdAccountBookTableView.dataSource = self
        householdAccountBookTableView.delegate = self
        settingSubView()
        showPaymentView()
        setPaymentData()
        setDiaryData()
        paymentLabel.text = String(sumPayment(selectedDate))
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
    
    func showPaymentView(){
        diaryView.removeFromSuperview()
        view.addSubview(paymentView)
    }
    
    func showDiaryView(){
        paymentView.removeFromSuperview()
        view.addSubview(diaryView)
    }
    
    func settingSubView(){
        paymentView.frame = CGRect(x: 0,
                                   y: segmentedControl.frame.minY + segmentedControl.frame.height,
                                   width: self.view.frame.width,
                                   height: (self.view.frame.height - segmentedControl.frame.minY))
        diaryView.frame = CGRect(x: 0,
                                  y: segmentedControl.frame.minY + segmentedControl.frame.height,
                                  width: self.view.frame.width,
                                  height: (self.view.frame.height - segmentedControl.frame.minY))
    }
    
    func sumPayment(_:Date) -> Int{
         //日付を取得、取得した日付の月首と月末を取得、paymentModelListを２つのフィルターをかける、mapとreduceで合計する
        let calendar = Calendar(identifier: .gregorian)
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        let day = calendar.date(from: comps)!
        let addDay = DateComponents(day: 1)
        let firstDay = calendar.date(byAdding: addDay, to: day)
        let addMonth = DateComponents(month: 1, day: -1)
        let lastDay = calendar.date(byAdding: addMonth, to: firstDay!)!
        let dayCheck = paymentModelList.filter({$0.date >= firstDay!})
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func setTableView(_: Date)-> [PaymentModel]{
        //空の配列を宣言、filterを使ってdateがselectedDateと同じ場合配列に追加、配列を返す
        var result:[PaymentModel] = []
        paymentModelList.forEach{payment in
            if payment.date.zeroclock == selectedDate.zeroclock{
                result.append(payment)
            }
        }
        return result
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPaymentData()
        setDiaryData()
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
    }
    
}


    extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setTableView(selectedDate).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = householdAccountBookTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        let item = setTableView(selectedDate)[indexPath.row]
        cell.budgetCategoryLabel.text = item.category
        cell.budgetPriceLabel.text = String(item.price)
        cell.memoLabel.text = item.memo
        return cell
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
        //ここでテーブルビューを新しくする処理
        householdAccountBookTableView.reloadData()
        print(selectedDate)
        print(setTableView(selectedDate))
    }
}

extension Date{
    var calendar:Calendar{
        var calendar = Calendar(identifier:  .gregorian)
        calendar.timeZone = .current
        calendar.locale = Locale(identifier: "ja-JP")
        return calendar
    }
    
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date{
        var comp = DateComponents()
        comp.year = year ?? calendar.component(.year, from:self)
        comp.month = month ?? calendar.component(.month, from:self)
        comp.day = day ?? calendar.component(.day, from:self)
        comp.hour = hour ?? calendar.component(.hour, from:self)
        comp.minute = minute ?? calendar.component(.minute, from:self)
        comp.second = second ?? calendar.component(.second, from:self)
        return calendar.date(from: comp)!
    }
    
    var zeroclock: Date{
        return fixed(hour: 0, minute: 0, second: 0)
    }
}
