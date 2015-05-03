//
//  BrickView.swift
//  Breakout
//
//  Created by Jack Huang on 15/3/13.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

import UIKit

class BrickView: UIView {
    
    var isSpecial: Bool = false {
        didSet {
            if isSpecial == true {
                backgroundColor = UIColor.specialColor()
            } else {
                backgroundColor = UIColor.defaultColor()
            }
        }
    }

    override func drawRect(rect: CGRect) {
        UIColor.blackColor().setStroke()
        let outline = UIBezierPath(rect: rect)
        outline.lineWidth = 0.5
        outline.stroke()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.defaultColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

private extension UIColor {
    
    class func randomColor() -> UIColor {
        let colors = [
            UIColor.redColor(),
            UIColor.blueColor(),
            UIColor.yellowColor(),
            UIColor.greenColor(),
            UIColor.purpleColor(),
            UIColor.orangeColor()
        ]
        let i = Int(arc4random() % UInt32(countElements(colors)))
        return colors[i]
    }
    
    class func defaultColor() -> UIColor {
        return UIColor.greenColor()
    }
    
    class func specialColor() -> UIColor {
        return UIColor.cyanColor()
    }
}






