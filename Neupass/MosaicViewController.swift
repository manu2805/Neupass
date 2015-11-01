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

struct Readings {
    var userID: String? // Check
    var showTime: NSDate? // Check
    var tapTime: NSDate? // Check
    var correct: Bool? // Check
    var correctPosition: Int? //Check
    var tapPosition: Int? //Check
    var totalSelectedImages: Int? //Check
    var blurRadius: Int? //Check
    var blurIterations: Int? //Check
    
    //Timings for year
    var keyTimings: [NSDate]? //Check
    var imageSelectTime: NSDate? //Cheeck
    
    var deviceType: Int? //Check
    var playMode: Int? //Check
    
    init() {
        userID = GameSingleton.sharedInstance.user()
        showTime = NSDate()
        totalSelectedImages = GameSingleton.sharedInstance.totalImages()
        imageSelectTime = GameSingleton.sharedInstance.imageTime()
        keyTimings = GameSingleton.sharedInstance.yearTimings()
        blurRadius = GameSingleton.sharedInstance.blurRadVal()
        blurIterations = GameSingleton.sharedInstance.blurIterVal()
        deviceType = 2
        playMode = 1
    }
    
}

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

class MosaicViewController: UIViewController, UICollectionViewDelegate, RAReorderableLayoutDataSource, RAReorderableLayoutDelegate {

    var camoImage: [UIImage] = [
        UIImage(named: "camouflage1.jpg")!,
        UIImage(named: "camouflage2.jpg")!,
        UIImage(named: "camouflage3.jpg")!,
        UIImage(named: "camouflage4.jpg")!,
        UIImage(named: "camouflage5.jpg")!,
        UIImage(named: "camouflage6.jpg")!,
        UIImage(named: "camouflage7.jpg")!,
        UIImage(named: "camouflage8.jpg")!,
        UIImage(named: "camouflage9.jpg")!,
        UIImage(named: "camouflage10.jpg")!,
        UIImage(named: "camouflage11.jpg")!,
        UIImage(named: "camouflage12.jpg")!,
        UIImage(named: "camouflage13.jpg")!,
        UIImage(named: "camouflage14.jpg")!,
        UIImage(named: "camouflage15.jpg")!,
        UIImage(named: "camouflage16.jpg")!
    ]
    var camoIndex: [Int] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var imageManager = PHImageManager.defaultManager()
    
    var correctImageIndex: Int?
    var chosenImageIndex: Int?
    var userImages: [Int] = []
    var assets: [UIImage] = []
    var currImage = 0
    
    var score = 0
    var blurRadius = 20
    var blurIterations = 1
    
    //Array of results
    var results: [Readings] = []
    var curResult: Readings?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let value = UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        self.title = "RAReorderableLayout"
        let nib = UINib(nibName: "verticalCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.scrollEnabled = false
        
        self.blurRadius = GameSingleton.sharedInstance.blurRadVal()
        self.blurIterations = GameSingleton.sharedInstance.blurIterVal()
        
        self.collectionView.reloadData {
            self.curResult = Readings()
        }
    }

    override func viewDidAppear(animated: Bool) {

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
        return 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(25, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        camoIndex.shuffleInPlace()
        
        if currImage == 4 {
            //userImages = shuffle(userImages)
            print("shuffled")
            print(userImages)
            currImage = 0
        }

        correctImageIndex = Int(arc4random_uniform(9))
        return 9

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("verticalCell", forIndexPath: indexPath) as! RACollectionViewCell

        if indexPath.item == correctImageIndex {
            var tmpImg = assets[userImages[currImage]]
            tmpImg = blurWithCoreImage(tmpImg)
            cell.imageView.image = Toucan(image: tmpImg).resize(CGSize(width: 222, height: 118), fitMode: Toucan.Resize.FitMode.Crop).image
            currImage++
        } else {
            let tmp = camoIndex[indexPath.item]
            var tmpImg = camoImage[tmp]
            tmpImg = blurWithCoreImage(tmpImg)
            cell.imageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.imageView.image = Toucan(image: tmpImg).resize(CGSize(width: 222, height: 118), fitMode: Toucan.Resize.FitMode.Crop).image
        }

        return cell
    }
    
    func blurWithCoreImage(sourceImage: UIImage) -> UIImage {
        let ciContext = CIContext(options: nil)
        let ciImage = CIImage(image: sourceImage)
        let ciFilter = CIFilter(name: "CIGaussianBlur")
        ciFilter!.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter!.setValue(10, forKey: "inputRadius")
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
        chosenImageIndex = indexPath.item
        
        //Set parameters after tapping image
        curResult?.tapTime = NSDate()
        curResult?.tapPosition = chosenImageIndex
        curResult?.correctPosition = correctImageIndex
        
        if correctImageIndex == chosenImageIndex {
            ++score
            curResult?.correct = true
            print(curResult!)
            self.collectionView.reloadData {
                print("Done")
            }
            sendResult()
        } else {
            curResult?.correct = false
            print(curResult!)
            let alertController = UIAlertController(title: "Game Over", message:
                "Your score was \(score)", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction( title: "Return", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) -> Void in
                 self.navigationController!.popToRootViewControllerAnimated(false)
            }))
            score = 0;
            self.presentViewController(alertController, animated: true, completion: nil)
        }
       
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: 222, height: 118)
        return size
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
        let connected = Reachability.isConnectedToNetwork()
        let count = curResult?.keyTimings?.count
        print(count)
        if connected {
            let json = [ "user_id": curResult?.userID,
                         "time": curResult?.showTime,
                         "response_time": curResult?.tapTime,
                         "correct": curResult?.correct,
                         "correct_position": curResult?.correctPosition,
                         "clicked_position": curResult?.tapPosition,
                         "total_selected_images": curResult?.totalSelectedImages,
                         "blur_radius": curResult?.blurRadius,
                         "blur_iterations": curResult?.blurIterations,
                         "time_year": curResult?.keyTimings[0],
                         "time_year_1click": curResult?.keyTimings[1],
                         "time_year_2click": curResult?.keyTimings[2],
                         "time_year_3click": curResult?.keyTimings[3],
                         "time_year_4click": curResult?.keyTimings[4],
                         "time_images_selected": curResult?.imageSelectTime,
                         "os_type": curResult?.deviceType,
                         "play_mode": curResult?.playMode
                        ]
            
            let jsonData = NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted, error: nil)
            
            // create post request
            let url = NSURL(string: "http://httpbin.org/post")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // insert json data to the request
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data,response,error in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: nil) as? NSDictionary {
                        print(jsonResult)
                    }
                } catch {
                    print(error)
                }
            }
            
            task.resume()
        } else {
            print("Not connected")
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