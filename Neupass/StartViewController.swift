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

let PRIVATE = 0
let SHARED = 1


class StartViewController: UIViewController, RMImagePickerControllerDelegate {
    
    //IBOutlets
    @IBOutlet weak var titlescreen: UITextView!
    @IBOutlet weak var selectPictureButton: UIButton!
    @IBOutlet weak var sharePictureButton: UIButton!
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
    var username: String?
    var cacheCount = 0
    
    //Private or shared
    var photosAccess: Int?
    
    //First time
    var tField: UITextField!
    
    //CachedCount
    var cachedCountPrivate: Int! = 0
    var cachedCountShare: Int! = 0
    var cacheArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup observer for new 
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadParams", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //Get values for radius and iterations
        if Reachability.isConnectedToNetwork() {
            //Get blur radius and blur iterations from the server
            Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getGameParameters_ios.jsp").responseString { response in
                    print("STRING")
                    print(response.result.value!)
                    self.parseResponse(response.result.value!)
            }
            Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getCamouflageIndices.jsp").responseString { response in
                //self.parseResponse(response.result.value!)
                self.parseIndex(response.result.value!)
            }
            Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getCorrectEntriesInMultipass.jsp").responseString { response in
                print(response.result.value!)
                self.parseCorrectImages(response.result.value!)
            }
        } else {
            GameSingleton.sharedInstance.setValues(9, blurIter: 2)
            GameSingleton.sharedInstance.setCorrectImages(1)
            GameSingleton.sharedInstance.displayCurrentStatus()
        }
        
        setup()
        
        let notification = UILocalNotification()
        notification.alertBody = "You have not played in an hour!" // text that will be displayed in the notification
        notification.fireDate = NSDate()  // right now (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        let unit: NSCalendarUnit = [.Hour]
        notification.repeatInterval =  unit// this line defines the interval at which the notification will be repeated
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        
        //FILE STUFF
        let checkValidation = NSFileManager.defaultManager()
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        var filePath = documentDirectoryURL.URLByAppendingPathComponent("privateCount.archive")
        if checkValidation.fileExistsAtPath(filePath.path!) {
            do {
                let count = try String(contentsOfURL: filePath, encoding: NSUTF8StringEncoding)
                self.cachedCountPrivate = Int(count)
            } catch {
                
            }
        }
        
        print("CACHED COUNT \(self.cachedCountPrivate)")
        
        filePath = documentDirectoryURL.URLByAppendingPathComponent("sharedCount.archive")
        if checkValidation.fileExistsAtPath(filePath.path!) {
            do {
                let count = try String(contentsOfURL: filePath, encoding: NSUTF8StringEncoding)
                self.cachedCountShare = Int(count)
            } catch {
                
            }
        }
        
        filePath = documentDirectoryURL.URLByAppendingPathComponent("privateTime.archive")
        if checkValidation.fileExistsAtPath(filePath.path!) {
            print("CHECKED")
            do {
                let time = try String(contentsOfURL: filePath, encoding: NSUTF8StringEncoding)
                print("TIME IS \(time)")
                GameSingleton.sharedInstance.setSelectImageParamsPrivate(self.cachedCountPrivate, imageSelectTime: Double(time)!)
            } catch {
                
            }
        }
        
        filePath = documentDirectoryURL.URLByAppendingPathComponent("shareTime.archive")
        if checkValidation.fileExistsAtPath(filePath.path!) {
            //print("CHECKED")
            do {
                let time = try String(contentsOfURL: filePath, encoding: NSUTF8StringEncoding)
                //print("TIME IS \(time)")
                GameSingleton.sharedInstance.setSelectImageParamsShared(self.cachedCountShare, imageSelectTime: Double(time)!)
            } catch {
                
            }
        }
        
        for i in 0..<cachedCountPrivate {
            let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            
            // create the destination url for the text file to be saved
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("privateimages\(i).archive")
            if checkValidation.fileExistsAtPath(filePath.path!) {
                let cachedImage = UIImage(contentsOfFile: filePath.path!)
                finalImages.append(cachedImage!)
            }
        }
        
        print(finalImages.count)
        if finalImages.count != 0 {
            //print("TOTAL PRIVATE COUNT \(finalImages.count)")
            GameSingleton.sharedInstance.setPrivatePictures(finalImages)
        }
        
        finalImages.removeAll()
        
        for i in 0..<cachedCountShare {
            let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            
            // create the destination url for the text file to be saved
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("sharedimages\(i).archive")
            if checkValidation.fileExistsAtPath(filePath.path!) {
                let cachedImage = UIImage(contentsOfFile: filePath.path!)
                finalImages.append(cachedImage!)
            }
        }
        
        if finalImages.count != 0 {
            //print("TOTAL SHARE COUNT \(finalImages.count)")
            GameSingleton.sharedInstance.setSharedPictures(finalImages)
        }
        
        //self.deleteOldFiles()
    }
    
    func reloadParams() {
        if Reachability.isConnectedToNetwork() {
            //Get blur radius and blur iterations from the server
            Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getGameParameters_ios.jsp").responseString { response in
                self.parseResponse(response.result.value!)
            }
            Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getCamouflageIndices.jsp").responseString { response in
                //self.parseResponse(response.result.value!)
                self.parseIndex(response.result.value!)
            }
            Alamofire.request(.GET, URLString: "http://130.126.138.38/PicturePasswords/getCorrectEntriesInMultipass.jsp").responseString { response in
                self.parseCorrectImages(response.result.value!)
            }
        } else {
            GameSingleton.sharedInstance.setValues(9, blurIter: 2)
            GameSingleton.sharedInstance.setCorrectImages(1)
            GameSingleton.sharedInstance.displayCurrentStatus()
        }
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        let pictureCount = finalImages.count
        
        if pictureCount < 4 && GameSingleton.sharedInstance.getPrivateCount() < 4 && GameSingleton.sharedInstance.getSharedCount() < 4 {
            playGameButton.enabled = false
            playGameButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            
        } else {
            if let picturesMeta = photosAccess {
                if picturesMeta == PRIVATE {
                    GameSingleton.sharedInstance.setPrivatePictures(finalImages)
                    finalImages.removeAll()
                    photosAccess = nil
                    let origImage = UIImage(named: "tick.png");
                    let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    selectPictureButton.setImage(tintedImage, forState: .Normal)
                    selectPictureButton.tintColor = UIColor.greenColor()
                } else {
                    GameSingleton.sharedInstance.setSharedPictures(finalImages)
                    finalImages.removeAll()
                    photosAccess = nil
                    let origImage = UIImage(named: "tick.png");
                    let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    sharePictureButton.setImage(tintedImage, forState: .Normal)
                    sharePictureButton.tintColor = UIColor.greenColor()
                }
                GameSingleton.sharedInstance.displayPictureCount()
            }
            
            let origImage = UIImage(named: "tick.png");
            let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            playGameButton.enabled = true
            playGameButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            playGameButton.setImage(tintedImage, forState: .Normal)
            playGameButton.tintColor = UIColor.greenColor()
        }
        
        //Check if there is any cached result
        checkCache()
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        let fileMgr = NSFileManager.defaultManager()
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        // create the destination url for the text file to be saved
        let filePath = documentDirectoryURL.URLByAppendingPathComponent("offlinedata.archive")
        if fileMgr.fileExistsAtPath(filePath.path!) {
            let dataArray = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath.path!) as! [String]
            //print("Found in file \(dataArray)")
            self.cacheArray = dataArray
            if (dataArray.count != 0) {
                let origImage = UIImage(named: "checked.png");
                let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                sendDataButton.setImage(tintedImage, forState: .Normal)
                sendDataButton.tintColor = UIColor.yellowColor()
                sendDataButton.enabled = true
            } else {
                sendDataButton.enabled = false
            }
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickImages(sender: AnyObject) {
        let imagePicker = RMImagePickerController()
        photosAccess = sender.tag
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
        
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        // create the destination url for the text file to be saved
        if photosAccess! == 0 {
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("privateCount.archive")
            print("PRIVATE COUNT \(assets.count)")
            let archiveCount = "\(assets.count)"
            do {
                try archiveCount.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Error")
            }
        } else {
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("sharedCount.archive")
            let archiveCount = "\(assets.count)"
            print("SHARE COUNT \(assets.count)")
            do {
                try archiveCount.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Error")
            }
        }
        
        let curTime = NSDate().timeIntervalSince1970
        let tmpStr = "\(curTime)"
        let count = assets.count
        
        if photosAccess! == 0 {
            GameSingleton.sharedInstance.setSelectImageParamsPrivate(count, imageSelectTime: curTime)
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("privateTime.archive")
            do {
                try tmpStr.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Error")
            }
        } else {
            GameSingleton.sharedInstance.setSelectImageParamsShared(count, imageSelectTime: curTime)
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("shareTime.archive")
            do {
            try tmpStr.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
            print("Error")
            }
        }
        
        finalImages.removeAll()
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        
        if assets.count >= 4 {
            for i in 0..<assets.count {
                let asset = assets[i]
                self.imageManager.requestImageForAsset(
                    asset,
                    targetSize: CGSize(width: 230, height: 140),
                    contentMode: PHImageContentMode.AspectFill,
                    options: options,
                    resultHandler: { (image, info) -> Void in
                    let resized = Toucan(image: image!).resize(CGSize(width: 230, height: 140), fitMode: Toucan.Resize.FitMode.Scale).image
                    self.finalImages.append(resized)
                        if self.photosAccess! == 0 {
                            self.saveToFilePrivate(resized, index: i)
                        } else {
                            self.saveToFileShared(resized, index: i)
                        }
                    })
            }
            sleep(1)
        }
        
        self.dismissPickerPopover()
        
        //Display alert and disable button
        if assets.count < 4 {
            let alertController = UIAlertController(title: "Error", message:
                "Please choose 4 or more pictures to start game", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func saveToFilePrivate(image: UIImage, index: Int) {
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        print("SAVING \(index)")
        let filePath = documentDirectoryURL.URLByAppendingPathComponent("privateimages\(index).archive")
        UIImageJPEGRepresentation(image,1.0)!.writeToURL(filePath, atomically: true)

    }
    
    func saveToFileShared(image: UIImage, index: Int) {
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        
        // create the destination url for the text file to be saved
        let filePath = documentDirectoryURL.URLByAppendingPathComponent("sharedimages\(index).archive")
        UIImageJPEGRepresentation(image,1.0)!.writeToURL(filePath, atomically: true)
        
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
            //print("Found in file \(dataArray)")
            GameSingleton.sharedInstance.setUserID(dataArray)
            return dataArray
        } else {
            userID = randomStringWithLength(32) as String
            GameSingleton.sharedInstance.setUserID(userID!)
            NSKeyedArchiver.archiveRootObject(userID!, toFile: fileURL.path!)
        }
        return userID
    }
    
    func getName() {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileMgr = NSFileManager.defaultManager()
        let fileURL = documentsURL.URLByAppendingPathComponent("username.archive")
        
        if fileMgr.fileExistsAtPath(fileURL.path!) {
            let dataArray = NSKeyedUnarchiver.unarchiveObjectWithFile(fileURL.path!) as! String
            print("Found in file \(dataArray)")
            self.username = dataArray
            GameSingleton.sharedInstance.setUserName(self.username!)
        } else {
            //Show the textfield for the username
            let alert = UIAlertController(title: "Enter Your First Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
                print("GETTING NAME \(self.tField.text)!")
                self.username = (self.tField.text)!
                NSKeyedArchiver.archiveRootObject((self.tField.text)!, toFile: fileURL.path!)
                GameSingleton.sharedInstance.setUserName(self.tField.text!)
            }))
            
            self.presentViewController(alert, animated: true, completion: {
            })
        }
    }
    
    // MARK: - Parse Response from Server
    func parseResponse(response: String) {
        let fullNameArr = response.characters.split{$0 == "\n"}.map(String.init)
        let blurRadVal = fullNameArr[0].characters.split{$0 == ":"}.map(String.init)
        let blurIterVal = fullNameArr[1].characters.split{$0 == ":"}.map(String.init)
        
        GameSingleton.sharedInstance.setValues(Int(blurRadVal[1])!, blurIter: Int(blurIterVal[1])!)
        GameSingleton.sharedInstance.displayCurrentStatus()
    }
    
    // MARK: - Parse for correct number of images per mosaic
    func parseCorrectImages(response: String) {
        let correctNum = response.characters.split{$0 == ":"}.map(String.init)
        let tmp = Int(correctNum[1])
        GameSingleton.sharedInstance.setCorrectImages(tmp!)
    }
    
    //MARK: - Parse Camouflage indices 
    func parseIndex(response: String) {
        let fullNameArr = response.characters.split{$0 == "\n"}.map(String.init)
        let chosenIndexMode = fullNameArr[0].characters.split{$0 == ":"}.map(String.init)
        let chosenIndices = fullNameArr[1].characters.split{$0 == ":"}.map(String.init)
        let intIndices = chosenIndices[1].characters.split{$0 == ","}.map(String.init)
        let numbersOptional = intIndices.reduce([Int]()) { acc, str in
            if let i = Int(str) {
                return acc + [i]
            }
            
            return acc
        }
        if chosenIndexMode[1] == "UseSpecified" {
            GameSingleton.sharedInstance.setIndices(numbersOptional)
        } else {
            let array = (0...299).map { $0 }
            GameSingleton.sharedInstance.setIndices(array)
        }
    }
    
    // MARK: - Check if there are entries in the cache and send to server if there are
    func checkCache() {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        _ = NSFileManager.defaultManager()
        let fileURL = documentsURL.URLByAppendingPathComponent("results.archive")
        if let tmpcache: [Readings] = NSKeyedUnarchiver.unarchiveObjectWithFile(fileURL.path!) as? [Readings] {
            let cache = tmpcache
            cacheCount = cache.count
            //print("IN CACHE \(cacheCount)")
            if cache.count > 0 {
                //TODO: - Send to server here
            }
        } 
    }
    
    func deleteOldFiles() {
        //Remove Images
        let filemgr = NSFileManager.defaultManager()
        for i in 0..<self.cachedCountPrivate {
            let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("privateimages\(i).archive")
            do {
                try filemgr.removeItemAtPath(filePath.path!)
            }
            catch {
                print("Error")
            }
            
        }
        
        for i in 0..<self.cachedCountShare {
            let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("sharedimages\(i).archive")
            do {
                try filemgr.removeItemAtPath(filePath.path!)
            }
            catch {
                print("Error")
            }
            
        }
        
        //Remove Cached Count
        var documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        var filePath = documentDirectoryURL.URLByAppendingPathComponent("privateCount.archive")
        do {
            try filemgr.removeItemAtPath(filePath.path!)
        }
        catch {
            print("Error")
        }
        
        documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        filePath = documentDirectoryURL.URLByAppendingPathComponent("sharedCount.archive")
        do {
            try filemgr.removeItemAtPath(filePath.path!)
        }
        catch {
            print("Error")
        }
        
        //Remove time
        filePath = documentDirectoryURL.URLByAppendingPathComponent("privateTime.archive")
        do {
            try filemgr.removeItemAtPath(filePath.path!)
        }
        catch {
            print("Error")
        }
        
        filePath = documentDirectoryURL.URLByAppendingPathComponent("shareTime.archive")
        do {
            try filemgr.removeItemAtPath(filePath.path!)
        }
        catch {
            print("Error")
        }
    }
    
    func sendCacheToServer(var cache: [String]) {
        let connected = Reachability.isConnectedToNetwork()
        for i in 0..<cache.count {
            if connected {
                let request = NSMutableURLRequest(URL: NSURL(string: "http://130.126.138.38/PicturePasswords/gameResult.jsp")!)
                request.HTTPMethod = "POST"
                request.HTTPBody = cache[i].dataUsingEncoding(NSUTF8StringEncoding)
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                    data, response, error in
                    
                    if error != nil {
                        print("error=\(error)")
                        return
                    }
                    
                    let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    //print("responseString = \(responseString)")
                }
                task.resume()
            }
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Error", message:
            "You have no data to send", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendCache(sender: AnyObject) {
        if cacheCount == 0 {
            showAlert()
        } else {
            performSegueWithIdentifier("showCacheOptions", sender: nil)
        }
    }

    
    //MARK: - Set up button format
    func setup() {
        // Do any additional setup after loading the view.
        let image = UIImage(named: "startbackground.png")
        backgroundImage = UIImageView(image: image)
        backgroundImage.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgroundImage)
        
        titlescreen.backgroundColor = UIColor.clearColor()
        self.view.bringSubviewToFront(titlescreen)
        self.view.bringSubviewToFront(selectPictureButton)
        self.view.bringSubviewToFront(sharePictureButton)
        self.view.bringSubviewToFront(playGameButton)
        self.view.bringSubviewToFront(sendDataButton)
        
        //Check if User ID exists in file, else create one
        userID = getID() as? String
        getName()
        
        selectPictureButton.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        selectPictureButton.layer.cornerRadius = 10.0
        selectPictureButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        selectPictureButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        selectPictureButton.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        let origImage = UIImage(named: "checked.png");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        selectPictureButton.setImage(tintedImage, forState: .Normal)
        selectPictureButton.tintColor = UIColor.yellowColor()
        selectPictureButton.tag = PRIVATE
        
        sharePictureButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        sharePictureButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        sharePictureButton.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        sharePictureButton.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.5)
        sharePictureButton.layer.cornerRadius = 10.0
        sharePictureButton.tag = SHARED
        
        playGameButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        playGameButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        playGameButton.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        playGameButton.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.5)
        playGameButton.layer.cornerRadius = 10.0
        
        sendDataButton.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.5)
        sendDataButton.layer.cornerRadius = 10.0
        sendDataButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        sendDataButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        sendDataButton.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        //sendDataButton.setImage(tintedImage, forState: .Normal)
        //sendDataButton.tintColor = UIColor.yellowColor()
    }
    
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.placeholder = "Enter an item"
        tField = textField
    }
    
    
    func handleCancel(alertView: UIAlertAction!)
    {
        print("Cancelled !!")
    }

}