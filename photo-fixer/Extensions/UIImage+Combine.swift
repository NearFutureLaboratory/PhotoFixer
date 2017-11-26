//
//  UIImage+Combine.swift
//  photo-fixer
//
//  Created by Julian Bleecker on 11/25/17.
//  Copyright © 2017 Near Future Laboratory. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
        
        let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  = round((newImageSize.width  - firstImage.size.width  ) / 2)
        let firstImageDrawY  = round((newImageSize.height - firstImage.size.height ) / 2)
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = round((newImageSize.height - secondImage.size.height) / 2)
        
        firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return image!
    }
    
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsBeginImageContextWithOptions(to, true, self.scale)
        cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized!
    }
    
    
    func imageByCropToRect(rect:CGRect, scale:Bool) -> UIImage {
        
        var rect = rect
        var scaleFactor: CGFloat = 1.0
        if scale  {
            scaleFactor = self.scale
            rect.origin.x *= scaleFactor
            rect.origin.y *= scaleFactor
            rect.size.width *= scaleFactor
            rect.size.height *= scaleFactor
        }
        
        var image: UIImage? = nil;
        if rect.size.width > 0 && rect.size.height > 0 {
            let imageRef = self.cgImage!.cropping(to: rect)
            image = UIImage(cgImage: imageRef!, scale: scaleFactor, orientation: self.imageOrientation)
        }
        
        return image!
    }
    
    
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    func crop( toAspectRatio : CGFloat) -> UIImage {
        let aspectRatio = self.size.width / self.size.height
        var croppedHeight : CGFloat
        var croppedWidth : CGFloat
        var cropSize : CGSize
        if (toAspectRatio < aspectRatio) {
            croppedHeight = self.size.width * (1 / toAspectRatio)
            cropSize = CGSize(width: self.size.width, height: croppedHeight)
        } else {
            croppedWidth = self.size.height * toAspectRatio
            cropSize = CGSize(width: croppedWidth, height: self.size.height)
        }
        
        
        return self.crop(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: cropSize))
//        let origin = CGPoint(x: (self.size.width - width)/2, y: (imageHeight - height)/2)
//        let size = CGSize(width: width, height: height)

        
    }

    func cropPortraitImageToAspectRatio(aspectRatio : CGFloat) -> UIImage {
        let croppedHeight = self.size.height * 1/aspectRatio
        let cropSize = CGSize(width: self.size.width, height: croppedHeight)
        
        UIGraphicsBeginImageContext(cropSize)
        let croppedImageRect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: croppedHeight)
       // CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
        self.draw(in: croppedImageRect)
       // [image drawInRect:scaledImageRect];
        let croppedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
       // UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return croppedImage;
    }
    
    func scaleImageToView(view : UIImageView) -> UIImage {
            let viewSize = view.frame.size
            let horizontalRatio = viewSize.width / self.size.width
            let verticalRatio = viewSize.height / self.size.height
            
            let ratio = max(horizontalRatio, verticalRatio)
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
            draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
    }
    
    
    class func createWhiteSquare(width : CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: width))
        UIColor.white.setFill()
        //[color setFill];
        UIRectFill(CGRect(x: 0, y: 0, width: width, height: width))
        //UIRectFill(imgBounds);
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        //UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        //UIGraphicsEndImageContext();
        
        return result
    }
    
    
    
    func aspectRatio() -> CGFloat
    {
        return self.size.width / self.size.height
    }
}
