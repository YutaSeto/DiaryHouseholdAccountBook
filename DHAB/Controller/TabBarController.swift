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
        let storyboard = UIStoryboard(name: "CalendarViewController", bundle: nil)
        let calendarViewController = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController
        calendarViewController?.tabBarItem = UITabBarItem(title: "カレンダー", image: UIImage(systemName: "calendar"), tag: 0)
        let calendarNavigationController = UINavigationController(rootViewController: calendarViewController!)
        controllers.append(calendarNavigationController)
        
        let storyboard1 = UIStoryboard(name: "HouseholdAccountBookViewController", bundle: nil)
        let householdAccountBookViewController = storyboard1.instantiateViewController(withIdentifier: "HouseholdAccountBookViewController") as? HouseholdAccountBookViewController
        householdAccountBookViewController!.tabBarItem = UITabBarItem(title: "家計簿", image: UIImage(systemName: "yensign.circle"), tag: 1)
        let householdAccoutBookNavigationController = UINavigationController(rootViewController: householdAccountBookViewController!)
        controllers.append(householdAccoutBookNavigationController)
        
        let storyboard2 = UIStoryboard(name: "DiaryViewController", bundle: nil)
        let diaryViewController = storyboard2.instantiateViewController(withIdentifier: "DiaryViewController") as? DiaryViewController
        diaryViewController!.tabBarItem = UITabBarItem(title: "日記", image: UIImage(systemName: "book"), tag: 2)
        let diaryNavigationController = UINavigationController(rootViewController: diaryViewController!)
        controllers.append(diaryNavigationController)
        
        setViewControllers(controllers, animated: false)
    }
    
    func remakeViewController() {
        let vc = self.viewControllers
        vc!.forEach{
            if let target = $0 as? CalendarViewController{
                target.reloadInputViews()
            }else if let target = $0 as? HouseholdAccountBookViewController{
                target.reloadInputViews()
            }else if let target = $0 as? DiaryViewController{
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
