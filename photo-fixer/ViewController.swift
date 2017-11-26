//
//  ViewController.swift
//  photo-fixer
//
//  Created by Julian Bleecker on 11/25/17.
//  Copyright © 2017 Near Future Laboratory. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var originalImageView : UIImageView!
    @IBOutlet var croppedImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let original = UIImage.init(named: "scale_original_4_3.png")!
        
        originalImageView?.image = original.scaleImageToView(view: originalImageView)
        // let r = CGRect(x: 0, y: 0, width: original.size.width, height: original.size.height * 3/4)
        // let cropped = original.imageByCropToRect(rect: r, scale: true).scaleImageToView(view: croppedImageView)
        
        //.crop(toAspectRatio: 4/3)
        var cropped : UIImage
        let ratio = original.aspectRatio()
        if ratio == 4/3 {
            cropped = original.crop(to: CGSize(width: original.size.width, height: original.size.width*2/3))
        } else {
            cropped = original
        }
        
        let whiteSquare = UIImage.createWhiteSquare(width: cropped.size.width)
        let sq = UIImage.imageByCombiningImage(firstImage: whiteSquare, withImage: cropped)
        
        croppedImageView?.image = sq
        
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let filePath = "\(paths[0])/MyImageName.png"
        
        do {
            // Save image.
            try UIImagePNGRepresentation(sq)?.write(to: URL(fileURLWithPath: filePath))
        } catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

