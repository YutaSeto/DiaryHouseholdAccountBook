//
//  TabBarController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift
import ChameleonFramework

class TabBarController:UITabBarController, UITabBarControllerDelegate{
    
    @IBOutlet weak var tabMenuBar: UITabBar!
    var controllers:[UIViewController] = []
    let tabBarModel = TabBarModel()
    var colorDelegate:ChangeTabBarColorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBarModel.setFirstCategory()
        controllers = tabBarModel.initTab()
        setViewControllers(controllers, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedIndex = 0
        self.tabBarController(self, didSelect: self.selectedViewController!)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController){
            let selectedColor:UIColor = themeColor.color
            let unselectedColor:UIColor = .systemGray2
            viewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:selectedColor], for: .selected)
            viewController.tabBarItem.image = viewController.tabBarItem.image?.withTintColor(selectedColor, renderingMode: .alwaysOriginal)
            for tabBarItem in tabBarController.tabBar.items ?? []{
                if tabBarController.tabBar.items?.firstIndex(of: tabBarItem) != index{
                    tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:unselectedColor], for: .normal)
                    tabBarItem.image = tabBarItem.image?.withTintColor(unselectedColor,renderingMode: .alwaysOriginal)
                }
            }
            
            if viewController is HouseholdAccountBookViewController{
                let storyboard = UIStoryboard(name: "HouseholdAccountBookViewController", bundle: nil)
                guard let householdAccountBookViewController = storyboard.instantiateViewController(withIdentifier: "HouseholdAccountBookViewController") as? HouseholdAccountBookViewController else {return}
                householdAccountBookViewController.colorDelegate = self
            }
        }
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

extension TabBarController:ChangeTabBarColorDelegate{
    func changeTabBarColor(_ tabBarController: UITabBarController,viewController: UIViewController) {
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController){
            let selectedColor:UIColor = themeColor.color
            let unselectedColor:UIColor = .systemGray2
            viewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:selectedColor], for: .selected)
            viewController.tabBarItem.image = viewController.tabBarItem.image?.withTintColor(selectedColor, renderingMode: .alwaysOriginal)
            for tabBarItem in tabBarController.tabBar.items ?? []{
                if tabBarController.tabBar.items?.firstIndex(of: tabBarItem) != index{
                    tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:unselectedColor], for: .normal)
                    tabBarItem.image = tabBarItem.image?.withTintColor(unselectedColor,renderingMode: .alwaysOriginal)
                }
            }
        }
    }
}
