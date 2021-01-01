//
//  ColourConverter.swift
//  Centralis
//
//  Created by AW on 18/12/2020.
//

import UIKit

public class ColourConverter {
    public func colourFromString(_ seed: String) -> UIColor {
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

