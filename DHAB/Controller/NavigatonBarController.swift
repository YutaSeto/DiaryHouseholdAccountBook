//
//  NavigatonBarController.swift
//  DHAB
//
//  Created by 瀬戸雄太 on 2023/04/29.
//

import Foundation
import UIKit

class NavigationBarController:UINavigationController{
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: "themeColorType")
        if themeColorTypeInt == 0 || themeColorTypeInt == 2 || themeColorTypeInt == 5 || themeColorTypeInt == 7 || themeColorTypeInt == 8 || themeColorTypeInt == 10 || themeColorTypeInt == 12{
            return .lightContent
        } else {
            return .darkContent
        }
    }
}

class StatusBarStyle {
    static let shared = StatusBarStyle()
    private init() { }
    var style: UIStatusBarStyle = .default
}
