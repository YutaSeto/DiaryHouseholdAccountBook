//
//  ExpenseItemViewModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/03.
//

import Foundation
import UIKit
import RealmSwift

class ExpenseItemViewModel{
    
    let realm = try! Realm()
    var categoryList:[Category] = []
    var incomeCategoryList:[Category] = []
    var isIncome: Bool?
    var journalList:[Journal] = []
    
    func addNewCategory(value: String,isPayment: Bool){
        let categoryModel = Category()
        try! realm.write{
            categoryModel.name = value
            categoryModel.isPayment = isPayment
            realm.add(categoryModel)
        }
    }
    
    func setJournalList(){
        let result = realm.objects(Journal.self)
        journalList = Array(result)
    }
    
    func overwritePaymentCategory(value:String, indexPath: IndexPath){
        let categoryModel = categoryList[indexPath.row]
        let  changeNamePaymentCategoryList = journalList.filter{$0.category == categoryModel.name}.filter{$0.isPayment == true}
        changeNamePaymentCategoryList.forEach{journal in
            try! realm.write{
                journal.category = value
            }
        }
        try! realm.write{
            categoryModel.name = value
            categoryList[indexPath.row] = categoryModel
        }
    }
    
    func overwriteIncomeCategory(value:String, indexPath: IndexPath){
        let categoryModel = incomeCategoryList[indexPath.row]
        let  changeNameIncomeCategoryList = journalList.filter{$0.category == categoryModel.name}.filter{$0.isPayment == false}
        changeNameIncomeCategoryList.forEach{journal in
            try! realm.write{
                journal.category = value
            }
        }
        try! realm.write{
            categoryModel.name = value
            incomeCategoryList[indexPath.row] = categoryModel
        }
    }
    
    func deleteCategory(targetItem:Category, targetJournal:[Journal], targetBudget:[Budget]){
        try! realm.write{
            realm.delete(targetItem)
            realm.delete(targetJournal)
            realm.delete(targetBudget)
        }
    }
    
    func isValidNameLimit(name: String) -> Bool{
        return name.count >= 8
    }
    
    func isValidTooManyPaymentCategories() -> Bool{
        return realm.objects(Category.self).filter{$0.isPayment == true}.count >= 12
    }
    
    func isValidTooManyIncomeCategories() -> Bool{
        return realm.objects(Category.self).filter{$0.isPayment == false}.count >= 12
    }
    
    func setCategoryData(){
        let result = realm.objects(Category.self).filter{$0.isPayment == true}
        categoryList = Array(result)
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(Category.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
    }
}
