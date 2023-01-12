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
    //subView関連
    @IBOutlet var householdAccountBookView: UIView!
    @IBOutlet var diaryView: UIView!
    func addHouseholdAccountView(){
        diaryView.removeFromSuperview()
        self.view.addSubview(householdAccountBookView)
    }
    func addDiaryView(){
        householdAccountBookView.removeFromSuperview()
        self.view.addSubview(diaryView)
    }
    
    func settingSubView(){
        householdAccountBookView.frame = CGRect(x: 0,
                                         y: viewChangeSegmentedControl.frame.minY + viewChangeSegmentedControl.frame.height,
                                         width: self.view.frame.width,
                                         height: (self.view.frame.height - viewChangeSegmentedControl.frame.minY))
                diaryView.frame = CGRect(x: 0,
                                          y: viewChangeSegmentedControl.frame.minY + viewChangeSegmentedControl.frame.height,
                                          width: self.view.frame.width,
                                          height: (self.view.frame.height - viewChangeSegmentedControl.frame.minY))
    }
    
    //segmentedControll関連
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
        addHouseholdAccountView()
        settingSubView()
        dateLabel.text = dateFormatter.string(from:Date())
    }
    
    //家計簿記入画面関連
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja-JP")
        return dateFormatter
    }
    
    var paymentList = ["食費","衣類","通信費","保険"]
    
    
}
