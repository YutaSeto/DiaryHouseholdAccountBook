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
        let names = ["CalendarViewController","HouseholdAccountBookViewController","DiaryViewController"]
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
