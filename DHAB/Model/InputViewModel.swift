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
    
    func addNewJournal(priceText:String,memoText:String,result:String){
        let text = priceText
        let realm = try! Realm()
        do{
            try realm.write{
                let journalModel = try Journal(price:Int(text)!,memo: memoText, category: result)
                journalModel.date = date
                journalModel.price = Int(text)!
                journalModel.category = result
                journalModel.isPayment = isPayment
                journalModel.memo = memoText
                realm.add(journalModel)
            }
            RecognitionChange.shared.updateCalendar = true
        }catch Journal.ValidationError.invalidPriceLimit{
            showPriceAlert()
        }catch Journal.ValidationError.invalidMemoLimit{
            showMemoAlert()
        }catch{
            print("エラーが発生")
        }
    }
    
    func showPriceAlert(){
        let alert = UIAlertController(title:"1億円以内で入力してください", message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(cancel)
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func showMemoAlert(){
        let alert = UIAlertController(title:"メモは10文字以内で入力してください", message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title:"キャンセル", style: .default, handler:{(action) -> Void in
            return
        })
        
        alert.addAction(cancel)
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func OverwriteJournal(priceText:String,result:String,memoText:String){
        do{
            let text = priceText
            try realm.write{
                journal?.date = date
                journal?.isPayment = isPayment
                if let price = Int(text),
                   price < 100000000{
                    journal?.price = price
                }else{
                    throw Journal.ValidationError.invalidPriceLimit
                }
                journal?.price = Int(text)!
                journal?.category = result
                if memoText.count <= 10{
                    journal?.memo = memoText
                }else{
                    throw Journal.ValidationError.invalidMemoLimit
                }
            }
        }catch Journal.ValidationError.invalidPriceLimit{
            showPriceAlert()
        }catch Journal.ValidationError.invalidMemoLimit{
            showMemoAlert()
        }catch{
            print("エラーが発生")
        }
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
