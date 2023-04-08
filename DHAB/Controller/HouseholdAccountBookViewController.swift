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
import ChameleonFramework

class HouseholdAccountBookViewController:UIViewController{
        
    let householdAccountBookViewModel = HouseholdAccountBookViewModel()
    let util = Util()
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayBackButton: UIButton!
    @IBOutlet weak var threeMonthBackButton: UIButton!
    @IBOutlet weak var dayPassButton: UIButton!
    @IBOutlet weak var threeMonthPassButton: UIButton!
    @IBOutlet weak var householdAccountBookSegmentedControl: UISegmentedControl!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //subView関連
    @IBOutlet var paymentView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var savingView: UIView!
    
    //支出画面の設定
    
    @IBOutlet weak var sumPaymentTableView: UITableView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var paymentPieGraphView: PieChartView!
    @IBOutlet weak var sumPaymentTableViewHeight: NSLayoutConstraint!
    
    //収入画面関連
    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableView: UITableView!
    @IBOutlet weak var sumIncomeTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var incomePieGraphView: PieChartView!
    
    //slideMenu画面関連
    @IBOutlet var slideMenuView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    var deleteCategoryDelegateForTabBar:DeleteCategoryDelegate?
    
    //推移画面関連
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var resultSumTableView: UITableView!
    @IBOutlet weak var resultSumTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        Logger.debug("")
        
        setNib()
        dayLabel.text = util.monthDateFormatter.string(from:householdAccountBookViewModel.date)
        addSubView()
        addPaymentView()
        settingSubView()
        setDelegateAndDataSource()
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setPaymentBudgetData()
        householdAccountBookViewModel.setIncomeBudgetData()
        householdAccountBookViewModel.setIncomeCategoryData()
        householdAccountBookViewModel.setCategoryData()
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        tableViewScroll()
        setSegmentedControlColor(color: .flatPowderBlueColorDark())
        setStatusBarBackgroundColor(.flatPowderBlueColorDark())
        incomeTableView.reloadData()
        paymentTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        
        setChartView()
        chartView.data = householdAccountBookViewModel.setData()
        setIncomePieGraphView()
        incomePieGraphView.data = householdAccountBookViewModel.setIncomePieGraphData()
        setNavigationBarButton()
        
        if householdAccountBookViewModel.setSumPayment() == 0{
            return
        }else{
            setPaymentPieGraphView()
            paymentPieGraphView.data = householdAccountBookViewModel.setPaymentPieGraphData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        householdAccountBookViewModel.isExpanded = false
        
        if RecognitionChange.shared.updateHouseholdAccountBook == true{
            householdAccountBookViewModel.setPaymentData()
            householdAccountBookViewModel.setIncomeData()
            householdAccountBookViewModel.setCategoryData()
            householdAccountBookViewModel.setIncomeCategoryData()
            householdAccountBookViewModel.setPaymentBudgetData()
            householdAccountBookViewModel.setIncomeBudgetData()
            householdAccountBookViewModel.paymentTableViewDataSource = []
            householdAccountBookViewModel.setPaymentTableViewDataSourse()
            householdAccountBookViewModel.incomeTableViewDataSource = []
            householdAccountBookViewModel.setIncomeTableViewDataSourse()
            paymentTableView.reloadData()
            sumPaymentTableView.reloadData()
            incomeTableView.reloadData()
            sumIncomeTableView.reloadData()
            updateChartView()
            updatePaymentPieGraph()
            updateIncomePieGraph()
            RecognitionChange.shared.updateHouseholdAccountBook = false
        }
        
        if RecognitionChange.shared.deletePayment == true{
            householdAccountBookViewModel.setPaymentData()
            householdAccountBookViewModel.setIncomeData()
            householdAccountBookViewModel.setSumPaymentData()
            householdAccountBookViewModel.setSumIncomeData()
            householdAccountBookViewModel.paymentTableViewDataSource = []
            householdAccountBookViewModel.incomeTableViewDataSource = []
            
            householdAccountBookViewModel.setPaymentTableViewDataSourse()
            householdAccountBookViewModel.setIncomeTableViewDataSourse()
            householdAccountBookViewModel.setMonthSumPayment()
            householdAccountBookViewModel.setMonthSumIncome()
            paymentTableView.reloadData()
            sumPaymentTableView.reloadData()
            incomeTableView.reloadData()
            sumIncomeTableView.reloadData()
            resultTableView.reloadData()
            resultSumTableView.reloadData()
            updateChartView()
            updatePaymentPieGraph()
            updateIncomePieGraph()
            RecognitionChange.shared.deletePayment = false
        }
        
        if RecognitionChange.shared.updateJournalByCalendar == true{
            householdAccountBookViewModel.setPaymentData()
            householdAccountBookViewModel.setIncomeData()
            householdAccountBookViewModel.setSumPaymentData()
            householdAccountBookViewModel.setSumIncomeData()
            householdAccountBookViewModel.paymentTableViewDataSource = []
            householdAccountBookViewModel.incomeTableViewDataSource = []
            
            householdAccountBookViewModel.setPaymentTableViewDataSourse()
            householdAccountBookViewModel.setIncomeTableViewDataSourse()
            householdAccountBookViewModel.setMonthSumPayment()
            householdAccountBookViewModel.setMonthSumIncome()
            paymentTableView.reloadData()
            sumPaymentTableView.reloadData()
            incomeTableView.reloadData()
            sumIncomeTableView.reloadData()
            resultTableView.reloadData()
            resultSumTableView.reloadData()
            updateChartView()
            updatePaymentPieGraph()
            updateIncomePieGraph()
            
            RecognitionChange.shared.updateJournalByCalendar = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sumPaymentTableViewHeight.constant = CGFloat(sumPaymentTableView.contentSize.height)
        sumIncomeTableViewHeight.constant = CGFloat(sumIncomeTableView.contentSize.height)
        resultSumTableViewHeight.constant = CGFloat(resultSumTableView.contentSize.height)
    }
    
    func tableViewScroll(){
        sumPaymentTableView.isScrollEnabled = false
        sumIncomeTableView.isScrollEnabled = false
        resultSumTableView.isScrollEnabled = false
    }
    
    func setSegmentedControlColor(color:UIColor){
        householdAccountBookSegmentedControl.selectedSegmentTintColor = color
        householdAccountBookSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)!], for: .selected)
        householdAccountBookSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(contrastingBlackOrWhiteColorOn: UIColor.systemGray3, isFlat: true)!], for: .normal)
    }
    
    func setNib(){
        paymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        incomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        sumPaymentTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        sumIncomeTableView.register(UINib(nibName: "HouseholdAccountBookTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        resultTableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        resultSumTableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
        menuTableView.register(UINib(nibName: "SelectStartUpModalTableViewCell", bundle: nil),forCellReuseIdentifier: "customCell")
    }
    
    func setDelegateAndDataSource(){
        paymentTableView.delegate = self
        paymentTableView.dataSource = self
        incomeTableView.delegate = self
        incomeTableView.dataSource = self
        sumPaymentTableView.delegate = self
        sumPaymentTableView.dataSource = self
        sumIncomeTableView.delegate = self
        sumIncomeTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.dataSource = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        resultSumTableView.delegate = self
        resultSumTableView.dataSource = self
    }
    
    
    @IBAction func householdAccountBookSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addPaymentView()
            householdAccountBookViewModel.isMonth = true
        case 1:
            addIncomeView()
            householdAccountBookViewModel.isMonth = true
        case 2:
            addSavingView()
            householdAccountBookViewModel.isMonth = false
        default:
            return
        }
    }
    
    
    @IBAction func dayBackButton(_ sender: UIButton) {
        dayBack()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    @IBAction func threeMonthBackButton(_ sender: UIButton) {
        threeMonthBack()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    @IBAction func dayPassButton(_ sender: UIButton) {
        dayPass()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    @IBAction func threeMonthPassButton(_ sender: UIButton) {
        threeMonthPass()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    
    func dayBack(){
        if householdAccountBookViewModel.isMonth{
            householdAccountBookViewModel.date = Calendar.current.date(byAdding: .month, value: -1, to: householdAccountBookViewModel.date)!
            dayLabel.text = util.monthDateFormatter.string(from: householdAccountBookViewModel.date)
        }else{
            householdAccountBookViewModel.date = Calendar.current.date(byAdding: .year, value: -1, to: householdAccountBookViewModel.date)!
            dayLabel.text = util.yearDateFormatter.string(from: householdAccountBookViewModel.date)
        }
        householdAccountBookViewModel.resetSumYearPaymentAndIncome()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        updateList()
        updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    func threeMonthBack(){
        householdAccountBookViewModel.date = Calendar.current.date(byAdding: .month, value: -3, to: householdAccountBookViewModel.date)!
        dayLabel.text = util.monthDateFormatter.string(from: householdAccountBookViewModel.date)
        householdAccountBookViewModel.resetSumYearPaymentAndIncome()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        updateList()
        updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    func dayPass(){
        if householdAccountBookViewModel.isMonth{
            householdAccountBookViewModel.date = Calendar.current.date(byAdding: .month, value: 1, to: householdAccountBookViewModel.date)!
            dayLabel.text = util.monthDateFormatter.string(from: householdAccountBookViewModel.date)
        }else{
            householdAccountBookViewModel.date = Calendar.current.date(byAdding: .year, value: 1, to: householdAccountBookViewModel.date)!
            dayLabel.text = util.yearDateFormatter.string(from: householdAccountBookViewModel.date)
        }
        householdAccountBookViewModel.resetSumYearPaymentAndIncome()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        updateList()
        updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    func threeMonthPass(){
        householdAccountBookViewModel.date = Calendar.current.date(byAdding: .month, value: 3, to: householdAccountBookViewModel.date)!
        dayLabel.text = util.monthDateFormatter.string(from: householdAccountBookViewModel.date)
        householdAccountBookViewModel.resetSumYearPaymentAndIncome()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        updateList()
        updateIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    //subView関連
    func addSubView(){
        view.addSubview(incomeView)
        view.addSubview(paymentView)
        view.addSubview(savingView)
        view.addSubview(slideMenuView)
    }
    
    func addPaymentView(){
        savingView.isHidden = true
        incomeView.isHidden = true
        paymentView.isHidden = false
        dayLabel.text = util.monthDateFormatter.string(from: householdAccountBookViewModel.date)
        threeMonthBackButton.isHidden = false
        threeMonthPassButton.isHidden = false
    }
    func addIncomeView(){
        savingView.isHidden = true
        paymentView.isHidden = true
        incomeView.isHidden = false
        dayLabel.text = util.monthDateFormatter.string(from: householdAccountBookViewModel.date)
        threeMonthBackButton.isHidden = false
        threeMonthPassButton.isHidden = false
    }
    
    func addSavingView(){
        incomeView.isHidden = true
        paymentView.isHidden = true
        savingView.isHidden = false
        dayLabel.text = util.yearDateFormatter.string(from: householdAccountBookViewModel.date)
        threeMonthBackButton.isHidden = true
        threeMonthPassButton.isHidden = true
    }
    
    func settingSubView(){
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.topAnchor.constraint(equalTo: householdAccountBookSegmentedControl.bottomAnchor,constant: 10).isActive = true
        paymentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        paymentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        paymentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        incomeView.translatesAutoresizingMaskIntoConstraints = false
        incomeView.topAnchor.constraint(equalTo: householdAccountBookSegmentedControl.bottomAnchor,constant: 10).isActive = true
        incomeView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        incomeView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        incomeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        savingView.translatesAutoresizingMaskIntoConstraints = false
        savingView.topAnchor.constraint(equalTo: householdAccountBookSegmentedControl.bottomAnchor,constant: 10).isActive = true
        savingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        savingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        savingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        slideMenuView.translatesAutoresizingMaskIntoConstraints = false
        slideMenuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        slideMenuView.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        slideMenuView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        slideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //支出画面関連
    
    func setPaymentPieGraphView(){
        paymentPieGraphView.highlightPerTapEnabled = false
        paymentPieGraphView.legend.enabled = false
        paymentPieGraphView.drawHoleEnabled = false
        paymentPieGraphView.rotationEnabled = false
        paymentPieGraphView.noDataTextColor = .black
    }
    
    private func updatePaymentPieGraph(){
        if householdAccountBookViewModel.setSumPayment() == 0{
            paymentPieGraphView.data = nil
            paymentPieGraphView.notifyDataSetChanged()
            return
        }else{
            setPaymentPieGraphView()
            paymentPieGraphView.data = householdAccountBookViewModel.setPaymentPieGraphData()
        }
    }

    func setIncomePieGraphView(){
        incomePieGraphView.highlightPerTapEnabled = false
        incomePieGraphView.legend.enabled = false
        incomePieGraphView.drawHoleEnabled = false
        incomePieGraphView.rotationEnabled = false
        incomePieGraphView.noDataTextColor = .black
    }
    
    private func updateIncomePieGraph(){
        if householdAccountBookViewModel.setSumIncome() == 0{
            incomePieGraphView.data = nil
            incomePieGraphView.notifyDataSetChanged()
            return
        }else{
            setIncomePieGraphView()
            incomePieGraphView.data = householdAccountBookViewModel.setIncomePieGraphData()
        }
    }
    
    //slidemenu関連
    func setNavigationBarButton(){
        let buttonActionSelector: Selector = #selector(showMenuButton)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: buttonActionSelector)
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.title = "家計簿"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)!]
        
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let leftButtonActionSelector: Selector = #selector(showInputView)
        let leftBarButton = UIBarButtonItem(image:UIImage(systemName: "plus"),style: .plain, target: self, action: leftButtonActionSelector)
        navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: .flatPowderBlueColorDark(), isFlat: true)
    }
    
    @objc func showInputView(){
        let storyboard = UIStoryboard(name: "InputViewController", bundle: nil)
        guard let inputViewController = storyboard.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController else {return}
        let navigationController = UINavigationController(rootViewController: inputViewController)
        inputViewController.inputViewControllerDelegate = self
        self.present(navigationController,animated:true)
    }
    
    @objc func showMenuButton(){
        showMenu(shouldExpand: householdAccountBookViewModel.isExpanded)
    }
    
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        showMenu(shouldExpand: householdAccountBookViewModel.isExpanded)
    }
    
    func showMenu(shouldExpand:Bool){
        if shouldExpand{
            returnView()
            householdAccountBookViewModel.isExpanded = false
        }else{
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: .curveEaseInOut,
                animations: {
                    self.slideMenuView.frame.origin.x = self.view.frame.width - self.slideMenuView.frame.width
                }, completion: nil)
            householdAccountBookViewModel.isExpanded = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches{
            if touch.view?.tag == 4{
                return
            }else{
                returnView()
                householdAccountBookViewModel.isExpanded = false
            }
        }
        householdAccountBookViewModel.isExpanded = false
    }
    
    func returnView(){
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations:  {
                self.slideMenuView.frame.origin.x = self.view.frame.width + self.slideMenuView.frame.width
            },
            completion: nil
        )
        householdAccountBookViewModel.isExpanded = false
    }
    
    func returnView0Second(){
        UIView.animate(
            withDuration: 0.2,
            delay: 1,
            options: .curveEaseIn,
            animations:  {
                self.slideMenuView.frame.origin.x = self.slideMenuView.frame.width - 10
            },
            completion: nil
        )
    }
    
    
    private func setChartView() {
        chartView.highlightPerTapEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = false
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1.0
    }
    
    private func updateChartView(){
        if householdAccountBookViewModel.sumYearPayment == 0{
            chartView.data = nil
            chartView.notifyDataSetChanged()
        }else{
            chartView.data = householdAccountBookViewModel.setData()
            chartView.notifyDataSetChanged()
        }
    }
    
    func updateList() {
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setCategoryData()
        householdAccountBookViewModel.setIncomeCategoryData()
        householdAccountBookViewModel.setPaymentBudgetData()
        householdAccountBookViewModel.setIncomeBudgetData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setSumPaymentData()
        householdAccountBookViewModel.setSumIncomeData()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        sumPaymentTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
}
        

extension HouseholdAccountBookViewController:InputViewControllerDelegate{
    func changeFromPaymentToIncome() {
        return()
    }
    
    func changeFromIncomeToPayment() {
        return
    }
    
    func didReceiveNotification() {
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setCategoryData()
        householdAccountBookViewModel.setIncomeCategoryData()
        householdAccountBookViewModel.setPaymentBudgetData()
        householdAccountBookViewModel.setIncomeBudgetData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setSumPaymentData()
        householdAccountBookViewModel.setSumIncomeData()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
        
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
    }
    
    func updateCalendar() {
        return
    }
    
    func updatePayment() {
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setCategoryData()
        householdAccountBookViewModel.setIncomeCategoryData()
        householdAccountBookViewModel.setPaymentBudgetData()
        householdAccountBookViewModel.setIncomeBudgetData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setSumPaymentData()
        householdAccountBookViewModel.setSumIncomeData()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
        
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
    }
    
    func updateDiary() {
        return
    }
    
    
}

extension HouseholdAccountBookViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === paymentTableView{
            return householdAccountBookViewModel.categoryList.count
        }else if tableView === incomeTableView{
            return householdAccountBookViewModel.incomeCategoryList.count
        }else if tableView === sumPaymentTableView{
            return 1
        }else if tableView === sumIncomeTableView{
            return 1
        }else if tableView === menuTableView{
            return householdAccountBookViewModel.menuList.count
        }else if tableView === resultTableView{
            return 12
        }else if tableView === resultSumTableView{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === paymentTableView{
            let cell = paymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            let item = householdAccountBookViewModel.paymentTableViewDataSource[indexPath.row]
            cell.data = item
            cell.expenceItemLabel.text = item.name
            cell.budgetLabel.text = util.getComma(item.budgetPrice)
            cell.priceLabel.text = util.getComma(item.paymentPrice)
            cell.balanceLabel.text = util.getComma(item.budgetPrice - item.paymentPrice)
            guard item.budgetPrice != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(item.budgetPrice - item.paymentPrice) / Float(item.budgetPrice)), animated: false)
            return cell
        }else if tableView === incomeTableView{
            let cell = incomeTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            let item = householdAccountBookViewModel.incomeTableViewDataSource[indexPath.row]
            cell.incomeData = item
            cell.expenceItemLabel.text = item.name
            cell.budgetLabel.text = util.getComma(item.incomeBudget)
            cell.priceLabel.text = util.getComma(item.incomePrice)
            cell.balanceLabel.text = util.getComma(item.incomeBudget - item.incomePrice)
            guard item.incomeBudget != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(item.incomeBudget - item.incomePrice) / Float(item.incomeBudget)), animated: false)
            return cell
        }else if tableView === sumPaymentTableView{
            let cell = sumPaymentTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            cell.expenceItemLabel.text = "合計"
            cell.budgetLabel.text = util.getComma(householdAccountBookViewModel.sumPaymentBudget())
            cell.priceLabel.text = util.getComma(householdAccountBookViewModel.setSumPayment())
            cell.balanceLabel.text = util.getComma(householdAccountBookViewModel.sumPaymentBudget() - householdAccountBookViewModel.setSumPayment())
            guard householdAccountBookViewModel.sumPaymentBudget() != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(householdAccountBookViewModel.sumPaymentBudget() - householdAccountBookViewModel.setSumPayment()) / Float(householdAccountBookViewModel.sumPaymentBudget())), animated: false)
            return cell
        }else if tableView === sumIncomeTableView{
            let cell = sumIncomeTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HouseholdAccountBookTableViewCell
            cell.expenceItemLabel.text = "合計"
            cell.budgetLabel.text = String(householdAccountBookViewModel.sumIncomeBudget())
            cell.priceLabel.text = String(householdAccountBookViewModel.setSumIncome())
            cell.balanceLabel.text = String(householdAccountBookViewModel.sumIncomeBudget() - householdAccountBookViewModel.setSumIncome())
            guard householdAccountBookViewModel.sumIncomeBudget() != 0 else {
                cell.progressBar.setProgress(Float(0), animated: false)
                return cell
            }
            cell.progressBar.setProgress(1 - Float(Float(householdAccountBookViewModel.sumIncomeBudget() - householdAccountBookViewModel.setSumIncome()) / Float(householdAccountBookViewModel.sumIncomeBudget())), animated: false)
            return cell
        }else if tableView === menuTableView{
            if indexPath.row == 2{
                if RecognitionChange.shared.startUpTimeModal == false{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! SelectStartUpModalTableViewCell
                    cell.modalSwitch.isOn = false
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! SelectStartUpModalTableViewCell
                    return cell
                }
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel!.text = householdAccountBookViewModel.menuList[indexPath.row]
                return cell
            }
        }else if tableView === resultTableView{
            let cell = resultTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ResultTableViewCell
            cell.selectionStyle = .none
            cell.dateLabel.text = "\(String(indexPath.row + 1))月"
            cell.paymentLabel.text = String(Int(householdAccountBookViewModel.sumPaymentList[indexPath.row]))
            cell.incomeLabel.text = String(Int(householdAccountBookViewModel.sumIncomeList[indexPath.row]))
            cell.resultLabel.text = String(Int(householdAccountBookViewModel.sumIncomeList[indexPath.row] - householdAccountBookViewModel.sumPaymentList[indexPath.row]))
            return cell
        }else if tableView === resultSumTableView{
            let cell = resultSumTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ResultTableViewCell
            cell.selectionStyle = .none
            cell.dateLabel.text = "累計"
            cell.paymentLabel.text = String(householdAccountBookViewModel.sumYearPayment)
            cell.incomeLabel.text = String(householdAccountBookViewModel.sumYearIncome)
            cell.resultLabel.text = String(householdAccountBookViewModel.sumYearIncome - householdAccountBookViewModel.sumYearPayment)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === menuTableView{
            switch indexPath.row{
            case 0:
                if householdAccountBookSegmentedControl.selectedSegmentIndex == 1{
                    let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController") as! ExpenseItemViewController
                    expenseItemViewController.categoryViewControllerDelegate = self
                    expenseItemViewController.deleteCategoryDelegateForTabBar = deleteCategoryDelegateForTabBar
                    expenseItemViewController.deleteCategoryDelegateForHouseholdAccountBook = self
                    navigationController.pushViewController(expenseItemViewController, animated: true)
                    present(navigationController,animated: true)
                    
                    expenseItemViewController.expenseItemViewModel.isIncome = true
                    expenseItemViewController.addIncomeView()
                    returnView0Second()
                    householdAccountBookViewModel.isExpanded = false
                }else{
                    let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController") as! ExpenseItemViewController
                    expenseItemViewController.categoryViewControllerDelegate = self
                    expenseItemViewController.deleteCategoryDelegateForTabBar = deleteCategoryDelegateForTabBar
                    expenseItemViewController.deleteCategoryDelegateForHouseholdAccountBook = self
                    navigationController.pushViewController(expenseItemViewController, animated: true)
                    present(navigationController,animated: true)
                    returnView0Second()
                    householdAccountBookViewModel.isExpanded = false
                }
            case 1:
                let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
                let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                let budgetViewController = storyboard.instantiateViewController(withIdentifier: "BudgetViewController") as! BudgetViewController
                budgetViewController.forHouseholdAccountBookDelegate = self
                budgetViewController.budgetViewControllerDelegate = self
                navigationController.pushViewController(budgetViewController, animated: true)
                
                present(navigationController,animated: true)
                returnView0Second()
                householdAccountBookViewModel.isExpanded = false
            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! SelectStartUpModalTableViewCell
                return
            default:
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }else{
            if householdAccountBookViewModel.isExpanded == true{
                returnView()
            }
        }
        return
    }
}


extension HouseholdAccountBookViewController:CategoryViewControllerDelegate{
    func deletePayment() {
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setSumPaymentData()
        householdAccountBookViewModel.setSumIncomeData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    func deleteIncome() {
        return
    }
    
    func updateHouseholdAccountBook() {
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setCategoryData()
        householdAccountBookViewModel.setPaymentBudgetData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setSumPaymentData()
        paymentTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    func updateIncome() {
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setIncomeBudgetData()
        householdAccountBookViewModel.setIncomeCategoryData()
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setSumIncomeData()
        householdAccountBookViewModel.setMonthSumIncome()
        incomeTableView.reloadData()
        resultSumTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
}

extension HouseholdAccountBookViewController:DeleteCategoryDelegate{
    func deleteTargetItem(data:Category,index:IndexPath,journal:[Journal],budget:[Budget]){
        householdAccountBookViewModel.targetItem = data
        householdAccountBookViewModel.targetIndex = index
        householdAccountBookViewModel.targetJournal = journal
        householdAccountBookViewModel.targetBudget = budget
        //paymentListの削除
        householdAccountBookViewModel.deleteTargetJournal()
        //categorylistの削除
        householdAccountBookViewModel.deleteTargetCategory()
//        paymentbudgetlistの削除
        householdAccountBookViewModel.deleteTargetBudget()
        
        if data.isPayment == true{
            paymentTableView.deleteRows(at: [index], with: .automatic)
        }else if data.isPayment == false{
            incomeTableView.deleteRows(at: [index], with: .automatic)
        }
        
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
    
    func remakeViewController() {
        //カテゴリーについて
        if householdAccountBookViewModel.targetItem?.isPayment == true{
            householdAccountBookViewModel.categoryList.remove(at: householdAccountBookViewModel.targetIndex!.row)
            paymentTableView.deleteRows(at: [householdAccountBookViewModel.targetIndex!], with: .automatic)
        }else if householdAccountBookViewModel.targetItem?.isPayment == false{
            householdAccountBookViewModel.incomeCategoryList.remove(at: householdAccountBookViewModel.targetIndex!.row)
            incomeTableView.deleteRows(at: [householdAccountBookViewModel.targetIndex!], with: .automatic)
        }
        //Journalについて paymentlist,incomelist, struct2種
        if householdAccountBookViewModel.targetItem?.isPayment == true{
            householdAccountBookViewModel.targetJournal!.forEach{target in
                let index = householdAccountBookViewModel.paymentList.firstIndex(where: {$0.id == target.id})
                householdAccountBookViewModel.paymentList.remove(at: index!)
            }
        }else if householdAccountBookViewModel.targetItem?.isPayment == false{
            householdAccountBookViewModel.targetJournal!.forEach{target in
                let index = householdAccountBookViewModel.incomeList.firstIndex(where: {$0.id == target.id})
                householdAccountBookViewModel.incomeList.remove(at: index!)
            }
        }
        //Budgetについて paymentBudgetList,incomeBudgetList, struct2種類
        if householdAccountBookViewModel.targetItem?.isPayment == true{
            householdAccountBookViewModel.targetBudget!.forEach{target in
                let index = householdAccountBookViewModel.paymentBudgetList.firstIndex(where: {$0.id == target.id})
                householdAccountBookViewModel.paymentBudgetList.remove(at: index!)
            }
        }else if householdAccountBookViewModel.targetItem?.isPayment == false{
            householdAccountBookViewModel.targetBudget!.forEach{target in
                let index = householdAccountBookViewModel.incomeBudgetList.firstIndex(where: {$0.id == target.id})
                householdAccountBookViewModel.incomeBudgetList.remove(at: index!)
            }
        }
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setSumPaymentData()
        householdAccountBookViewModel.setSumIncomeData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        paymentTableView.reloadData()
        incomeTableView.reloadData()
        sumPaymentTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
    }
    
    func remakeUIView(){
        guard let tab = self.tabBarController as? TabBarController else {return}
        tab.remakeViewController()
    }
}

extension HouseholdAccountBookViewController:ForHouseholdAccountBookDeleagte,BudgetViewControllerDelegate{
    func updateHouseholdAccountBookView() {
        householdAccountBookViewModel.setPaymentData()
        householdAccountBookViewModel.setIncomeData()
        householdAccountBookViewModel.setSumPaymentData()
        householdAccountBookViewModel.setSumIncomeData()
        householdAccountBookViewModel.paymentTableViewDataSource = []
        householdAccountBookViewModel.incomeTableViewDataSource = []
        householdAccountBookViewModel.setPaymentTableViewDataSourse()
        householdAccountBookViewModel.setIncomeTableViewDataSourse()
        householdAccountBookViewModel.setMonthSumPayment()
        householdAccountBookViewModel.setMonthSumIncome()
        paymentTableView.reloadData()
        sumPaymentTableView.reloadData()
        incomeTableView.reloadData()
        sumIncomeTableView.reloadData()
        resultTableView.reloadData()
        resultSumTableView.reloadData()
        updateChartView()
        updatePaymentPieGraph()
        updateIncomePieGraph()
    }
}
