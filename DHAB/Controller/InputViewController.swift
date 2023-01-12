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
    
    @IBOutlet weak var viewChangeSegmentedControl: UISegmentedControl!
    
    @IBAction func viewChangeSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            print("家計簿が選ばれました")
        case 1:
            print("日記が選ばれました")
        default:
            return
        }
    }
  
   
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    


}
