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
    
    var data : Data!
    
    var subjectID: Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.saveImageButton.isEnabled = false
        
        self.navigationItem.title = "Capture Image"
    }
    
    // MARK: Image picker delegate functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true)
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.data = self.scaleDownAndConvertImageToNSData(img)
        
        self.imageView.image = img
        self.saveImageButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    // MARK: View Controller Toolbar Items
    @IBAction func searchTapped(_ sender: AnyObject) {
        takeOrSelectPicture(false)
    }
    
    @IBAction func cameraTapped(_ sender: AnyObject) {
        takeOrSelectPicture(true)
    }
    
    @IBAction func saveTapped(_ sender: AnyObject) {
        
        if self.data == nil {
            showAlert("No image selected", message: "")
            return
        }
        
        let datastore = (UIApplication.shared.delegate as! AppDelegate).UIDatastore!
        let subject = datastore.subject(withID: self.subjectID)
        
        subject?.collect(self.data, withMetadata: "Random String", contentType: "image/jpeg", completion: { (err: Error?) -> Void in
            if let error = err {
                OperationQueue.main.addOperation() {
                    self.showAlert("", message: error.localizedDescription)
                }
            } else {
                // update the UI.
                OperationQueue.main.addOperation() {
                    self.showAlert("Data saved successfully", message: "Will be uploaded automatically!")
                    self.imageView.image = nil
                    self.data = nil
                    self.saveImageButton.isEnabled = false
                }
            }
        })
    }
    
    func takeOrSelectPicture(_ fromCamera: Bool) {
        // Looks for camera
        if fromCamera {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                present(imagePicker, animated: true)
            } else {
                showAlert("Camera not accessible", message: "")
            }
            
            return
        }
        
        // Looks for images in photo library
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default))
        self.present(alert, animated: true)
    }

    func scaleDownAndConvertImageToNSData(_ image: UIImage) -> Data {
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
            } else if imgAspectRatio > adjustedAspectRatio {
                // Adjusting larger height
                imgHeight = adjustedWidth / imgWidth * imgHeight
                imgWidth = adjustedWidth
            } else {
                // No compression
                imgWidth = adjustedWidth;
                imgHeight = adjustedHeight;
                compressionQuality = 1
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: imgWidth, height: imgHeight)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality)
        UIGraphicsEndImageContext()
        
        return imageData!;
    }
}
