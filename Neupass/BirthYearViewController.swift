//
//  BirthYearViewController.swift
//  Neupass
//
//  Created by Manudeep N.s on 10/29/15.
//  Copyright (c) 2015 Manudeep Suresh. All rights reserved.
//

import UIKit
import SpriteKit
import Photos
import RMImagePicker

class BirthYearViewController: UIViewController {

    @IBOutlet weak var yearLabel: UITextField!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var circle1: UIButton!
    @IBOutlet weak var circle2: UIButton!
    @IBOutlet weak var circle3: UIButton!
    @IBOutlet weak var circle4: UIButton!
    
    var backgroundImage: UIImageView!
    var digitCount = 0
    var assets: [UIImage] = []
    var hashVal: [Int] = []
    
    // Timer 
    var start: Double?
    var keyPress1: Double?
    var keyPress2: Double?
    var keyPress3: Double?
    var keyPress4: Double?
    var keyTimings: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set background image
        let image = UIImage(named: "startbackground.png")
        backgroundImage = UIImageView(image: image)
        backgroundImage.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgroundImage)
        
        //Set blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        view.addSubview(blurEffectView)
        
        //Format the label
        yearLabel.backgroundColor = UIColor.clearColor()
        yearLabel.borderStyle = UITextBorderStyle.None
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        self.view.bringSubviewToFront(yearLabel)
        
        setup()

    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        digitCount = 0
        circle1.backgroundColor = UIColor.clearColor()
        circle2.backgroundColor = UIColor.clearColor()
        circle3.backgroundColor = UIColor.clearColor()
        circle4.backgroundColor = UIColor.clearColor()
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        //Clear all the old values
        GameSingleton.sharedInstance.clearOldVal()
        
        //Get appropriate pictures
        assets = GameSingleton.sharedInstance.getPictures()
    }
    
    override func viewDidAppear(animated: Bool) {
        start = NSDate().timeIntervalSince1970
        keyTimings.removeAll(keepCapacity: false)
        keyTimings.append(start!)
    }
    
    
    @IBAction func digitTapped(sender: AnyObject) {
        let tapTime = (NSDate().timeIntervalSince1970)
        ++digitCount
        if digitCount == 1 {
            circle1.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress1 = tapTime
            keyPress1 = keyPress1! - start!
            print(keyPress1!)
            keyTimings.append(keyPress1!)
        } else if digitCount == 2 {
            circle2.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress2 = tapTime
            keyPress2 = keyPress2! - start!
            print(keyPress2!)
            keyTimings.append(keyPress2!)
        } else if digitCount == 3 {
            circle3.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress3 = tapTime
            keyPress3 = keyPress3! - start!
            keyTimings.append(keyPress3!)
        } else if digitCount == 4 {
            circle4.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress4 = tapTime
            keyPress4 = keyPress4! - start!
            keyTimings.append(keyPress4!)
            GameSingleton.sharedInstance.setTimeForYear(keyTimings)
            performSegueWithIdentifier("showMosaic", sender: nil)
        }
    }
    
    
    override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!) {
        if segue.identifier == "showMosaic" {
            let tmp = segue!.destinationViewController as! MosaicViewController
            
            print(UIScreen.mainScreen().bounds.height)
            if (UIScreen.mainScreen().bounds.height == 667.0) {
                tmp.IMAGE_SIZE_WIDTH = 221.0
                tmp.IMAGE_SIZE_HEIGHT = 118.0
            } else if (UIScreen.mainScreen().bounds.height == 736) {
                tmp.IMAGE_SIZE_WIDTH = 242.0
                tmp.IMAGE_SIZE_HEIGHT = 129.0
            }
            
            tmp.assets = GameSingleton.sharedInstance.getPictures()
            let chosenIndices = GameSingleton.sharedInstance.getIndices()
            print("LARGE \(chosenIndices.count)")
            for i in 0..<chosenIndices.count{
                tmp.camoIndex.append(chosenIndices[i])
            }
            for i in 0..<assets.count {
                tmp.userImages.append(i)
            }
            for i in 0..<assets.count {
                tmp.subsetChosenImage.append(i)
            }
            tmp.userCountChoice = GameSingleton.sharedInstance.getUserCountChosen()
            if (assets.count % tmp.userCountChoice == 0) {
                tmp.iterations = assets.count / tmp.userCountChoice
            } else {
                tmp.iterations = assets.count / tmp.userCountChoice + 1

            }
            
            tmp.camoIndex.shuffleInPlace()
            
            let userChoice = GameSingleton.sharedInstance.getGameMode()
            let correctCount = GameSingleton.sharedInstance.getUserCountChosen()
            if (userChoice == GameModes.RoommateVsUser || userChoice == GameModes.FriendVsUser || userChoice == GameModes.FriendVsRoommate || userChoice == GameModes.StrangerVsShared || userChoice == GameModes.StrangerVsUser) {
                if (assets.count % correctCount) != 0 {
                    for i in 0..<(correctCount - (assets.count % correctCount)) {
                        tmp.subsetChosenImage.append(i)
                    }
                }
            }

            print(tmp.subsetChosenImage)
        }
    }
    
    
    func setup() {
        button1.backgroundColor = UIColor.clearColor()
        button1.layer.cornerRadius = 0.5 * button1.bounds.size.width
        button1.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.blackColor().CGColor
        button1.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button1)
        
        button2.backgroundColor = UIColor.clearColor()
        button2.layer.cornerRadius = 0.5 * button2.bounds.size.width
        button2.layer.borderWidth = 1
        button2.layer.borderColor = UIColor.blackColor().CGColor
        button2.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button2)
        
        button3.backgroundColor = UIColor.clearColor()
        button3.layer.cornerRadius = 0.5 * button3.bounds.size.width
        button3.layer.borderWidth = 1
        button3.layer.borderColor = UIColor.blackColor().CGColor
        button3.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button3)
        
        button3.backgroundColor = UIColor.clearColor()
        button3.layer.cornerRadius = 0.5 * button3.bounds.size.width
        button3.layer.borderWidth = 1
        button3.layer.borderColor = UIColor.blackColor().CGColor
        button3.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button3)
        
        button4.backgroundColor = UIColor.clearColor()
        button4.layer.cornerRadius = 0.5 * button4.bounds.size.width
        button4.layer.borderWidth = 1
        button4.layer.borderColor = UIColor.blackColor().CGColor
        button4.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button4)
        
        button5.backgroundColor = UIColor.clearColor()
        button5.layer.cornerRadius = 0.5 * button5.bounds.size.width
        button5.layer.borderWidth = 1
        button5.layer.borderColor = UIColor.blackColor().CGColor
        button5.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button5)
        
        button6.backgroundColor = UIColor.clearColor()
        button6.layer.cornerRadius = 0.5 * button6.bounds.size.width
        button6.layer.borderWidth = 1
        button6.layer.borderColor = UIColor.blackColor().CGColor
        button6.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button6)
        
        button7.backgroundColor = UIColor.clearColor()
        button7.layer.cornerRadius = 0.5 * button7.bounds.size.width
        button7.layer.borderWidth = 1
        button7.layer.borderColor = UIColor.blackColor().CGColor
        button7.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button7)
        
        button8.backgroundColor = UIColor.clearColor()
        button8.layer.cornerRadius = 0.5 * button8.bounds.size.width
        button8.layer.borderWidth = 1
        button8.layer.borderColor = UIColor.blackColor().CGColor
        button8.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button8)
        
        button9.backgroundColor = UIColor.clearColor()
        button9.layer.cornerRadius = 0.5 * button9.bounds.size.width
        button9.layer.borderWidth = 1
        button9.layer.borderColor = UIColor.blackColor().CGColor
        button9.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button9)
        
        button0.backgroundColor = UIColor.clearColor()
        button0.layer.cornerRadius = 0.5 * button0.bounds.size.width
        button0.layer.borderWidth = 1
        button0.layer.borderColor = UIColor.blackColor().CGColor
        button0.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(button0)
        
        circle1.backgroundColor = UIColor.clearColor()
        circle1.enabled = false
        circle1.layer.cornerRadius = 0.5 * circle1.bounds.size.width
        circle1.layer.borderWidth = 1
        circle1.layer.borderColor = UIColor.blackColor().CGColor
        circle1.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(circle1)
        
        circle2.backgroundColor = UIColor.clearColor()
        circle2.enabled = false
        circle2.layer.cornerRadius = 0.5 * circle2.bounds.size.width
        circle2.layer.borderWidth = 1
        circle2.layer.borderColor = UIColor.blackColor().CGColor
        circle2.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(circle2)
        
        circle3.backgroundColor = UIColor.clearColor()
        circle3.enabled = false
        circle3.layer.cornerRadius = 0.5 * circle3.bounds.size.width
        circle3.layer.borderWidth = 1
        circle3.layer.borderColor = UIColor.blackColor().CGColor
        circle3.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(circle3)
        
        circle4.backgroundColor = UIColor.clearColor()
        circle4.enabled = false
        circle4.layer.cornerRadius = 0.5 * circle4.bounds.size.width
        circle4.layer.borderWidth = 1
        circle4.layer.borderColor = UIColor.blackColor().CGColor
        circle4.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0).CGColor
        self.view.bringSubviewToFront(circle4)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
