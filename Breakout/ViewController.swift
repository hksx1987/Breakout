//
//  ViewController.swift
//  Breakout
//
//  Created by Jack Huang on 15/3/10.
//  Copyright (c) 2015年 Jack's app for practice. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate {
    
    // behaviors
    lazy var animator: UIDynamicAnimator = {
        UIDynamicAnimator(referenceView: self.gameView)
    }()
    
    var breakoutBehavior = BreakoutBehavior()
    
    // game elements
    struct Constant {
        static let BallSize = CGSize(width: 30, height: 30)
        static let BallColor = UIColor.redColor()
        static let BrickSize = CGSize(width: 320/4, height: 40)
        static let BrickColor = UIColor.blueColor()
        static let PaddleSize = CGSize(width: 80, height: 15)
        static let PaddleColor = UIColor.greenColor()
    }
    struct Boundary {
        static let Paddle = "PaddleBoundaryIdentifier"
        static let TopWall = "TopWallBoundaryIdentifier"
        static let LeftWall = "LeftWallBoundaryIdentifier"
        static let RightWall = "RightWallBoundaryIdentifier"
    }
    
    lazy var ball: UIView = {
        let lazilyBall = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: Constant.BallSize))
        lazilyBall.backgroundColor = Constant.BallColor
        lazilyBall.center = self.gameView.center
        return lazilyBall
    }()
    
    lazy var paddle: UIView = {
        let lazilyPaddle = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: Constant.PaddleSize))
        lazilyPaddle.backgroundColor = UIColor.grayColor()
        lazilyPaddle.center = CGPoint(x: self.gameView.center.x, y: self.gameView.bounds.size.height * 0.85)
        return lazilyPaddle
    }()
    var balls = [UIView]()
    var bricks = [String:BrickView]()
    var resetButton: UIButton?
    var isPushed: Bool = false // if ball is pushed
    
    @IBOutlet weak var gameView: UIView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: "pushBall:")
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            gameView.addGestureRecognizer(tap)
            let twoFingersTap = UITapGestureRecognizer(target: self, action: "spinable:")
            twoFingersTap.numberOfTapsRequired = 1
            twoFingersTap.numberOfTouchesRequired = 2
            gameView.addGestureRecognizer(twoFingersTap)
            let twoFingersDoubleTap = UITapGestureRecognizer(target: self, action: "unspinable:")
            twoFingersDoubleTap.numberOfTapsRequired = 2
            twoFingersDoubleTap.numberOfTouchesRequired = 2
            gameView.addGestureRecognizer(twoFingersDoubleTap)
        }
    }
    
    func pushBall(gesture: UITapGestureRecognizer) {
        isPushed = true
        breakoutBehavior.pushBalls(balls)
    }
    func spinable(gesture: UITapGestureRecognizer) {
        breakoutBehavior.elementBehavior.allowsRotation = true
    }
    func unspinable(gesture: UITapGestureRecognizer) {
        breakoutBehavior.elementBehavior.allowsRotation = false
    }
    
    var touchOffset = CGPoint.zeroPoint
    func movePaddle(gesture: UIPanGestureRecognizer) {
        let location = gesture.locationInView(gameView)
        switch gesture.state {
        case .Began:
            touchOffset = CGPoint(x: paddle.center.x-location.x, y: paddle.center.y-location.y)
        case .Changed:
            paddle.center.x = location.x+touchOffset.x
            if paddle.frame.minX <= 0.0 {
                paddle.center.x = paddle.bounds.size.width/2
            } else if paddle.frame.maxX >= gameView.bounds.size.width {
                paddle.center.x = gameView.bounds.size.width-paddle.bounds.size.width/2
            }
            let path = UIBezierPath(rect: paddle.frame)
            breakoutBehavior.addBoundaryForPath(path, named: Boundary.Paddle)
            // ball along with paddle
            for ball in balls {
                if !isPushed {
                    ball.center.x = paddle.center.x
                    animator.updateItemUsingCurrentState(ball)
                }
            }
        case .Ended: fallthrough
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
        breakoutBehavior.collisionDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGame() {
        resetButton?.removeFromSuperview()
        isPushed = false
        
        // setup bricks with boundaries
        for i in 0...4 { // rows
            for j in 0...3 { // columns
                let position = "\(i)\(j)"
                let origin = CGPoint(x: Constant.BrickSize.width * CGFloat(j), y: Constant.BrickSize.height * CGFloat(i))
                let brick = BrickView(frame: CGRect(origin: origin, size: Constant.BrickSize))
                if i % 4 == 0 && j % 3 == 0 {
                    brick.isSpecial = true // set special brick
                }
                gameView.addSubview(brick)
                bricks[position] = brick
                breakoutBehavior.addBoundaryForPath(UIBezierPath(rect: brick.frame), named: position)
            }
        }
        
        // add paddle boundary
        paddle.center.x = gameView.center.x
        gameView.addSubview(paddle)
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "movePaddle:"))
        let paddleBoundary = UIBezierPath(ovalInRect: paddle.frame)
        breakoutBehavior.addBoundaryForPath(paddleBoundary, named: Boundary.Paddle)
        
        // add wall boundary after view's bounds laid out
        breakoutBehavior.addBoundaryFromPoint(gameView.bottomLeftPosition, toPoint: gameView.frame.origin, named: Boundary.LeftWall)
        breakoutBehavior.addBoundaryFromPoint(gameView.frame.origin, toPoint: gameView.topRightPosition, named:Boundary.TopWall)
        breakoutBehavior.addBoundaryFromPoint(gameView.topRightPosition, toPoint: gameView.bottomRightPosition, named: Boundary.RightWall)
        
        animator.addBehavior(breakoutBehavior)
        balls = [ball]
        
        for ball in balls {
            ball.center = CGPoint(x: gameView.center.x, y: paddle.center.y-Constant.BallSize.height-1)
        }
        breakoutBehavior.addBehaviorsToElements(balls)
        
        // add auto-reset function
        unowned let unownedBreakoutBehavior = breakoutBehavior
        breakoutBehavior.action = { [unowned self] in
            // game over
            var i: Int?
            for (index, ball) in enumerate(self.balls) {
                if !self.gameView.bounds.contains(ball.center) {
                    unownedBreakoutBehavior.removeBehaviorsFromElement(ball)
                    ball.removeFromSuperview()
                    i = index
                    break
                }
            }
            if i != nil { self.balls.removeAtIndex(i!) }
            if self.balls.count == 0 { self.clearGame() }
        }
        
    }
    
    func clearGame() {
        // clear all
        var isFinished: Bool = (bricks.count == 0)
        
        for item in gameView.subviews {
            breakoutBehavior.removeBehaviorsFromElement(item as UIView)
            item.removeFromSuperview()
        }
        animator.removeBehavior(breakoutBehavior)
        balls.removeAll()
        bricks.removeAll()
        
        let button = UIButton.buttonWithType(.Custom) as UIButton
        button.setAttributedTitle(NSAttributedString(string: isFinished ? "Congratulation!" : "Again?", attributes: [NSForegroundColorAttributeName:UIColor.blueColor()]), forState: .Normal)
        button.sizeToFit()
        button.center = gameView.center
        button.addTarget(self, action: "setupGame", forControlEvents: .TouchUpInside)
        gameView.addSubview(button)
        resetButton = button
    }

    
    // MARK: - UICollisionBehaviorDelegate
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying) {
        if let idString = identifier as? NSString { // cast as String will crash!
            if let brick = bricks.removeValueForKey(idString) { // return a associated value or nil
                if !brick.isSpecial {
                    brick.removeFromSuperview()
                    behavior.removeBoundaryWithIdentifier(idString)
                } else {
                    brick.isSpecial = false
                    bricks[idString] = brick
                }
            }
        }
        // win
        if self.bricks.count == 0 { self.clearGame() }
    }
    
    // MARK: -
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

private extension UIView {
    
    var bottomLeftPosition: CGPoint {
        return CGPoint(x: frame.origin.x, y: frame.origin.y+bounds.size.height)
    }
    var topRightPosition: CGPoint {
        return CGPoint(x: frame.origin.x+bounds.size.width, y: frame.origin.y)
    }
    var bottomRightPosition: CGPoint {
        return CGPoint(x: frame.origin.x+bounds.size.width, y: frame.origin.y+bounds.size.height)
    }
}








































