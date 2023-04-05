//
//  InputViewModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/03.
//

import Foundation
import UIKit
import RealmSwift

class InputViewModel{
    
    var journal:Journal? = nil
    var category:String = ""
    var isPayment:Bool = true
    let realm = try! Realm()
    var categoryList:[Category] = []
    var incomeCategoryList:[Category] = []
    var date:Date = Date()
    var datePicker:UIDatePicker{
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(identifier: "Asia/tokyo")
//        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ja-JP")
        return datePicker
    }
    var isDiary:Bool = false
    var diary:Diary?
    var selectedIndex:Int?
    var imageArray:[Data] = []
    var currentIndex = 0
    var diaryModel = Diary()
    var diaryList:[Diary] = []
    
    
    func setCategoryData(){
        let result = realm.objects(Category.self).filter{$0.isPayment == true}
        categoryList = Array(result)
    }
    
    func setIncomeCategoryData(){
        let result = realm.objects(Category.self).filter{$0.isPayment == false}
        incomeCategoryList = Array(result)
    }
    
    func addNewJournal(priceText:Int, expenseItem: String, memo:String){
        try! realm.write{
            let journal = Journal()
            journal.date = date
            journal.price = priceText
            journal.category = expenseItem
            journal.isPayment = isPayment
            journal.memo = memo
            realm.add(journal)
        }
    }
    
    func overwriteJournal(price:Int,result:String, memo:String){
        try! realm.write{
            journal?.date = date
            journal?.isPayment = isPayment
            journal?.price = price
            journal?.price = price
            journal?.category = result
            journal?.memo = memo
        }
    }
    
    func isValidPrice(price:Int) ->Bool{
        return price > 100000000
    }
    
    func isValidMemoLimit(memo: String) -> Bool{
        return memo.count > 10
    }
    
    func addNewDiary(titleText:String,diaryText:String){
        let realm = try! Realm()
        try! realm.write{
            diaryModel.date = date.zeroclock
            diaryModel.title = titleText
            diaryModel.text = diaryText
            diaryModel.pictureList.append(objectsIn: imageArray)
            realm.add(diaryModel)
        }
    }
    
    func overwriteDiary(titleText:String,diaryText:String){
        let realm = try! Realm()
        try! realm.write{
            diary!.pictureList.removeAll()
            diary!.date = date.zeroclock
            diary!.title = titleText
            diary!.text = diaryText
            diary!.pictureList.append(objectsIn: imageArray)
        }
    }
    
    func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        var transform = CGAffineTransform.identity

        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: (image.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (image.cgImage?.colorSpace!)!, bitmapInfo: (image.cgImage?.bitmapInfo.rawValue)!)

        ctx?.concatenate(transform)

        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }

        if let cgImage = ctx?.makeImage() {
            return UIImage(cgImage: cgImage)
        } else {
            return image
        }
    }
    
    
}
