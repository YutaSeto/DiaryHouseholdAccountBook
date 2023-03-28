//
//  TabBarController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift

class TabBarController:UITabBarController, UITabBarControllerDelegate{
    
    @IBOutlet weak var tabMenuBar: UITabBar!
    var controllers:[UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "hasLaunchedBefore"){
            userDefaults.set(true, forKey: "hasLaunchedBefore")
            let realm = try! Realm()
            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "食費"
                category.isPayment = true
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "日用品"
                category.isPayment = true
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "交通費"
                category.isPayment = true
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "光熱費"
                category.isPayment = true
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "交際費"
                category.isPayment = true
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "その他"
                category.isPayment = true
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "給料"
                category.isPayment = false
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "賞与"
                category.isPayment = false
                realm.add(category)
            }

            try! realm.write{
                let category = CategoryModel()
                category.id = NSUUID().uuidString
                category.name = "その他"
                category.isPayment = false
                realm.add(category)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewDidLoad()
        initTab()
    }
    
    
    func configureBackgroundColor(){
        UITabBar.appearance().backgroundColor = UIColor.lightGray
    }
    
    func initTab(){
        
        let storyboard1 = UIStoryboard(name: "CalendarViewController", bundle: nil)
        if let calendarViewController = storyboard1.instantiateInitialViewController(){
            calendarViewController.tabBarItem = UITabBarItem(title: "カレンダー", image: UIImage(systemName: "calendar"), tag: 0)
            controllers.append(calendarViewController)
        }
        
        let storyboard2 = UIStoryboard(name: "HouseholdAccountBookViewController", bundle: nil)
        if let householdAccountBookViewController = storyboard2.instantiateInitialViewController(){
            householdAccountBookViewController.tabBarItem = UITabBarItem(title: "家計簿", image: UIImage(systemName: "yensign.circle"), tag: 1)
            controllers.append(householdAccountBookViewController)
        }
        
        let storyboard3 = UIStoryboard(name: "DiaryViewController", bundle: nil)
        if let diaryViewController = storyboard3.instantiateInitialViewController(){
            diaryViewController.tabBarItem = UITabBarItem(title: "日記", image: UIImage(systemName: "book"), tag: 2)
            controllers.append(diaryViewController)
        }
        
        setViewControllers(controllers, animated: false)
    }
    
    func remakeViewController() {
        print("デリゲートが実行")
        let vc = self.viewControllers
        vc!.forEach{
            if let target = $0 as? CalendarViewController{
                print("カレンダーをリロード")
                target.reloadInputViews()
            }else if let target = $0 as? HouseholdAccountBookViewController{
                print("家計簿をリロード")
                target.reloadInputViews()
            }else if let target = $0 as? DiaryViewController{
                print("日記をリロード")
                target.reloadInputViews()
            }
        }
    }

}

extension TabBarController:InputViewControllerDelegate{
    func changeFromPaymentToIncome() {
        return
    }
    
    func changeFromIncomeToPayment() {
        return
    }
    
    func didReceiveNotification() {
        return
    }
    
    func updatePayment() {
        return
    }
    func updateDiary() {
        return
    }
    
    func updateCalendar() {
        return
    }
    
    func updateIncome() {
        return
    }
    
    func inputViewController(_ viewController: InputViewController, didUpdateData data: String) {
        return
    }
}
