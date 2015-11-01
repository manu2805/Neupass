//
//  StartViewController.swift
//  Neupass
//
//  Created by Manudeep N.s on 10/29/15.
//  Copyright (c) 2015 Manudeep Suresh. All rights reserved.
//

import UIKit
import Photos
import RMImagePicker
import Alamofire

class StartViewController: UIViewController, RMImagePickerControllerDelegate {
    
    //IBOutlets
    @IBOutlet weak var titlescreen: UITextView!
    @IBOutlet weak var selectPictureButton: UIButton!
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var sendDataButton: UIButton!
    
    //Local Properties
    var backgroundImage: UIImageView!
    var selectPictureTick = false
    var playGameTick = false
    var sendData = false
    
    //Photos
    var popoverController: UIPopoverController!
    lazy var imageManager = PHImageManager.defaultManager()
    var assets: [PHAsset] = []
    var finalImages: [UIImage] = []
    
    //USER ID
    var userID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let image = UIImage(named: "startbackground.png")
        backgroundImage = UIImageView(image: image)
        backgroundImage.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgroundImage)
        
        titlescreen.backgroundColor = UIColor.clearColor()
        self.view.bringSubviewToFront(titlescreen)
        self.view.bringSubviewToFront(selectPictureButton)
        self.view.bringSubviewToFront(playGameButton)
        self.view.bringSubviewToFront(sendDataButton)
        
        //Check if User ID exists in file, else create one
        userID = getID() as? String
        
        
        //Get blur radius and blur iterations from the server
        Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getGameParameters.jsp")
            .responseString { response in
                self.parseResponse(response.result.value!)
        }
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        let pictureCount = finalImages.count
        print("\(pictureCount)")
        if pictureCount < 4 {
            //Display alert and disable button
            let alertController = UIAlertController(title: "Error", message:
                "Please choose 4 pictures", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            playGameButton.enabled = false
        } else {
            playGameButton.enabled = true
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickImages(sender: AnyObject) {
        let imagePicker = RMImagePickerController()
        imagePicker.pickerDelegate = self
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.popoverController = UIPopoverController(contentViewController: imagePicker)
            self.popoverController.presentPopoverFromBarButtonItem(
                self.navigationItem.rightBarButtonItem!,
                permittedArrowDirections: UIPopoverArrowDirection.Any,
                animated: true)
        } else {
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - RMImagePickerControllerDelegate
    
    func rmImagePickerController(picker: RMImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        finalImages.removeAll(keepCapacity: false)
        for i in 0..<assets.count {
            let asset = assets[i]
            self.imageManager.requestImageForAsset(
                asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: PHImageContentMode.AspectFill,
                options: nil,
                resultHandler: { (image, info) -> Void in
                self.finalImages.append(image!)
                })
        }
        let curTime = NSDate()
        let count = assets.count
        GameSingleton.sharedInstance.setSelectImageParams(count, imageSelectTime: curTime)
        self.dismissPickerPopover()
    }
    
    func rmImagePickerControllerDidCancel(picker: RMImagePickerController) {
        self.dismissPickerPopover()
    }


    func dismissPickerPopover() {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.popoverController?.dismissPopoverAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Prepare for segue
    override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!) {
        if segue.identifier == "showKeycode" {
           let tmp = segue!.destinationViewController as! BirthYearViewController
            tmp.assets = finalImages
        }
    }
    
    // MARK: - Create 32-bit User ID
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }
    
    // MARK: - Retrieve UserID from file
    func getID() -> NSString? {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileMgr = NSFileManager.defaultManager()
        let fileURL = documentsURL.URLByAppendingPathComponent("user.archive")
        
        if fileMgr.fileExistsAtPath(fileURL.path!) {
            let dataArray = NSKeyedUnarchiver.unarchiveObjectWithFile(fileURL.path!) as! String
            print("Found in file \(dataArray)")
            return dataArray
        } else {
            userID = randomStringWithLength(32) as String
            NSKeyedArchiver.archiveRootObject(userID!, toFile: fileURL.path!)
        }
        return userID
    }
    
    // MARK: - Parse Response from Server
    func parseResponse(response: String) {
        let fullNameArr = response.characters.split{$0 == "\n"}.map(String.init)
        let blurRadVal = fullNameArr[0].characters.split{$0 == ":"}.map(String.init)
        let blurIterVal = fullNameArr[1].characters.split{$0 == ":"}.map(String.init)
        
        GameSingleton.sharedInstance.setValues(Int(blurRadVal[1])!, blurIter: Int(blurIterVal[1])!, userID: userID!)
        GameSingleton.sharedInstance.displayCurrentStatus()
    }
}