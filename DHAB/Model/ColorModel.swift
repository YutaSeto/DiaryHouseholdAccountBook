//
//  ColorModel.swift
//  DHAB
//
//  Created by setoon on 2023/04/19.
//

import Foundation
import UIKit
import ChameleonFramework

class ColorModel{
    var colorList:[UIColor] = [.flatWhite(),.flatRed(),.flatPink(),.flatOrange(),.flatLime(),.flatGreen(),.flatMint(),.flatSand(),.flatTeal(),.flatBlue(),.flatPowderBlue(),.flatBrown(),.flatGray(),.flatBlack()]
    var colorNameList:[String] = ["ホワイト","レッド","ピンク","オレンジ","ライム","グリーン","ミント","サンド","ターコイズ","ブルー","パウダーブルー","ブラウン","グレー","ブラック"]
}

enum ColorType:Int{
    case `default`
    case red
    case pink
    case orange
    case lime
    case mint
    case blue
    case sand
    case teal
    case powderblue
    case brown
    case green
    case gray
    case black
    
    var color: UIColor{
        switch self{
        case .default: return FlatWhite()
        case .red: return FlatRed()
        case .pink:  return FlatPink()
        case .orange: return FlatOrange()
        case .lime: return FlatLime()
        case .green: return FlatGreen()
        case .mint: return FlatMint()
        case .sand: return FlatSand()
        case .teal: return FlatTeal()
        case .blue: return FlatBlue()
        case .powderblue: return FlatPowderBlue()
        case .brown: return FlatBrown()
        case .gray: return FlatMaroon()
        case .black: return FlatBlack()
        }
    }
}
