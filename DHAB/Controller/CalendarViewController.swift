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
    
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var householdAccountBookTableView: UITableView!
    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentModel.self).sorted(byKeyPath: "date",ascending: false)
        paymentModelList = Array(result)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
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
