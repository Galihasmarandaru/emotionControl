//
//  viewFirstOpen.swift
//  emotionControl
//
//  Created by Galih Asmarandaru on 21/05/19.
//  Copyright © 2019 Galih Asmarandaru. All rights reserved.
//

import UIKit
import CoreMotion

class ViewFirstOpen: UIViewController {
    
    let impact = UIImpactFeedbackGenerator();
    
    lazy var dynamicAnimator: UIDynamicAnimator =
        {
            let dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
            return dynamicAnimator
    }()
    
    lazy var collision: UICollisionBehavior =
        {
            let collision = UICollisionBehavior(items: [self.orangeView])
            collision.translatesReferenceBoundsIntoBoundary = true
            return collision
    }()
    
    lazy var fieldBehaviors: [UIFieldBehavior] =
        {
            var fieldBehaviors = [UIFieldBehavior]()
            for _ in 0 ..< 2
            {
                let field = UIFieldBehavior.springField()
                field.addItem(self.orangeView)
                fieldBehaviors.append(field)
            }
            return fieldBehaviors
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior =
        {
            let itemBehavior = UIDynamicItemBehavior(items: [self.orangeView])
            // Adjust these values to change the "stickiness" of the view
            itemBehavior.density = 0.01
            itemBehavior.resistance = 10
            itemBehavior.friction = 0.0
            itemBehavior.allowsRotation = false
            return itemBehavior
    }()
    
    lazy var orangeView: UIView =
        {
            let widthHeight: CGFloat = 180.0
            let orangeView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: widthHeight, height:
                widthHeight))
            orangeView.backgroundColor = UIColor.orange
            self.view.addSubview(orangeView)
            return orangeView
    }()
    
    lazy var panGesture: UIPanGestureRecognizer =
        {
            impact.impactOccurred()
            let panGesture = UIPanGestureRecognizer(target: self, action:
                #selector(self.handlePan(sender:)))
            return panGesture
    }()
    
    lazy var attachment: UIAttachmentBehavior =
        {
            let attachment = UIAttachmentBehavior(item: self.orangeView, attachedToAnchor: .zero)
            return attachment
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
       orangeView.layer.cornerRadius = orangeView.frame.size.width/2
        dynamicAnimator.addBehavior(collision)
        dynamicAnimator.addBehavior(itemBehavior)
        for field in fieldBehaviors
        {
            dynamicAnimator.addBehavior(field)
        }
        orangeView.addGestureRecognizer(panGesture)
        impact.impactOccurred()
    }
    
    override func viewDidLayoutSubviews()
    {
        impact.impactOccurred()
        super.viewDidLayoutSubviews()
        orangeView.center = view.center
        dynamicAnimator.updateItem(usingCurrentState: orangeView)
        for (index, field) in fieldBehaviors.enumerated()
        {
            field.position = CGPoint(x: view.bounds
                .midX, y:  view.bounds.height * (0.25 + 1 * CGFloat(index)))
            field.region = UIRegion(size: CGSize(width: view.bounds.width, height:
                view.bounds.height * 0.5))
        } }
    
    
    @objc func handlePan(sender: UIPanGestureRecognizer)
    {
//        impact.impactOccurred()
        let location = sender.location(in: view)
        let velocity = sender.velocity(in: view)
        switch sender.state
        {
        case .began:
            attachment.anchorPoint = location
            dynamicAnimator.addBehavior(attachment)
        case .changed:
            attachment.anchorPoint = location
        case .cancelled, .ended, .failed, .possible:
            itemBehavior.addLinearVelocity(velocity, for: self.orangeView)
            dynamicAnimator.removeBehavior(attachment)
        default:
            print("nothing")
        }
    }
    
}


