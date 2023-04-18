//
//  NotificationViewController.swift
//  DHAB
//
//  Created by setoon on 2023/04/17.
//

import Foundation
import UIKit
import UserNotifications

class NotificationViewController:UIViewController{
    
    let notificationModel = NotificationModel()
    let util = Util()
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    var toolbar: UIToolbar{
        let toolbarRect = CGRect(x: 0,y: 0, width:view.frame.size.width,height: 35)
        let toolbar = UIToolbar(frame: toolbarRect)
        let doneItem = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(didTapFinishButton))
        toolbar.setItems([doneItem], animated: modalPresentationCapturesStatusBarAppearance)
        return toolbar
    }
    
    @IBOutlet weak var notificationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var daylyOrWeeklySegmentedControl: UISegmentedControl!
    @IBOutlet weak var weekdaySegmentedControl: UISegmentedControl!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker()
    }
    
    @objc func didTapFinishButton(){
        view.endEditing(true)
    }
    
    func configureDatePicker(){
        let datePicker = notificationModel.datePicker
        let targetDate = Date()
        datePicker.date = targetDate
        timeTextField.inputView = datePicker
        timeTextField.text = util.timeDateFormatter.string(from: targetDate)
        timeTextField.inputAccessoryView = toolbar
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
    }
    
    @objc func didChangeDate(picker: UIDatePicker){
        notificationModel.date = picker.date
        timeTextField.text = util.timeDateFormatter.string(from: picker.date)
    }
}
