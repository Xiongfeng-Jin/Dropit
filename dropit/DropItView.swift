//
//  DropItView.swift
//  dropit
//
//  Created by Jin on 2/26/17.
//  Copyright © 2017 Jin. All rights reserved.
//

import UIKit
import CoreMotion

class DropItView: NamedBezierPathView ,UIDynamicAnimatorDelegate{
    private let dropPerRow = 10
    private let dropBehavior = FallingObjectBehavior()

    private lazy var animator :UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        removeCompleteRow()
    }
    
    var animating = false{
        didSet{
            if animating {
                animator.addBehavior(dropBehavior)
                updateRealGravity()
            }
            else{
                animator.removeBehavior(dropBehavior)
            }
        }
    }
    
    
    var realGravity = false{
        didSet{
            updateRealGravity()
        }
    }
    
    
    private var motionManager:CMMotionManager = CMMotionManager()
    private func updateRealGravity(){
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive{
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {[unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil{
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y{
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx, &dy)
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
                            default:
                                dx = 0; dy = 0
                            }
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx:dx,dy:dy)
                        }
                    }
                    else{
                        self.motionManager.stopAccelerometerUpdates()
                    }
                })
            }
        }
        else{
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    private var lastDrop:UIView?
    
    private var attachment:UIAttachmentBehavior?{
        willSet{
            if attachment != nil{
                animator.removeBehavior(attachment!)
                bezierPaths[PathName.Attachment] = nil
            }
        }
        didSet{
            if attachment != nil{
                animator.addBehavior(attachment!)
                attachment!.action = {[unowned self] in
                    if let attachedDrop = self.attachment!.items.first as? UIView{
                        self.bezierPaths[PathName.Attachment] = UIBezierPath.lineFrom(from: (self.attachment?.anchorPoint)!, to: attachedDrop.center)
                    }
                }
            }
        }
    }
    
    private struct PathName{
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: dropSize))
        bezierPaths[PathName.MiddleBarrier] = path
        dropBehavior.addBarrier(path: path, named: PathName.MiddleBarrier)*/
    }
    
    private var dropSize :CGSize{
        let size = bounds.size.width / CGFloat(dropPerRow)
        return CGSize(width: size, height: size)
    }
    
    func grapDrop(recognizer:UIPanGestureRecognizer){
        let gesturePoint = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            if let dropToAttchTo = lastDrop, dropToAttchTo.superview != nil{
                attachment = UIAttachmentBehavior(item: dropToAttchTo, attachedToAnchor: gesturePoint)
            }
        case .changed:
            attachment?.anchorPoint = gesturePoint
        default:
            attachment = nil
            lastDrop = nil
        }
    }
    
    private func removeCompleteRow(){
        var dropsToRemove = [UIView]()
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        repeat{
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFound = [UIView]()
            while dropsTested < dropPerRow {
                if let hitView = hitTest(p: hitTestRect.mid), hitView.superview == self {
                    dropsFound.append(hitView)
                }
                else{
                    break
                }
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            if dropsTested == dropPerRow{
                dropsToRemove += dropsFound
            }
        }while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove{
            dropBehavior.removeItem(item: drop)
            drop.removeFromSuperview()
        }
    }
    
    func addDrop(){
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(max: dropPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        addSubview(drop)
        dropBehavior.addItem(item: drop)
        lastDrop = drop
    }
}
