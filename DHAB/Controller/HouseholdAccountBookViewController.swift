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
        dayLabel.text = monthDateFormatter.string(from: date)
    }
    
    func dayPass(){
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        dayLabel.text = monthDateFormatter.string(from: date)
    }
    
    private var date = Date()
    
    private var monthDateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    private var dayDateFormatter: DateFormatter{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy年MM月dd日"
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
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        setPaymentData()
        dayLabel.text = dayDateFormatter.string(from:date)
        addPaymentView()
        settingSubView()
        setPaymentData()
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        configureInputButton()
    }
    
    //支出画面の設定
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var inputButton: UIButton!
    
    @IBAction func inputButton(_ sender: Any) {
        tapInputButton()
    }
    private var paymentModelList:[PaymentModel] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        paymentModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = paymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
        let paymentModel: PaymentModel = paymentModelList[indexPath.row]
        cell.dateLabel.text = dayDateFormatter.string(from: paymentModel.date)
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
    
    func configureInputButton(){
        inputButton.layer.cornerRadius = inputButton.bounds.width / 2
    }
    
    func  tapInputButton(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        present(inputViewController,animated:true)
    }
}
