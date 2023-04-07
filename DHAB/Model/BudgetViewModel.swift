//
//  BudgetViewController.swift
//  DHAB
//
//  Created by setoon on 2023/04/03.
//

import Foundation
import UIKit
import RealmSwift

class BudgetViewModel{
    
    var date = Date()
    var categoryList:[Category] = []
    var incomeCategoryList:[Category] = []
    var paymentBudgetList:[Budget] = []
    var incomeBudgetList:[Budget] = []
    var budgetTableViewDataSource: [BudgetTableViewCellItem] = []
    var incomeBudgetTableViewDataSource: [IncomeBudgetTableViewCellItem] = []
    
    let util = Util()
    let realm = try! Realm()
    
    func setCategoryData(){
        let result = realm.objects(Category.self).filter{$0.isPayment == true}
        categoryList = Array(result)
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(Category.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
    }
    
    func setPaymentBudgetData(){
        let result = realm.objects(Budget.self).filter{$0.isPayment == true}
        paymentBudgetList = Array(result)
    }
    
    func setIncomeBudgetData(){
        let result = realm.objects(Budget.self).filter{$0.isPayment == false}
        incomeBudgetList = Array(result)
    }
    
    func setBudgetTableViewDataSourse(){
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        categoryList.forEach{ expense in
            let dayCheckBudget = self.paymentBudgetList.filter({$0.budgetDate >= firstDay}).filter({$0.budgetDate <= lastDay})
            if let budget:Budget = dayCheckBudget.filter({$0.expenseID == expense.id}).first{
                let item = BudgetTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                budgetTableViewDataSource.append(item)
            } else {
                let budget = Budget()
                budget.id = UUID().uuidString
                budget.expenseID = expense.id
                budget.budgetDate = date.zeroclock
                budget.isPayment = true
                budget.budgetPrice = 0
                try! realm.write { realm.add(budget)}
                paymentBudgetList.append(budget)
                
                let item = BudgetTableViewCellItem(
                    id:budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                budgetTableViewDataSource.append(item)
            }
        }
    }
    
    func setIncomeBudgetTableViewDataSourse(){
        let firstDay = util.setFirstDay(date: date)
        let lastDay = util.setLastDay(date: date)
        incomeCategoryList.forEach{ expense in
            let dayCheckBudget = self.incomeBudgetList.filter({$0.budgetDate >= firstDay}).filter{$0.budgetDate <= lastDay}
            if let budget:Budget = dayCheckBudget.filter({$0.expenseID == expense.id}).filter({$0.isPayment == false}).first{
                let item = IncomeBudgetTableViewCellItem(
                    id: budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                incomeBudgetTableViewDataSource.append(item)
            } else {
                let budget = Budget()
                budget.id = UUID().uuidString
                budget.expenseID = expense.id
                budget.budgetDate = date.zeroclock
                budget.isPayment = false
                budget.budgetPrice = 0
                try! realm.write { realm.add(budget)}
                incomeBudgetList.append(budget)
                
                let item = IncomeBudgetTableViewCellItem(
                    id:budget.id,
                    name: expense.name,
                    price: budget.budgetPrice
                )
                incomeBudgetTableViewDataSource.append(item)
            }
        }
    }
}
