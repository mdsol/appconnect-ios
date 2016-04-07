//
//  CaptureImage.swift
//  AppConnectSwift
//
//  Created by Suman Sucharit Das on 4/1/16.
//  Copyright © 2016 Medidata Solutions. All rights reserved.
//

import UIKit

class CaptureImage: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        photoUpload(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Image picker delegate functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        print(info)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = image
        self.image = image!
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: View Controller Toolbar Items
    @IBAction func searchTapped(sender: AnyObject) {
        photoUpload(false)
    }
    
    @IBAction func cameraTapped(sender: AnyObject) {
        photoUpload(true)
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        if(image.CGImage != nil){
            let data = compressFile() as? NSData
            var subject: MDSubject
            //subject.co
        }
        else{
            postAlert("No image", message: "Image selected has no path")
        }
    }
    
    func photoUpload(fromCamera: Bool) {
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        if(fromCamera){
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                imagePicker.sourceType = .Camera
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                postAlert("Camera not accessable", message: "AppConnect cannot access the camera.")
            }
        }
        else {
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: {})
        }
    }

    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
        preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func compressFile() -> NSData{
        var imgHeight = image.size.height as CGFloat
        var imgWidth = image.size.width as CGFloat
        let adjustedHeight = 1136.0 as CGFloat
        let adjustedWidth = 640.0 as CGFloat
        let imgAspectRatio = imgWidth/imgHeight
        let adjustedAspectRatio = adjustedWidth/adjustedHeight
        var compressionQuality : CGFloat = 0.5 // Quality of compression
        
        // Resize
        if (adjustedHeight < imgHeight || adjustedWidth < imgWidth){
            // Adjusting larger width
            if(imgAspectRatio < adjustedAspectRatio){
                imgWidth = adjustedHeight / imgHeight * imgWidth;
                imgHeight = adjustedHeight;
            }
            // Adjusting larger height
            else if (imgAspectRatio > adjustedAspectRatio){
                imgHeight = adjustedWidth / imgWidth * imgHeight
                imgWidth = adjustedWidth
            }
            // No compression
            else{
                imgWidth = adjustedWidth;
                imgHeight = adjustedHeight;
                compressionQuality = 1;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, imgWidth, imgHeight)
        
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData!;
    }

}


