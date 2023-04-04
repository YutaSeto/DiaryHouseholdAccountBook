//
//  CalendarModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/03.
//

import Foundation
import UIKit
import RealmSwift

class CalendarViewModel{
    
    let util = Util()
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
    var monthPaymentModelList:[JournalModel] = []
    var displayPaymentList:[JournalModel] = []
    var monthIncomeModelList:[JournalModel] = []
    var displayIncomeList:[JournalModel] = []
    var diaryModelList:[DiaryModel] = []
    var incomeModelList:[JournalModel] = []
    var displayJournalList:[JournalModel] = []
    

    
    func setMonthPaymentModelList(){
        let firstDay = util.setFirstDay(date: selectedDate)
        let lastDay = util.setLastDay(date: selectedDate)
        let paymentList:[JournalModel] = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay}.filter{$0.isPayment == true}
        monthPaymentModelList = paymentList
    }
    
    func setMonthIncomeModelList(){
        let firstDay = util.setFirstDay(date: selectedDate)
        let lastDay = util.setLastDay(date: selectedDate)
        let incomeList:[JournalModel] = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay}.filter{$0.isPayment == false}
        monthIncomeModelList = incomeList
    }
    
    func setMonthPayment()-> Int{
        let firstDay = util.setFirstDay(date: selectedDate)
        let lastDay = util.setLastDay(date: selectedDate)
        
        var sum:Int = 0
        let paymentList = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay}.filter{$0.isPayment == true}
        paymentList.forEach{payment in
            sum += payment.price
        }
        return sum
    }
    
    func setMonthIncome()-> Int{
        let firstDay = util.setFirstDay(date: selectedDate)
        let lastDay = util.setLastDay(date: selectedDate)
        
        var sum:Int = 0
        let incomeList = realm.objects(JournalModel.self).filter{($0.date >= firstDay)}.filter{$0.date <= lastDay}.filter{$0.isPayment == false}
        incomeList.forEach{income in
            sum += income.price
        }
        return sum
    }
    
    func setSumPayment() -> Int{
        let firstDay = util.setFirstDay(date: selectedDate)
        let lastDay = util.setLastDay(date: selectedDate)
        let dayCheck = displayPaymentList.filter({$0.date >= (firstDay)}).filter{$0.isPayment == true}
        let dayCheck2 = dayCheck.filter({$0.date <= lastDay.zeroclock})
        let sum = dayCheck2.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func setSumIncome() -> Int{
        let firstDay = util.setFirstDay(date: selectedDate)
        let lastDay = util.setLastDay(date: selectedDate)
        let dayCheck = displayIncomeList.filter({$0.date >= firstDay}).filter{$0.date <= lastDay}
        let sum = dayCheck.map{$0.price}.reduce(0){$0 + $1}
        return sum
    }
    
    func setTableView(){
        var result:[JournalModel] = []
        let paymentList = realm.objects(JournalModel.self).sorted(byKeyPath: "date",ascending: false).filter{$0.isPayment == true}
        paymentList.forEach{payment in
            if payment.date.zeroclock == selectedDate.zeroclock{
                result.append(payment)
            }
        }
        displayPaymentList = result
    }
    
    func setDisplayJournalList(){
        var result:[JournalModel] = []
        let journalList = realm.objects(JournalModel.self).sorted(byKeyPath: "date",ascending: false)
        journalList.forEach{journal in
            if journal.date.zeroclock == selectedDate.zeroclock{
                result.append(journal)
            }
        }
        displayJournalList = result
    }
    
    func setDiaryTableView()-> [DiaryModel]{
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
    }
    
    func deleteHouseholdAccountBookTableViewCell(tableView: UITableView, indexPath: IndexPath){
        let targetItem = displayJournalList[indexPath.row]
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
    }
    
    func deleteDiaryTableViewCell(tableView: UITableView, indexPath: IndexPath){
        let targetItem = setDiaryTableView()[indexPath.row]
        if let index = diaryModelList.firstIndex(where: {$0.id == targetItem.id}){
            diaryModelList.remove(at: index)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
        try! realm.write{
            realm.delete(targetItem)
        }
    }
    
    func removePaymentAddIncome(tableView: UITableView){
        displayJournalList.remove(at: deleteIndexPath.row)
        tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        let index:Int = monthPaymentModelList.firstIndex(where: {$0.id == payment!.id})!
        monthPaymentModelList.remove(at: index)
        displayIncomeList.append(payment!)
        monthIncomeModelList.append(payment!)
        tableView.reloadData()
        payment = nil
        income = nil
    }
    
    func removeIncomeAddPayment(tableView: UITableView){
        displayJournalList.remove(at: deleteIndexPath.row)
        tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
        let index:Int = monthIncomeModelList.firstIndex(where: {$0.id == income!.id})!
        monthIncomeModelList.remove(at: index)
        displayPaymentList.append(income!)
        monthPaymentModelList.append(income!)
        tableView.reloadData()
        payment = nil
        income = nil
    }
    
    func setSumPaymentForCalendarCell(date:Date) -> String{
        return util.getComma(realm.objects(JournalModel.self).filter{$0.isPayment == true}.filter{$0.date.zeroclock == date.zeroclock}.map{$0.price}.reduce(0){$0 + $1})
    }
    
    func setSumIncomeForCalendarCell(date:Date) -> String{
        util.getComma(realm.objects(JournalModel.self).filter{$0.isPayment == false}.filter{$0.date.zeroclock == date.zeroclock}.map{$0.price}.reduce(0){$0 + $1})
    }
    
    
}
