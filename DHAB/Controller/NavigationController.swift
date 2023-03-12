//
//  NavigationController.swift
//  DHAB
//
//  Created by 瀬戸雄太 on 2023/03/07.
//

import Foundation
import UIKit

class NavigationController:UINavigationController{
    var date:Date?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let budgetViewController = BudgetViewController()
//        budgetViewController.date = date!
//        self.present(budgetViewController,animated: true)
    }
}
