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
        case .red: return FlatRedDark()
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
    
    var lightColor: UIColor{
        switch self{
        case .default:
            let color = UIColor.init(displayP3Red: 0.931, green: 0.9462, blue: 0.95, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .red:
            let color = UIColor.init(displayP3Red: 0.91 * 0.9, green: 0.30394 * 0.9, blue: 0.2366 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .pink:
            let color = UIColor.init(displayP3Red: 0.96 * 0.9, green: 0.4896 * 0.9, blue: 0.77184 * 0.9, alpha: 1.0)
            
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .orange:
            let color = UIColor.init(displayP3Red: 0.9 * 0.9, green: 0.492 * 0.9, blue: 0.135 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .lime:
            let color = UIColor.init(displayP3Red: 0.6526 * 0.9, green: 0.78 * 0.9, blue: 0.234 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .green:
            let color = UIColor.init(displayP3Red: 0.184 * 0.9, green: 0.8 * 0.9, blue: 0.440667 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .mint:
            let color = UIColor.init(displayP3Red: 0.1036 * 0.9, green: 0.74 * 0.9, blue: 0.61272 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .sand:
            let color = UIColor.init(displayP3Red: 0.94 * 0.9, green: 0.8695 * 0.9, blue: 0.705 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .teal:
            let color = UIColor.init(displayP3Red: 0.2295 * 0.9, green: 0.439875 * 0.9, blue: 0.51 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .blue:
            let color = UIColor.init(displayP3Red: 0.315 * 0.9, green: 0.399 * 0.9, blue: 0.63 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .powderblue:
            let color = UIColor.init(displayP3Red: 0.722 * 0.9, green: 0.7904 * 0.9, blue: 0.95 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .brown:
            let color = UIColor.init(displayP3Red: 0.37 * 0.9, green: 0.2701 * 0.9, blue: 0.2035 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .gray:
            let color = UIColor.init(displayP3Red: 0.585 * 0.9, green: 0.645667 * 0.9, blue: 0.65 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        case .black:
            let color = UIColor.init(displayP3Red: 0.585 * 0.9, green: 0.645667 * 0.9, blue: 0.65 * 0.9, alpha: 1.0)
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            alpha *= 0.5
            return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
    }
}
