//
//  Color.swift
//  DHAB
//
//  Created by setoon on 2023/04/19.
//

import Foundation
import ChameleonFramework

enum ColorType{
    case `default`
    case red
    case pink
    case orange
    case plum
    case lime
    case mint
    case blue
    case sand
    case teal
    case powderblue
    case brown
    case green
    case maroon
    case coffee
    
    var color: UIColor{
        switch self{
        case .default: return.white
        case .red: return FlatRed()
        case .pink:  return FlatPink()
        case .orange: return FlatOrange()
        case .plum: return FlatPlum()
        case .lime: return FlatLime()
        case .mint: return FlatMint()
        case .blue: return FlatBlue()
        case .sand: return FlatSand()
        case .teal: return FlatTeal()
        case .powderblue: return FlatPowderBlue()
        case .brown: return FlatBrown()
        case .green: return FlatGreen()
        case .maroon: return FlatMaroon()
        case .coffee: return FlatCoffee()
        }
    }
    
    var subColor: UIColor{
        switch self{
        case .default: return.white
        case .red: return FlatRed().lighten(byPercentage: 0.5)
        case .pink:  return FlatPink().lighten(byPercentage: 0.5)
        case .orange: return FlatOrange().lighten(byPercentage: 0.5)
        case .plum: return FlatPlum().lighten(byPercentage: 0.5)
        case .lime: return FlatLime().lighten(byPercentage: 0.5)
        case .mint: return FlatMint().lighten(byPercentage: 0.5)
        case .blue: return FlatBlue().lighten(byPercentage: 0.5)
        case .sand: return FlatSand().lighten(byPercentage: 0.5)
        case .teal: return FlatTeal().lighten(byPercentage: 0.5)
        case .powderblue: return FlatPowderBlue().lighten(byPercentage: 0.5)
        case .brown: return FlatBrown().lighten(byPercentage: 0.5)
        case .green: return FlatGreen().lighten(byPercentage: 0.5)
        case .maroon: return FlatMaroon().lighten(byPercentage: 0.5)
        case .coffee: return FlatCoffee().lighten(byPercentage: 0.5)
        }
    }
}
