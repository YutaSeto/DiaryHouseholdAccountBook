//
//  menuViewController.swift
//  DHAB
//
//  Created by setoon on 2023/01/18.
//

import Foundation
import UIKit

class MenuViewController: UIViewController{
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    
    let menuList = ["予算の設定","カテゴリーの設定"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let menuPos = menuView.layer.position
        self.menuView.layer.position.x = -self.menuView.frame.width
        UIView.animate(
            withDuration: 0.5,
            delay:0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
            },
            completion: { bool in
            })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches{
            if touch.view?.tag == 1{
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: .curveEaseIn,
                    animations:  {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                    },
                    completion: { bool in
                        self.dismiss(animated: true, completion: nil)
                    }
                )
            }
        }
    }
}

extension MenuViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = menuList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            let storyboard = UIStoryboard(name: "ExpenceItemViewController", bundle: nil)
            guard let expenceItemViewController = storyboard.instantiateInitialViewController() as? ExpenceItemViewController else {return}
            present(expenceItemViewController,animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
            guard let budgetViewController = storyboard.instantiateInitialViewController() as? BudgetViewController else {return}
            present(budgetViewController,animated: true)
        default:
            return
        }
    }
}
