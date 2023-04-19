//
//  ColorViewController.swift
//  DHAB
//
//  Created by setoon on 2023/04/19.
//

import Foundation
import UIKit
import ChameleonFramework

class ColorViewController:UIViewController{
    let colorModel = ColorModel()
    
    let themeColorType = "themeColorType"
    
    @IBOutlet weak var colorTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorTableView.delegate = self
        colorTableView.dataSource = self
        colorTableView.register(UINib(nibName: "ColorTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
    }
    
    func saveThemeColor(type: ColorType){
    }
}

extension ColorViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorModel.colorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ColorTableViewCell
        cell.colorView.backgroundColor = colorModel.colorList[indexPath.row]
        cell.colorLabel.text = colorModel.colorNameList[indexPath.row]
        
        if indexPath.row == UserDefaults.standard.integer(forKey: "themeColorType"){
            cell.checkMark.isHidden = false
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells{
            if let cell = cell as? ColorTableViewCell{
                cell.checkMark.isHidden = true
            }
        }
        let cell = tableView.cellForRow(at: indexPath) as! ColorTableViewCell
        cell.checkMark.isHidden = !cell.checkMark.isHidden
        tableView.deselectRow(at: indexPath, animated: true)
        
        //ユーザーデフォルトに保存
        UserDefaults.standard.setValue(indexPath.row, forKey: themeColorType)
        
        let themeColorTypeInt = UserDefaults.standard.integer(forKey: themeColorType)
        let themeColor = ColorType(rawValue: themeColorTypeInt) ?? .default
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        appearance.backgroundColor = themeColor.color
        
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: themeColor.color, isFlat: true)
    }
    
}