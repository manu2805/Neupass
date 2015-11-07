//
//  MosaicViewController.swift
//  Neupass
//
//  Created by Manudeep N.s on 10/29/15.
//  Copyright (c) 2015 Manudeep Suresh. All rights reserved.
//

import UIKit
import Photos
import RMImagePicker
import Alamofire

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

extension UICollectionView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
            { _ in completion()}
    }
}

func randomSequenceGenerator(min min: Int, max: Int) -> () -> Int {
    var numbers: [Int] = []
    return {
        if numbers.count == 0 {
            numbers = Array(min ... max)
        }
        
        let index = Int(arc4random_uniform(UInt32(numbers.count)))
        return numbers.removeAtIndex(index)
    }
}

extension Array {
    func slice(args: Int...) -> Array {
        var s = args[0]
        var e = self.count - 1
        if args.count > 1 { e = args[1] }
        
        if e < 0 {
            e += self.count
        }
        
        if s < 0 {
            s += self.count
        }
        
        let count = (s < e ? e-s : s-e)+1
        let inc = s < e ? 1 : -1
        var ret = Array()
        
        var idx = s
        for var i=0;i<count;i++  {
            ret.append(self[idx])
            idx += inc
        }
        return ret
    }
}

class MosaicViewController: UIViewController, UICollectionViewDelegate, RAReorderableLayoutDataSource, RAReorderableLayoutDelegate {

    var camoIndex: [Int] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var imageManager = PHImageManager.defaultManager()
    
    var correctImageIndex: [Int] = []
    var chosenImageIndex: Int?
    var userImages: [Int] = []
    var assets: [UIImage] = []
    var correctImage: UIImage!
    var hashVal: NSData!
    var currImage = 0
    
    var blurRadius = 20
    var blurIterations = 1
    
    //Array of results
    var results: [Readings] = []
    var curResult: Readings!
    
    //Check if first load
    var firstTime = true
    
    //Scores
    var score: Int!
    var attempts: Int!
    
    //Camo Subset
    var camoSubset: [Int] = []
    
    //2 ends
    var start: Int! = 0
    var userCountChoice: Int!
    
    
    //Variables for new part
    var subsetChosenImage: [Int] = []
    var currSubset: [Int] = []
    var front = 0
    var tracker = 0
    var multipleTapCount = 0
    var shouldReturn = false
    var iterations: Int!
    var currIterations: Int = 0
    
    //DEvice
    var IMAGE_SIZE_WIDTH: Double!
    var IMAGE_SIZE_HEIGHT: Double!
    
    //Offline Data
    var offline: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Rotate screen

        self.title = "RAReorderableLayout"
        let nib = UINib(nibName: "verticalCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.scrollEnabled = false
        
        self.blurRadius = GameSingleton.sharedInstance.blurRadVal()
        self.blurIterations = GameSingleton.sharedInstance.blurIterVal()
        
        //print(camoIndex)
    }
    
    override func viewWillAppear(animated: Bool) {        
        // Do any additional setup after loading the view.
        let value = UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        camoIndex.shuffleInPlace()
        
        curResult = Readings()
        let tmp = GameSingleton.sharedInstance.getGameMode()
        if tmp == GameModes.User {
            navigationItem.title = "User"
        } else if tmp == GameModes.Roommate {
            navigationItem.title = "Roommate"
        } else if tmp == GameModes.RoommateVsUser {
            navigationItem.title = "Roommate vs User"
        } else if tmp == GameModes.FriendVsUser {
            navigationItem.title = "Friends vs User"
        } else if tmp == GameModes.FriendVsRoommate {
            navigationItem.title = "Friends vs Roommate"
        } else if tmp == GameModes.StrangerVsUser {
            navigationItem.title = "Stranger vs User"
        } else {
            navigationItem.title = "Stranger vs Shared"
        }
        firstTime = true
        start = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        score = 0
        attempts = 0
        results.removeAll()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        //print("Cache \(results.count) count")
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("results.archive")
        NSKeyedArchiver.archiveRootObject(results, toFile: fileURL.path!)
        //print(fileURL.path!)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(25, -5, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //camoIndex.shuffleInPlace()
        currIterations = currIterations + 1
        
        correctImageIndex.removeAll()
        shouldReturn = false
        
        camoSubset.removeAll()
        
        camoIndex.shuffleInPlace()
        if (start + 9) < camoIndex.count {
            camoSubset = camoIndex.slice(start, start + 9)
            start = start + 9
        } else {
            camoSubset = camoIndex.slice(start, camoIndex.count - 1)
            camoSubset += camoIndex.slice(0, 9)
            camoIndex.shuffleInPlace()
            start = Int(arc4random_uniform(UInt32(20)))
        }

        //print(camoSubset)
        
        
        let getRandom1 = randomSequenceGenerator(min: 0, max: 8)
        for _ in 0..<userCountChoice {
            let newPoint = getRandom1()
            correctImageIndex.append(newPoint)
        }
        
        if userCountChoice > 1 {
            if (front + (userCountChoice - 1)) < assets.count {
                currSubset = subsetChosenImage.slice(front, front +  (userCountChoice - 1))
                front = front + userCountChoice
                shouldReturn = false
            } else {
                subsetChosenImage.shuffleInPlace()
                currSubset += subsetChosenImage.slice(0, userCountChoice)
                front = 0
                shouldReturn = true
            }
        }
        
        tracker = 0
        //print("CHOSEN MAN \(correctImageIndex)")
        print("CHOSEN \(correctImageIndex)")
        print("CAMO \(camoSubset)")
        return 9

    }
    
    func randRange (lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let recognizers = collectionView.gestureRecognizers {
            for recognizer in recognizers {
                collectionView.removeGestureRecognizer(recognizer)
            }
        }
        
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("verticalCell", forIndexPath: indexPath) as! RACollectionViewCell
        let tapGesture = UILongPressGestureRecognizer(target: self, action: "imageTapped:")
        tapGesture.minimumPressDuration = 0.01
        cell.addGestureRecognizer(tapGesture)
        cell.imageView.image = nil
        
        var tmpImg: UIImage!
        //print(assets.count)
        if correctImageIndex.contains(indexPath.item) {
            let tmp = GameSingleton.sharedInstance.getGameMode()
            if userCountChoice == 1 {
                if (tmp == GameModes.RoommateVsUser || tmp == GameModes.FriendVsUser || tmp == GameModes.FriendVsRoommate || tmp == GameModes.StrangerVsShared || tmp == GameModes.StrangerVsUser) {
                    tmpImg = assets[userImages[currImage]]
                } else {
                    tmpImg = assets[userImages[0]]
                }
            } else {
                    let hold = currSubset[tracker]
                    tmpImg = assets[hold]
                    ++tracker
            }
            
            //print(tmpImg.imageOrientation.rawValue)
            /*if tmpImg.imageOrientation.rawValue == 3 {
                tmpImg = tmpImg.imageRotatedByDegrees(90, flip: false)
            }*/
            correctImage = tmpImg
            var resized = Toucan(image: tmpImg).resize(CGSize(width: IMAGE_SIZE_WIDTH, height: IMAGE_SIZE_HEIGHT), fitMode: Toucan.Resize.FitMode.Scale).image
            for _ in 0..<2 {
                resized = blurWithCoreImage(resized)
            }
            cell.imageView.image = resized
        } else {
            var tmp = camoSubset[indexPath.item]
            if (tmp >= camoImage.count) {
                while(true) {
                    tmp = Int(arc4random_uniform(300))
                    if camoSubset.contains(tmp) {
                        continue
                    } else {
                        break
                    }
                }
            }
            let tmpImg = camoImage[tmp]
            let resized = Toucan(image: tmpImg).resize(CGSize(width: IMAGE_SIZE_WIDTH, height: IMAGE_SIZE_HEIGHT), fitMode: Toucan.Resize.FitMode.Scale).image
            //cell.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.imageView.image = blurWithCoreImage(resized)
        }

        return cell
    }
    
    func blurWithCoreImage(sourceImage: UIImage) -> UIImage {
        let ciContext = CIContext(options: nil)
        let ciImage = CIImage(image: sourceImage)
        let ciFilter = CIFilter(name: "CIGaussianBlur")
        ciFilter!.setValue(ciImage, forKey: kCIInputImageKey)
        //ciFilter!.setValue(Double(GameSingleton.sharedInstance.blurRadVal())/2.5, forKey: "inputRadius")
        ciFilter!.setValue(GameSingleton.sharedInstance.blurRadVal(), forKey: "inputRadius")
        let cgImage = ciContext.createCGImage(ciFilter!.outputImage!, fromRect: ciImage!.extent)
        let blurredImage = UIImage(CGImage: cgImage)
        return blurredImage
    }
    
    
    func collectionView(collectionView: UICollectionView, allowMoveAtIndexPath indexPath: NSIndexPath) -> Bool {
        if collectionView.numberOfItemsInSection(indexPath.section) <= 1 {
            return false
        }
        return true
    }
    
    func scrollTrigerEdgeInsetsInCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)
    }
    
    func collectionView(collectionView: UICollectionView, reorderingItemAlphaInSection section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }
    
    func imageTapped(tapGesture: UITapGestureRecognizer) {
        curResult?.tapTime = NSDate().timeIntervalSince1970 - (curResult?.showTime)!
        
        let tapLocation = tapGesture.locationInView(self.collectionView)
        let indexPath = self.collectionView.indexPathForItemAtPoint(tapLocation)
        let chosenImageIndex = indexPath?.item
        
        //Set parameters after tapping image
        if tapGesture.state == .Began {
            //curResult?.tapTime = NSDate().timeIntervalSince1970 - (curResult?.showTime)!
            ++multipleTapCount
            //print("TAPPED")
            //print("MULTIPLE TAP \(multipleTapCount)")
            curResult?.tapPosition = chosenImageIndex
            curResult?.correctPosition = correctImageIndex[0]
            
            attempts = attempts + 1
            if correctImageIndex.contains(chosenImageIndex!)  {
                score = score! + 1
                curResult?.correct = 1
                sendResult()
            } else {
                curResult?.correct = 0
                sendResult()
            }
            
            // Prevent repeating within 3
            if userCountChoice == 1 {
                let curr = userImages[0]
                let tmpMode = GameSingleton.sharedInstance.getGameMode()
                if (tmpMode == GameModes.User || tmpMode == GameModes.Roommate) {
                    userImages.removeAtIndex(0)
                    let newIndex = randRange(2, upper: userImages.count)
                    if newIndex == userImages.count {
                        userImages.append(curr)
                    } else {
                        userImages.insert(curr, atIndex: newIndex)
                    }
                }
                currImage++
            
    
                let tmp = GameSingleton.sharedInstance.getGameMode()
                if (tmp == GameModes.RoommateVsUser || tmp == GameModes.FriendVsUser || tmp == GameModes.FriendVsRoommate || tmp == GameModes.StrangerVsShared || tmp == GameModes.StrangerVsUser) && (currImage == assets.count) {
                    currImage = 0
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData {
                        self.curResult = Readings()
                    }
                })
            } else {
                //print("MULTIPLE IMAGES")
                let tmp = GameSingleton.sharedInstance.getGameMode()
                if (tmp == GameModes.RoommateVsUser || tmp == GameModes.FriendVsUser || tmp == GameModes.FriendVsRoommate || tmp == GameModes.StrangerVsShared || tmp == GameModes.StrangerVsUser) &&  (currIterations == iterations) && (multipleTapCount == userCountChoice) {
                    let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! RACollectionViewCell
                    cell.removeGestureRecognizer(tapGesture)
                    tracker = 0
                    front = 0
                    sendMultipleChoice(self.currSubset, positions: correctImageIndex)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                if (multipleTapCount != userCountChoice) {
                    //print("NOT YET")
                    let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! RACollectionViewCell
                    cell.imageView.image = nil
                    cell.imageView.image = UIImage(named: "checked.jpg")
                    cell.removeGestureRecognizer(tapGesture)
                } else if (multipleTapCount == userCountChoice) {
                    multipleTapCount = 0
                    let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! RACollectionViewCell
                    cell.removeGestureRecognizer(tapGesture)
                    sleep(1)
                    sendMultipleChoice(self.currSubset, positions: correctImageIndex)
                    //sleep(1)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.collectionView.reloadData {
                            self.curResult = Readings()
                        }
                    })
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: IMAGE_SIZE_WIDTH, height: IMAGE_SIZE_HEIGHT)
        return size
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    // MARK: - Send result to server
    func sendResult() {
        var URLString: String!
        let connected = Reachability.isConnectedToNetwork()
        
        let timeConvert = (curResult?.showTime!)! * 1000
        let timeConvert1 = Int((curResult?.tapTime!)! * 1000)
        let timeConvert2 = Int((curResult?.keyTimings![0])! * 1000)
        let timeConvert3 = Int((curResult?.keyTimings![1])! * 1000)
        let timeConvert4 = Int((curResult?.keyTimings![2])! * 1000)
        let timeConvert5 = Int((curResult?.keyTimings![3])! * 1000)
        let timeConvert6 = Int((curResult?.keyTimings![4])! * 1000)
        
        let imageData = NSData(data: UIImageJPEGRepresentation(correctImage, 0.6)!)
        curResult?.hashVal = imageData.MD5Data()
        
        let tmpName = GameSingleton.sharedInstance.getUsername()
        if connected {
            let postString1 = "user_id=\((curResult?.userID!)!)&time=\(timeConvert)&response_time=\(timeConvert1)&correct=\((curResult?.correct!)!)&correct_position=\((curResult?.correctPosition!)!)"
            let postString2 = "&clicked_position=\((curResult?.tapPosition!)!)&total_selected_images=\((curResult?.totalSelectedImages!)!)&total_camouflage_images=\((curResult?.totalCamoImages!)!)&blur_radius=\((curResult?.blurRadius!)!)&blur_iterations=\((curResult?.blurIterations!)!)"
            let postString3 = "&time_year=\(timeConvert2)&time_year_1click=\(timeConvert3)&"
            let postString4 = "time_year_2click=\(timeConvert4)&time_year_3click=\(timeConvert5)"
            let postString5 = "&time_year_4click=\(timeConvert6)&time_images_selected=\((curResult?.imageSelectTime!)! * 1000)&os_type=2&play_mode=\((curResult?.playMode)!)&password_image=\((curResult?.hashVal)!)&user_name=\(tmpName)&num_correct_images=\(userCountChoice)"
            
            let finalString = postString1 + postString2 + postString3 + postString4 + postString5
            //print(finalString)
            URLString = finalString
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://130.126.138.38/PicturePasswords/gameResult.jsp")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = finalString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
        
            if error != nil {
                print("error=\(error)")
                return
            }
        
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            }
            task.resume()
        } else {
            offline.append(URLString)
        }
        
        if offline.count != 0 {
            let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            // create the destination url for the text file to be saved
            let filePath = documentDirectoryURL.URLByAppendingPathComponent("offlinedata.archive")
            NSKeyedArchiver.archiveRootObject(offline, toFile: filePath.path!)
        }
    }
    
    func sendMultipleChoice(images: [Int], positions: [Int]) {
        let connected = Reachability.isConnectedToNetwork()
        
        let timeConvert = (curResult?.showTime!)! * 1000
        _ = Int((curResult?.tapTime!)! * 1000)
        let timeConvert2 = Int((curResult?.keyTimings![0])! * 1000)
        let timeConvert3 = Int((curResult?.keyTimings![1])! * 1000)
        let timeConvert4 = Int((curResult?.keyTimings![2])! * 1000)
        let timeConvert5 = Int((curResult?.keyTimings![3])! * 1000)
        let timeConvert6 = Int((curResult?.keyTimings![4])! * 1000)
        
        for i in 0..<userCountChoice {
            let currPos = positions[i]
            let imageData = NSData(data: UIImageJPEGRepresentation(assets[images[i]], 0.6)!)
            curResult?.hashVal = imageData.MD5Data()
        
            let tmpName = GameSingleton.sharedInstance.getUsername()
            if connected {
                let postString1 = "user_id=\((curResult?.userID!)!)&time=\(timeConvert)&response_time=\(0)&correct=\((curResult?.correct!)!)&correct_position=\(currPos)"
            let postString2 = "&clicked_position=-1&total_selected_images=\((curResult?.totalSelectedImages!)!)&total_camouflage_images=\((curResult?.totalCamoImages!)!)&blur_radius=\((curResult?.blurRadius!)!)&blur_iterations=\((curResult?.blurIterations!)!)"
            let postString3 = "&time_year=\(timeConvert2)&time_year_1click=\(timeConvert3)&"
            let postString4 = "time_year_2click=\(timeConvert4)&time_year_3click=\(timeConvert5)"
            let postString5 = "&time_year_4click=\(timeConvert6)&time_images_selected=\((curResult?.imageSelectTime!)! * 1000)&os_type=2&play_mode=\((curResult?.playMode)!)&password_image=\((curResult?.hashVal)!)&user_name=\(tmpName)&num_correct_images=\(userCountChoice)"
            
            let finalString = postString1 + postString2 + postString3 + postString4 + postString5
            print(finalString)
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://130.126.138.38/PicturePasswords/gameResult.jsp")!)
            request.HTTPMethod = "POST"
            request.HTTPBody = finalString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if error != nil {
                    print("error=\(error)")
                    return
                }
                
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString)")
            }
            task.resume()
            }
        }
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent == nil {
            let alert: UIAlertView = UIAlertView(title: "Done", message: "You scored \(score) out of \(attempts)", delegate: nil, cancelButtonTitle: "Cancel");
            alert.show()
        
            // Delay the dismissal by 5 seconds
            let delay = 5.0 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                alert.dismissWithClickedButtonIndex(-1, animated: true)
            })
        }
    }
}

class RACollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var color = UIColor.lightGrayColor()
    var gradientLayer: CAGradientLayer?
    var hilightedCover: UIView!
    override var highlighted: Bool {
        didSet {
            self.hilightedCover.hidden = !self.highlighted
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.hilightedCover.frame = self.bounds
        self.applyGradation(self.imageView)
    }
    
    private func configure() {
        self.imageView = UIImageView()
        self.imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(self.imageView)
        
        self.hilightedCover = UIView()
        self.hilightedCover.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.hilightedCover.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.hilightedCover.hidden = true
        self.addSubview(self.hilightedCover)
    }
    
    private func applyGradation(gradientView: UIView!) {
        self.gradientLayer?.removeFromSuperlayer()
        self.gradientLayer = nil
        
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer!.frame = gradientView.bounds
        
        let mainColor = UIColor(white: 0, alpha: 0.3).CGColor
        let subColor = UIColor.clearColor().CGColor
        self.gradientLayer!.colors = [subColor, mainColor]
        self.gradientLayer!.locations = [0, 1]
        
        gradientView.layer.addSublayer(self.gradientLayer!)
    }
}