//
//  LookJournalViewController.swift
//  DHAB
//
//  Created by setoon on 2023/04/17.
//

import Foundation
import UIKit

class LookJournalViewController:UIViewController{
    
    let util = Util()
    let lookJournalModel = LookJournalModel()
    
    @IBOutlet weak var journalTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journalTableView.register(UINib(nibName: "BudgetTableViewCell", bundle: nil),forCellReuseIdentifier: "cell")
        lookJournalModel.setDay()
        lookJournalModel.setJournal()
        lookJournalModel.setGroupedJournals()
        lookJournalModel.setSortedJournals()
        journalTableView.delegate = self
        journalTableView.dataSource = self
    }
}

extension LookJournalViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitles = lookJournalModel.sortedJournals.keys.sorted(by:>)
        let sectionDate = sectionTitles[section]
        return lookJournalModel.sortedJournals[sectionDate]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = journalTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BudgetTableViewCell
        let item = lookJournalModel.journalsForSection(_section: indexPath.section)[indexPath.row]
        cell.budgetCategoryLabel.text = item.category
        cell.budgetPriceLabel.text = util.getComma(item.price)
        cell.memoLabel.text = item.memo
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lookJournalModel.sortedJournals.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedKeys = Array(lookJournalModel.sortedJournals.keys).sorted(by: >)
        let date = sortedKeys[section]
        return util.dayDateFormatter.string(from: date)
    }
}
