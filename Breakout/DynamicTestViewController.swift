//
//  DynamicTestViewController.swift
//  Breakout
//
//  Created by Jack Huang on 15/3/12.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

import UIKit

class DynamicTestViewController: UIViewController {

    lazy var redBlock: UIView = {
        let v = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: 20, height: 20)))
        v.backgroundColor = UIColor.redColor()
        v.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "dragBlock:"))
        self.view.addSubview(v)
        return v
    }()
    
    lazy var blueBlock: UIView = {
        let v = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: 50, height: 50)))
        v.backgroundColor = UIColor.blueColor()
        self.view.addSubview(v)
        return v
        }()
    
    lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
    var attachment: UIAttachmentBehavior?
    
    func addGravityForItem(item: UIDynamicItem) {
        let gravity = UIGravityBehavior()
        gravity.addItem(item)
        animator.addBehavior(gravity)
    }
    
    func addCollisionForItems(items: [UIDynamicItem]) {
        let collision = UICollisionBehavior()
        collision.collisionMode = .Everything
        collision.translatesReferenceBoundsIntoBoundary = true
        for item in items { collision.addItem(item) }
        animator.addBehavior(collision)
    }
    
    func addItemBehaviorForItem(item: UIDynamicItem) {
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.elasticity = 1
        itemBehavior.resistance = 0
        itemBehavior.friction = 0
        itemBehavior.density = 1
        itemBehavior.addItem(item)
        animator.addBehavior(itemBehavior)
    }
    
    func addAnotherItemBehaviorForItem(item: UIDynamicItem) {
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.elasticity = 1
        itemBehavior.resistance = 0
        itemBehavior.friction = 0
        itemBehavior.density = 0.1
        itemBehavior.addItem(item)
        animator.addBehavior(itemBehavior)
    }
    
    func dragBlock(gesture: UIPanGestureRecognizer) {
        let location = gesture.locationInView(view)
        switch gesture.state {
        case .Began:
            if redBlock.frame.contains(location) {
                attachment = UIAttachmentBehavior(item: redBlock, attachedToAnchor: location)
                animator.addBehavior(attachment)
            }
        case .Changed:
            attachment?.anchorPoint = location
        case .Ended:
            animator.removeBehavior(attachment)
        default: break
        }
    }
    
    func push(gesture: UITapGestureRecognizer) {
        addImpulsePushToItem(redBlock)
        addImpulsePushToItem(blueBlock)
    }
    
    func addImpulsePushToItem(item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .Instantaneous)
        push.pushDirection = CGVector(dx: 0, dy: 10)
        push.setTargetOffsetFromCenter(UIOffset(horizontal: 20, vertical:0), forItem: item)
        push.magnitude = 0.1
        animator.addBehavior(push)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "push:"))
        
        // set view's values before added to dynamic behaviors
        redBlock.center = CGPoint(x: view.center.x-50, y: view.bounds.size.height * 0.5)
        blueBlock.center = CGPoint(x: view.center.x+50, y: view.bounds.size.height * 0.5)
        
        // collision
        addCollisionForItems([redBlock, blueBlock])
        
        // item behavior
        addItemBehaviorForItem(redBlock)
        addAnotherItemBehaviorForItem(blueBlock)
        
    }
}







































