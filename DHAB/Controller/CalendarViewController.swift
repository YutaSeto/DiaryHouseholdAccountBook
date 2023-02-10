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
    
    private var paymentModelList:[PaymentModel] = []
    private var dayDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    var date:Date = Date()
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var householdAccountBookTableView: UITableView!
    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentModel.self).sorted(byKeyPath: "date",ascending: false)
        paymentModelList = Array(result)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        calendarView.dataSource = self
        calendarView.delegate = self
        setPaymentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPaymentData()
    }
}


    extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

extension CalendarViewController:FSCalendarDataSource,FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateList = paymentModelList.map({$0.date.zeroclock})
        let isEqualDate = dateList.contains(date.zeroclock)
        return isEqualDate ? 1 : 0
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
