//
//  EDLightBox.swift
//  FoodSquare
//
//  Created by Edward Anthony on 7/30/15.
//  Copyright (c) 2015 FoodSquare. All rights reserved.
//

import UIKit

@objc protocol EDLightBoxDelegate {
    func parentViewControllerForLightBox(lightBox: EDLightBox) -> UIViewController
    func imageURLForLightBox(lightBox: EDLightBox) -> NSURL
    
    optional func lightBoxWillAppear(lightBox: EDLightBox)
    optional func lightBoxDidAppear(lightBox: EDLightBox)
    optional func lightBoxWillDisappear(lightBox: EDLightBox)
    optional func lightBoxDidDisappear(lightBox: EDLightBox)
}

class EDLightBoxViewController: UIViewController {
    let imageView = UIImageView()
    let doneButton = UIButton()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.clearColor()
        
        imageView.contentMode = .ScaleAspectFit
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 4.0
        doneButton.layer.borderWidth = 1.0
        doneButton.layer.borderColor = UIColor.whiteColor().CGColor
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), forState: .Normal)
        doneButton.titleLabel!.font = UIFont.systemFontOfSize(13.0)
        
        view.addSubview(imageView)
        view.addSubview(doneButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        doneButton.sizeToFit()
        let size = doneButton.frame.rectByInsetting(dx: -12.0, dy: 0)
        doneButton.frame = CGRect(x: view.frame.width - 20.0 - size.width, y: 30.0, width: size.width, height: size.height)
        doneButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleBottomMargin
    }
}

class EDLightBox: NSObject {
    
    var animationDuration = 0.6
    var overlayColor = UIColor.blackColor()
    
    weak var delegate: EDLightBoxDelegate!
    
    var lightBoxViewController: EDLightBoxViewController?
    var sourceImageView: UIImageView?
    
    func installOnImageViews(imageViews: [UIView]) {
        imageViews.map { self.installOnImageView($0) }
    }
    
    func installOnImageView(imageView: UIView) {
        imageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTouchSourceImageView:")
        imageView.addGestureRecognizer(tapGesture)
    }
    
    func didTouchSourceImageView(sender: UITapGestureRecognizer) {
        if let senderView = sender.view as? UIImageView {
            showLightBoxWithSourceImageView(senderView)
        } else {
            println("Cannot determine source image view")
        }
    }
    
    func showLightBoxWithSourceImageView(sourceImageView: UIImageView) {
        setupLightBoxViewControllerForImageView(sourceImageView)
        assert(delegate != nil, "EDLightBox delegate cannot be nil")
        
        self.sourceImageView = sourceImageView
        
        let parentViewController = delegate.parentViewControllerForLightBox(self)
        lightBoxViewController!.view.frame = parentViewController.view.bounds
        
        parentViewController.addChildViewController(lightBoxViewController!)
        parentViewController.view.addSubview(lightBoxViewController!.view)
        
        delegate?.lightBoxWillAppear?(self)
        
        // Animate show light box
        
        self.sourceImageView!.hidden = true
        
        let lightBoxImageView = self.lightBoxViewController!.imageView
        lightBoxImageView.frame.size = self.sourceImageView!.bounds.size
        lightBoxImageView.transform = self.sourceImageView!.transform
        
        lightBoxImageView.center = lightBoxImageView.superview!.convertPoint(sourceImageView.center, fromView: sourceImageView.superview)
        println(lightBoxImageView.center)
        
        UIView.animateWithDuration(animationDuration - 0.2, animations: {
            self.lightBoxViewController!.view.backgroundColor = self.overlayColor
            }, completion: nil)
        
        UIView.animateWithDuration(animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 20,
            options: .CurveLinear,
            animations: {
                lightBoxImageView.frame = self.lightBoxViewController!.view.frame
            }, completion: { finished in
                self.delegate?.lightBoxDidAppear?(self)
        })
    }
    
    func hideLightBox() {
        self.delegate.lightBoxWillDisappear?(self)
        self.lightBoxViewController!.doneButton.hidden = true
        
        let lightBoxImageView = self.lightBoxViewController!.imageView
        lightBoxImageView.layer.masksToBounds = self.sourceImageView!.layer.masksToBounds
        lightBoxImageView.layer.cornerRadius = self.sourceImageView!.layer.cornerRadius
        
        UIView.animateWithDuration(animationDuration - 0.2, animations: {
            self.lightBoxViewController!.view.backgroundColor = UIColor.clearColor()
            }, completion: nil)
        
        UIView.animateWithDuration(animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 20,
            options: .CurveLinear,
            animations: {
                let center = lightBoxImageView.superview!.convertPoint(self.sourceImageView!.center, fromView: self.sourceImageView!.superview)
                let sourceImageViewSize = self.sourceImageView!.bounds.size
                lightBoxImageView.frame = CGRect(x: center.x - (sourceImageViewSize.width / 2),
                    y: center.y - (sourceImageViewSize.height / 2),
                    width: sourceImageViewSize.width, height: sourceImageViewSize.height)
            }, completion: { finished in
                self.lightBoxViewController!.view.removeFromSuperview()
                self.lightBoxViewController!.removeFromParentViewController()
                self.sourceImageView!.hidden = false
                self.delegate.lightBoxDidDisappear?(self)
        })
    }
    
    // MARK: -
    
    func setupLightBoxViewControllerForImageView(imageView: UIImageView) {
        lightBoxViewController = EDLightBoxViewController()
        lightBoxViewController!.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        lightBoxViewController!.doneButton.addTarget(self, action: "hideLightBox", forControlEvents: .TouchUpInside)
        let url = delegate.imageURLForLightBox(self)
        lightBoxViewController!.imageView.sd_setImageWithURL(url, placeholderImage: imageView.image)
    }
}
