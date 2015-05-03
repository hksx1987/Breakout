//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Jack Huang on 15/3/12.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    // collision for all game elements
    lazy var collision: UICollisionBehavior = {
        let c = UICollisionBehavior()
        c.collisionMode = .Boundaries
        return c
        }()
    
    lazy var elementBehavior: UIDynamicItemBehavior = {
        let lazilyElemBehavior = UIDynamicItemBehavior()
        lazilyElemBehavior.elasticity = 1
        lazilyElemBehavior.resistance = 0
        lazilyElemBehavior.friction = 0
        lazilyElemBehavior.allowsRotation = false
        return lazilyElemBehavior
        }()
    
    var ballPusher: UIPushBehavior?
    weak var collisionDelegate: UICollisionBehaviorDelegate? {
        get { return collision.collisionDelegate }
        set { collision.collisionDelegate = newValue }
    }
    var items: [AnyObject] {
        return collision.items
    }
    
    override init() {
        super.init()
        addChildBehavior(collision)
        addChildBehavior(elementBehavior)
    }
    
    func addBehaviorsToElements(elems: [UIView]) {
        for elem in elems {
            addBehaviorsToElement(elem)
        }
    }
    
    func addBehaviorsToElement(elem: UIView) {
        if let superview = dynamicAnimator?.referenceView {
            if !contains(superview.subviews as [UIView], elem) {
                superview.addSubview(elem)
            }
        }
        collision.addItem(elem)
        elementBehavior.addItem(elem)
    }
    
    func removeBehaviorsFromElement(elem: UIView) {
        collision.removeItem(elem)
        elementBehavior.removeItem(elem)
    }
        
    func pushBalls(balls: [UIView]) {
        let push = UIPushBehavior(items: balls, mode: .Instantaneous)
        push.magnitude = 0.01
        push.pushDirection = CGVector(dx: CGFloat(0.3).positiveOrNegative(), dy: CGFloat(0.3).positiveOrNegative())
        //println("push.pushDirection(\(push.pushDirection.dx),\(push.pushDirection.dy))")
        //ballPusher = push
        unowned let unownedPush = push!
        push.action = {
            unownedPush.dynamicAnimator!.removeBehavior(unownedPush)
        }
        dynamicAnimator?.addBehavior(push)
    }
    
    func addBoundaryForPath(path: UIBezierPath, named name: String) {
        collision.removeBoundaryWithIdentifier(name)
        collision.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBoundaryFromPoint(point: CGPoint, toPoint: CGPoint, named name: String) {
        collision.addBoundaryWithIdentifier(name, fromPoint: point, toPoint: toPoint)
    }
}

private extension CGFloat {
    
    func positiveOrNegative() -> CGFloat {
        let numbers = [1.0,-1.0]
        let i = Int(arc4random() % 2)
        return self * CGFloat(numbers[i])
    }
    
    func divideTen() -> CGFloat {
        return self / 10.0
    }
    
}

func randomCGFloat(i1: CGFloat, i2: CGFloat) -> CGFloat {
    let n1 = i1 < i2 ? i1 : i2
    let n2 = i1 < i2 ? i2 : i1
    let n = n2-n1
    let r = (n != 0) ? arc4random() % UInt32(n*100+1) : 0
    return CGFloat(r)/100+n1
}
















