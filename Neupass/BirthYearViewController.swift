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
    
    // Timer 
    var start: NSDate?
    var keyPress1: NSDate?
    var keyPress2: NSDate?
    var keyPress3: NSDate?
    var keyPress4: NSDate?
    var keyTimings: [NSDate
    ] = []
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        start = NSDate()
        keyTimings.removeAll(keepCapacity: false)
        keyTimings.append(start!)
    }
    
    
    @IBAction func digitTapped(sender: AnyObject) {
        let tapTime = NSDate()
        ++digitCount
        if digitCount == 1 {
            circle1.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress1 = tapTime
            keyTimings.append(keyPress1!)
        } else if digitCount == 2 {
            circle2.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress2 = tapTime
            keyTimings.append(keyPress2!)
        } else if digitCount == 3 {
            circle3.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress3 = tapTime
            keyTimings.append(keyPress3!)
        } else if digitCount == 4 {
            circle4.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
            keyPress4 = tapTime
            keyTimings.append(keyPress4!)
            GameSingleton.sharedInstance.setTimeForYear(keyTimings)
            performSegueWithIdentifier("showMosaic", sender: nil)
        }
    }
    
    
    override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!) {
        if segue.identifier == "showMosaic" {
            let tmp = segue!.destinationViewController as! MosaicViewController
            tmp.assets = assets
            for i in 0..<16 {
                tmp.camoIndex.append(i)
            }
            for i in 0..<assets.count {
                tmp.userImages.append(i)
            }
        }
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
