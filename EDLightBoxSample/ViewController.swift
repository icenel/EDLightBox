//
//  ViewController.swift
//  EDLightBoxSample
//
//  Created by Edward Anthony on 7/31/15.
//  Copyright (c) 2015 Edward Anthony. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EDLightBoxDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let lightBox = EDLightBox()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // You can set low resolution image here
        var lowResolutionImageURL = NSURL(string: "http://imageshack.com/a/img537/7851/gEmPzw.jpg")!
        imageView.image = UIImage(data: NSData(contentsOfURL: lowResolutionImageURL)!)
        
        lightBox.delegate = self
        
        // Install light box
        lightBox.installOnImageView(imageView)
    }

    func parentViewControllerForLightBox(lightBox: EDLightBox) -> UIViewController {
        return self
    }
    
    func imageURLForLightBox(lightBox: EDLightBox) -> NSURL {
        // High resolution image for light box
        var highResolutionImageURL = NSURL(string: "http://imageshack.com/a/img907/7184/7qC5Ls.jpg")!
        
        return highResolutionImageURL
    }

}

