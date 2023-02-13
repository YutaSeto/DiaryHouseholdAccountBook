//
//  TabBarController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit

class TabBarController:UITabBarController, UITabBarControllerDelegate{
    
    @IBOutlet weak var tabMenuBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.viewDidLoad()

        initTab()
        
    }
    
    func initTab(){
        var controllers:[UIViewController] = []
        
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
}
