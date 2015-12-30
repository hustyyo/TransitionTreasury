//
//  BTTransitionAnimation.swift
//  TransitionTreasury
//
//  Created by DianQK on 12/22/15.
//  Copyright © 2015 TransitionTreasury. All rights reserved.
//

import UIKit

public class IBanTangTransitionAnimation: NSObject, TRViewControllerAnimatedTransitioning {
    
    public var keyView: UIView?
    
    public var transitionStatus: TransitionStatus?
    
    public var transitionContext: UIViewControllerContextTransitioning?
    
    public var completion: (() -> Void)?
    
    public var cancelPop: Bool = false
    
    public var interacting: Bool = false
    
    lazy private var keyViewCopy: UIView = {
        let keyViewCopy = UIView(frame: self.keyView!.frame)
        keyViewCopy.layer.contents = self.keyView?.layer.contents
        keyViewCopy.layer.contentsGravity = self.keyView!.layer.contentsGravity
        keyViewCopy.layer.contentsScale = self.keyView!.layer.contentsScale
        return keyViewCopy
    }()
    
    init(key: UIView?, status: TransitionStatus = .Push) {
        keyView = key
        transitionStatus = status
        super.init()
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containView = transitionContext.containerView()
        
        let lightMaskLayer: CALayer = {
            let layer =  CALayer()
            layer.frame = CGRect(origin: CGPointZero, size: toVC!.view.bounds.size)
            layer.backgroundColor = toVC!.view.backgroundColor?.CGColor
            let maskAnimation = CABasicAnimation(keyPath: "opacity")
            maskAnimation.fromValue = 0
            maskAnimation.toValue = 1
            maskAnimation.duration = transitionDuration(transitionContext)
            layer.addAnimation(maskAnimation, forKey: "")
            return layer
        }()
        
        containView?.addSubview(toVC!.view)
        containView?.addSubview(fromVC!.view)
        if transitionStatus == .Push {
            containView?.layer.addSublayer(lightMaskLayer)
            containView?.addSubview(keyViewCopy)
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations: {
            switch self.transitionStatus! {
            case .Push :
                self.keyViewCopy.layer.position.y = self.keyViewCopy.layer.bounds.height / 2
            case .Pop where self.interacting == true :
                fromVC!.view.layer.position.x = fromVC!.view.layer.bounds.width * 1.5
            case .Pop where self.interacting == false :
                fromVC!.view.layer.opacity = 0
                self.keyViewCopy.layer.position.y = self.keyView!.layer.position.y
            default :
                fatalError("You set false status.")
            }
            }) { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                if !self.cancelPop {
                    if finished {
                        self.completion?()
                        self.completion = nil
                    }
                }
                if self.transitionStatus == .Push {
                    toVC?.view.addSubview(self.keyViewCopy)
                    lightMaskLayer.removeFromSuperlayer()
                }
                self.cancelPop = false
        }
    }

}
