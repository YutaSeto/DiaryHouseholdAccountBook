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
    let tabBarModel = TabBarModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarModel.setFirstCategory()
        tabBarModel.configureBackgroundColor()
        controllers = tabBarModel.initTab()
        setViewControllers(controllers, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewDidLoad()
    }
    
    
    func remakeViewController() {
        print(" デリゲートが機能しました")
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
