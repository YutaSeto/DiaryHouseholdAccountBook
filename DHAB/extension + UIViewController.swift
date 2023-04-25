//
//  extension + UIViewController.swift
//  DHAB
//
//  Created by setoon on 2023/04/07.
//

import Foundation
import UIKit

extension UIViewController {    
    private final class StatusBarView: UIView { }

    func setStatusBarBackgroundColor(color: UIColor?) {
        for subView in self.view.subviews where subView is StatusBarView {
            subView.removeFromSuperview()
        }
        guard let color = color else {
            return
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.shadowColor = color
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
    }
}

