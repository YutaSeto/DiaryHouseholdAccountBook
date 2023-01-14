//
//  TabBarController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit

class TabBarController:UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        let names = ["InputViewController","CalendarViewController","HouseholdAccountBookViewController","DiaryViewController","SettingViewController"]
        var viewControllers = [UIViewController]()
        for name in names {
            let storyboard = UIStoryboard(name: name, bundle: nil)
            if let viewController = storyboard.instantiateInitialViewController(){
                viewControllers.append(viewController)
            }
        }
        setViewControllers(viewControllers, animated: false)
        
    }
    
}
