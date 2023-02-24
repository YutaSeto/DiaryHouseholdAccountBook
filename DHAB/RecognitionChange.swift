//
//  RecognitionChange.swift
//  DHAB
//
//  Created by setoon on 2023/02/24.
//

import Foundation
import UIKit
import RealmSwift

final public class RecognitionChange{
    
    var updateCalendar:Bool = false
    
    public static let shared = RecognitionChange()
    
    private init(){}
}
