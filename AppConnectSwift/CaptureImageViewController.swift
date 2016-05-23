//
//  CaptureImage.swift
//  AppConnectSwift
//
//  Created by Suman Sucharit Das on 4/1/16.
//  Copyright © 2016 Medidata Solutions. All rights reserved.
//

import UIKit

class CaptureImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveImageButton: UIBarButtonItem!
    
    var imagePicker = UIImagePickerController()
    var userID : Int64!
    var data : NSData!
    var collectedSubjects: [MDSubject]!
    var subjectID: Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takeOrSelectPicture(true)
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.saveImageButton.enabled = false
        self.loadSubjects()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Capture Image"
    }
    
    // MARK: Image picker delegate functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.data = self.scaleDownAndConvertImageToNSData(img)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: View Controller Toolbar Items
    @IBAction func searchTapped(sender: AnyObject) {
        takeOrSelectPicture(false)
    }
    
    @IBAction func cameraTapped(sender: AnyObject) {
        takeOrSelectPicture(true)
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        
        if self.data == nil {
            showAlert("No image selected", message: "")
            return
        }
        
        let datastore = MDDatastoreFactory.create()
        let subject = datastore.subjectWithID(self.subjectID)
        
        subject.collectData(self.data, withMetadata: "Random String", contentType: "image/jpeg", completion: { (dataEnvelope:  MDSubjectDataEnvelope!, err: NSError!) -> Void in
            if err == nil {
                // data is collected, will be uploaded in the background.
                // show an alert?
            }
        })
    }
    
    func takeOrSelectPicture(fromCamera: Bool) {
        // Looks for camera
        if fromCamera {
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                imagePicker.sourceType = .Camera
                presentViewController(imagePicker, animated: true, completion: {})
            }
            else {
                showAlert("Camera not accessible", message: "")
            }
        }
        else {
            // Looks for images in photo library
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: {})
        }
    }
    
    func loadSubjects() {
        var bgQueue : NSOperationQueue! = NSOperationQueue()
        bgQueue.addOperationWithBlock() {
            let clientFactory = MDClientFactory.sharedInstance()
            let client = clientFactory.clientOfType(MDClientType.Network);
            var datastore = MDDatastoreFactory.create()
            let user = datastore.userWithID(self.userID)
            
            // Start an asynchronous task to load the subjects for the user logged in
            client.loadSubjectsForUser(user) { (subjects: [AnyObject]!, error: NSError!) -> Void in
                // Check all subjects loaded
                if error == nil {
                    // Enable image saving button once loaded
                    self.collectedSubjects = subjects as! [MDSubject]
                    self.subjectID = self.collectedSubjects[0].objectID;
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.saveImageButton.enabled = true
                        bgQueue = nil
                        datastore = nil
                    }
                }
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func scaleDownAndConvertImageToNSData(image: UIImage) -> NSData {
        var imgHeight = image.size.height as CGFloat
        var imgWidth = image.size.width as CGFloat
        let adjustedHeight = 1136.0 as CGFloat
        let adjustedWidth = 640.0 as CGFloat
        let imgAspectRatio = imgWidth/imgHeight
        let adjustedAspectRatio = adjustedWidth/adjustedHeight
        var compressionQuality : CGFloat = 0.5 // Quality of compression
        
        // Resize
        if adjustedHeight < imgHeight || adjustedWidth < imgWidth {
            if imgAspectRatio < adjustedAspectRatio {
                // Adjusting larger width
                imgWidth = adjustedHeight / imgHeight * imgWidth;
                imgHeight = adjustedHeight
            }
            else if imgAspectRatio > adjustedAspectRatio {
                // Adjusting larger height
                imgHeight = adjustedWidth / imgWidth * imgHeight
                imgWidth = adjustedWidth
            }
            else {
                // No compression
                imgWidth = adjustedWidth;
                imgHeight = adjustedHeight;
                compressionQuality = 1
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, imgWidth, imgHeight)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
        image.drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img, compressionQuality)
        UIGraphicsEndImageContext()
        
        return imageData!;
    }
}
