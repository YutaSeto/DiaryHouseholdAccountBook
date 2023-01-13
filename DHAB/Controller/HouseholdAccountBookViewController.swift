//
//  HouseholdAccountBookViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import RealmSwift
import UIKit
import Charts

class HouseholdAccountBookViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,InputViewControllerDelegate{
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var householdAccountBookSegmentedControl: UISegmentedControl!
    
    @IBAction func householdAccountBookSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addPaymentView()
        case 1:
            addIncomeView()
        case 2:
            addSavingView()
        default:
            return
        }
    }
    
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
    }
    
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
    }
    
    func dayBack(){
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        dayLabel.text = dateFormatter.string(from: date)
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        dayLabel.text = dateFormatter.string(from: date)
    }
    
    var date = Date()
    
    var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    //subView関連
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var savingView: UIView!
    
    func addPaymentView(){
        incomeView.removeFromSuperview()
        savingView.removeFromSuperview()
        self.view.addSubview(paymentView)
    }
    func addIncomeView(){
        paymentView.removeFromSuperview()
        savingView.removeFromSuperview()
        self.view.addSubview(incomeView)
    }
    
    func addSavingView(){
        paymentView.removeFromSuperview()
        incomeView.removeFromSuperview()
        self.view.addSubview(savingView)
    }
    
    func settingSubView(){
        paymentView.frame = CGRect(x: 0,
                                   y: householdAccountBookSegmentedControl.frame.minY + householdAccountBookSegmentedControl.frame.height,
                                   width: self.view.frame.width,
                                   height: (self.view.frame.height - householdAccountBookSegmentedControl.frame.minY))
        incomeView.frame = CGRect(x: 0,
                                  y: householdAccountBookSegmentedControl.frame.minY + householdAccountBookSegmentedControl.frame.height,
                                  width: self.view.frame.width,
                                  height: (self.view.frame.height - householdAccountBookSegmentedControl.frame.minY))
        savingView.frame = CGRect(x: 0,
                                  y: householdAccountBookSegmentedControl.frame.minY + householdAccountBookSegmentedControl.frame.height,
                                  width: self.view.frame.width,
                                  height: (self.view.frame.height - householdAccountBookSegmentedControl.frame.minY))
    }
    
    override func viewDidLoad() {
        dayLabel.text = dateFormatter.string(from:date)
        addPaymentView()
        settingSubView()
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        setPaymentData()
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paymentTableView.delegate = self
    }
    
    //支出画面の設定
    @IBOutlet weak var paymentTableView: UITableView!
    
    var paymentModelList:[PaymentModel] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        paymentModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = paymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
        let paymentModel: PaymentModel = paymentModelList[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: paymentModel.date)
        cell.expenceItemLabel.text = paymentModel.expenceItem
        cell.priceLabel.text = String(paymentModel.price)
        return cell
    }
    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(PaymentModel.self)
        paymentModelList = Array(result)
        paymentTableView.reloadData()
    }
        
    func updatePayment() {
        setPaymentData()
    }
    
    func updateDiary() {
        return
    }
    
}
