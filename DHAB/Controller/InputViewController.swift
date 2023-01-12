//
//  InputViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift

class InputViewController:UIViewController{
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    
    @IBAction func viewChangeSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            addHouseholdAccountView()
        case 1:
            addDiaryView()
        default:
            return
        }
    }
   
    override func viewDidLoad(){
        super.viewDidLoad()
        
        householdAccountBookView.frame = CGRect(x: 0,
                                         y: viewChangeSegmentedControl.frame.minY + viewChangeSegmentedControl.frame.height,
                                         width: self.view.frame.width,
                                         height: (self.view.frame.height - viewChangeSegmentedControl.frame.minY))
                diaryView.frame = CGRect(x: 0,
                                          y: viewChangeSegmentedControl.frame.minY + viewChangeSegmentedControl.frame.height,
                                          width: self.view.frame.width,
                                          height: (self.view.frame.height - viewChangeSegmentedControl.frame.minY))
    }
    
    func addHouseholdAccountView(){
        diaryView.removeFromSuperview()
        self.view.addSubview(householdAccountBookView)
    }
    
    func addDiaryView(){
        householdAccountBookView.removeFromSuperview()
        self.view.addSubview(diaryView)
    }

    
}
