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
    case green
    case mint
    case sand
    case teal
    case blue
    case powderblue
    case brown
    case gray
    case black
    
    var color: UIColor{
        switch self{
        case .default: return FlatWhite()
        case .red: return FlatRed()//問題あり
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
        case .gray: return FlatGray()
        case .black: return FlatBlack()
        }
        
    }
    
    var darkColor: UIColor{
        switch self{
        case .default: return FlatWhiteDark()
        case .red: return FlatRedDark()//問題あり
        case .pink:  return FlatPinkDark()
        case .orange: return FlatOrangeDark()
        case .lime: return FlatLimeDark()
        case .green: return FlatGreenDark()
        case .mint: return FlatMintDark()
        case .sand: return FlatSandDark()
        case .teal: return FlatTealDark()
        case .blue: return FlatBlueDark()
        case .powderblue: return FlatPowderBlueDark()
        case .brown: return FlatBrownDark()
        case .gray: return FlatGrayDark()
        case .black: return FlatBlackDark()
        }
    }
}
