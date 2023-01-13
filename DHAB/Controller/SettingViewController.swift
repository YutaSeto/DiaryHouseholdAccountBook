//
//  SettingViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/12.
//

import Foundation
import UIKit
import RealmSwift

class SettingViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var settingTableView: UITableView!
        
    var paymentList = [(String)]()
    var settingList = ["費目の設定","予算の設定","通知の設定"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = settingList[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            return
        case 1:
            return
        case 2:
            return
        default:
            return
        }
    }
}
