//
//  HouseholdAccountBookViewModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/03.
//

import Foundation
import UIKit
import RealmSwift
import Charts

class HouseholdAccountBookViewModel{
    
    let util = Util()
    var date = Date()
    var isMonth = true
    var sumPayment:HouseholdAccountBookTableViewCellItem = HouseholdAccountBookTableViewCellItem()
    var paymentList:[JournalModel] = []
    var paymentBudgetList:[BudgetModel] = []
    var categoryList:[CategoryModel] = []
    var paymentTableViewDataSource: [HouseholdAccountBookTableViewCellItem] = []
    var sumIncome:IncomeTableViewCellItem = IncomeTableViewCellItem()
    var incomeList:[JournalModel] = []
    var incomeBudgetList:[BudgetModel] = []
    var incomeCategoryList:[CategoryModel] = []
    var incomeTableViewDataSource: [IncomeTableViewCellItem] = []
    var targetItem:CategoryModel?
    var targetIndex:IndexPath?
    var targetJournal:[JournalModel]?
    var targetBudget:[BudgetModel]?
    let menuList = ["カテゴリーの設定","予算の設定"]
    var isExpanded:Bool = false
    var sumPaymentList: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
    var sumYearPayment: Int = 0
    var sumIncomeList: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0]
    var sumYearIncome: Int = 0
    let colors:[UIColor] = [.red, .blue, .green, .yellow, .gray, .brown, .cyan, .purple, .orange]
    
    
    func setCategoryData(){
        let realm = try! Realm()
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == true}
        categoryList = Array(result)
    }
    
    func setSumPayment() -> Int{
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        let dayCheck = paymentList.filter({$0.date >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.date < lastDay})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumPaymentBudget() -> Int{
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        let dayCheck = paymentBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.budgetDate < lastDay})
        let sum = dayCheck2.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    
    func setPaymentBudgetData(){
        let realm = try! Realm()
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == true}
        paymentBudgetList = Array(result)
    }
    
    func setSumPaymentData(){
        sumPayment.name = "合計"
        sumPayment.paymentPrice = setSumPayment()
        sumPayment.budgetPrice = sumPaymentBudget()
    }
    
    func setPaymentData(){
        let realm = try! Realm()
        let result = realm.objects(JournalModel.self).filter{$0.isPayment == true}
        paymentList = Array(result)
    }
    
    func setPaymentPieGraphData() -> PieChartData {
        // データの配列を作成する
        var dataEntries:[PieChartDataEntry] = []
        
        //こうすると項目の数が有限になってしまう
        for i in 0 ..< paymentTableViewDataSource.count{
            dataEntries.append(PieChartDataEntry(value: Double(paymentTableViewDataSource[i].paymentPrice), label: paymentTableViewDataSource[i].name))
        }
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "支出")
        dataSet.colors = colors
        dataSet.sliceSpace = 0.0
        let data = PieChartData(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        return data
    }
    
    func setIncomePieGraphData() -> PieChartData {
        // データの配列を作成する
        var dataEntries:[PieChartDataEntry] = []
        
        for i in 0 ..< incomeTableViewDataSource.count{
            dataEntries.append(PieChartDataEntry(value: Double(incomeTableViewDataSource[i].incomePrice), label: incomeTableViewDataSource[i].name))
        }
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "支出")
        dataSet.colors = colors
        let data = PieChartData(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        return data
    }
    
    func setData() -> BarChartData {
        // データの配列を作成する
        
        var barColors: [UIColor] = []
        var dataEntries:[BarChartDataEntry] = []
        for i in 0 ..< 12{
            dataEntries.append(BarChartDataEntry(x: Double(i), y: sumIncomeList[i] - sumPaymentList[i]))
            if sumIncomeList[i] - sumPaymentList[i] <= 0 {
                barColors.append(.red)
            } else {
                barColors.append(.blue)
            }
        }
        
        // データセットを作成する
        let dataSet = BarChartDataSet(entries: dataEntries, label: "収支")
        dataSet.colors = colors
        
        // チャートデータを作成する
        let data = BarChartData(dataSets: [dataSet])
        data.barWidth = 0.6
        
        return data
    }
    
    func setPaymentTableViewDataSourse(){
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        let dayCheckBudget = paymentBudgetList.filter({$0.budgetDate >= firstDay}).filter{$0.budgetDate < lastDay}
        
        let dayCheckPayment = paymentList.filter({$0.date >= firstDay}).filter{$0.date < lastDay}
        categoryList.forEach{ expense in
            if let budget:BudgetModel = dayCheckBudget.filter({$0.expenseID == expense.id}).first{
                let sum = dayCheckPayment.filter{$0.category == expense.name}.map{$0.price}.reduce(0){$0 + $1}
                
                let item = HouseholdAccountBookTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    paymentPrice:sum,
                    budgetPrice: budget.budgetPrice
                )
                paymentTableViewDataSource.append(item)
            } else {
                let sumPayment = dayCheckPayment.filter{$0.category == expense.name}.map{$0.price}.reduce(0, {$0 + $1})
                let data = BudgetModel()
                data.id = UUID().uuidString
                data.expenseID = expense.id
                data.budgetDate = date
                data.budgetPrice = 0
                let realm = try! Realm()
                try! realm.write { realm.add(data)}
                paymentBudgetList.append(data)
                
                let item = HouseholdAccountBookTableViewCellItem(
                    id:data.id,
                    name: expense.name,
                    paymentPrice: sumPayment,
                    budgetPrice: data.budgetPrice
                )
                paymentTableViewDataSource.append(item)
            }
        }
    }
    
    func setSumIncome() -> Int{
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        let dayCheck = incomeList.filter({$0.date >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.date < lastDay})
        let sum = dayCheck2.filter{$0.isPayment == false}.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func sumIncomeBudget() -> Int{
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        let dayCheck = incomeBudgetList.filter({$0.budgetDate >= firstDay})
        let dayCheck2 = dayCheck.filter({$0.budgetDate < lastDay})
        let sum = dayCheck2.filter{$0.isPayment == false}.map{$0.budgetPrice}.reduce(0){$0 + $1}
        return sum
    }
    
    func setIncomeData(){
        let realm = try! Realm()
        let result = realm.objects(JournalModel.self).filter{$0.isPayment == false}
        incomeList = Array(result)
    }
    
    func setIncomeCategoryData(){
        let realm = try! Realm()
        let result = realm.objects(CategoryModel.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
    }
    
    func setIncomeBudgetData(){
        let realm = try! Realm()
        let result = realm.objects(BudgetModel.self).filter{$0.isPayment == false}
        incomeBudgetList = Array(result)
    }
    
    func setSumIncomeData(){
        sumIncome.name = "合計"
        sumIncome.incomePrice = setSumIncome()
        sumIncome.incomeBudget = sumIncomeBudget()
    }
    
    func setIncomeTableViewDataSourse(){
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        let dayCheckBudget = incomeBudgetList.filter({$0.budgetDate >= firstDay}).filter{$0.budgetDate < lastDay}
        
        let dayCheckIncome = incomeList.filter({$0.date >= firstDay}).filter{$0.date < lastDay}
        incomeCategoryList.forEach{ expense in
            if let budget:BudgetModel = dayCheckBudget.filter({$0.expenseID == expense.id}).first{ //予算に入力がある時
                let sum = dayCheckIncome.filter{$0.category == expense.name}.map{$0.price}.reduce(0){$0 + $1}

                let item = IncomeTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    incomePrice:sum,
                    incomeBudget: budget.budgetPrice
                )
                incomeTableViewDataSource.append(item)
            }else{ //予算が入力されていなくて、priceに入力がない時
                let sumPrice = dayCheckIncome.filter{$0.category == expense.name}.map{$0.price}.reduce(0, {$0 + $1})
                let data = BudgetModel()
                data.id = UUID().uuidString
                data.expenseID = expense.id
                data.budgetDate = date
                data.budgetPrice = 0
                let realm = try! Realm()
                try! realm.write { realm.add(data)}
                incomeBudgetList.append(data)

                let item = IncomeTableViewCellItem(
                    id:data.id,
                    name: expense.name,
                    incomePrice: sumPrice,
                    incomeBudget:data.budgetPrice
                )
                incomeTableViewDataSource.append(item)
            }
        }
    }
    
    func setMonthSumPayment(){
        for i in 0 ..< 12{
            let calendar = Calendar(identifier: .gregorian)
            let comps = calendar.dateComponents([.year], from: date)
            let day = calendar.date(from: comps)!
            let addIMonth = DateComponents(month: i)
            let add2Month = DateComponents(month: i + 1)
            let firstDay = calendar.date(byAdding: addIMonth, to: day)?.zeroclock
            let lastDay = calendar.date(byAdding: add2Month, to: day)!.zeroclock
            let dayCheckSumPayment = paymentList.filter({$0.date >= firstDay!})
            let dayCheckSumPayment2 = dayCheckSumPayment.filter({$0.date < lastDay})
            sumPaymentList[i] = Double(Int(dayCheckSumPayment2.map{$0.price}.reduce(0){$0 + $1}))
            sumYearPayment += Int(sumPaymentList[i])
        }
    }
    
    func setMonthSumIncome(){
        for i in 0 ..< 12{
            let calendar = Calendar(identifier: .gregorian)
            let comps = calendar.dateComponents([.year], from: date)
            let day = calendar.date(from: comps)!
            let addIMonth = DateComponents(month: i)
            let add2Month = DateComponents(month: i + 1)
            let firstDay = calendar.date(byAdding: addIMonth, to: day)?.zeroclock
            let lastDay = calendar.date(byAdding: add2Month, to: day)!.zeroclock
            let dayCheckSumPayment = incomeList.filter({$0.date >= firstDay!})
            let dayCheckSumPayment2 = dayCheckSumPayment.filter({$0.date < lastDay})
            sumIncomeList[i] = Double(dayCheckSumPayment2.map{$0.price}.reduce(0){$0 + $1})
            sumYearIncome += Int(sumIncomeList[i])
        }
    }
    
    
    func resetSumYearPaymentAndIncome(){
        sumYearPayment = 0
        sumYearIncome = 0
    }
    
}
