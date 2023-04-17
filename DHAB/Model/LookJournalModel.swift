//
//  LookJournalModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/17.
//

import Foundation
import RealmSwift
import UIKit

class LookJournalModel{
    
    var category:Category?
    var date:Date?
    var journalList:[Journal] = []
    var groupedJournals:[Date:[Journal]] = [:]
    var sortedJournals:[Date:[Journal]] = [:]
    let realm = try! Realm()
    let util = Util()
    var firstDay:Date = Date()
    var lastDay:Date = Date()
    
    func setJournal(){
        journalList = realm.objects(Journal.self).filter{$0.isPayment == self.category!.isPayment}.filter{$0.category == self.category?.name}.filter{$0.date >= self.firstDay.zeroclock}.filter{$0.date < lastDay.zeroclock}
    }
    
    func setDay(){
        firstDay = util.setFirstDay(date: date!.zeroclock)
        lastDay = util.setLastDay(date: date!.zeroclock)
    }
    
    func setGroupedJournals(){
        groupedJournals = Dictionary(grouping: journalList){ journal in
            return Calendar.current.startOfDay(for:journal.date.zeroclock)
        }
    }
    
    func setSortedJournals(){
        sortedJournals = groupedJournals.mapValues{journals in
            return journals.sorted{$0.date > $1.date}
        }
    }
    
    func journalsForSection(_section:Int) -> [Journal]{
        let sectionDate = Array(groupedJournals.keys)[_section]
        return groupedJournals[sectionDate] ?? []
    }
}
