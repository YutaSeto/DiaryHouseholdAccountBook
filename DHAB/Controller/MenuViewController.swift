//
//  MenuViewController2.swift
//  DHAB
//
//  Created by setoon on 2023/01/18.
//

import UIKit

class MenuViewController: UIViewController {
    
    let menuList = ["カテゴリーの設定","予算の設定"]
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let menuPos = menuView.layer.position
        self.menuView.layer.position.x = UIScreen.main.bounds.width + self.menuView.frame.width
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
                returnView()
            }
        }
    }
    // Do any additional setup after loading the view.
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
    
    func returnView(){
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations:  {
                self.menuView.layer.position.x = UIScreen.main.bounds.width + self.menuView.frame.width
            },
            completion: { bool in
                self.dismiss(animated: true, completion: nil)
            }
        )
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            let storyboard = UIStoryboard(name: "ExpenseItemViewController", bundle: nil)
            let expenseItemViewController = storyboard.instantiateViewController(withIdentifier: "ExpenseItemViewController")
            present(expenseItemViewController,animated: true)
            returnView()
        case 1:
            let storyboard = UIStoryboard(name: "BudgetViewController", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            present(navigationController,animated: true)
            returnView()
        default:
            return
        }
    }
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


