//
//  GameModesViewController.swift
//  Neupass
//
//  Created by Manudeep N.s on 11/1/15.
//  Copyright © 2015 Manudeep Suresh. All rights reserved.
//

import UIKit

class GameModesViewController: UIViewController {
    
    @IBOutlet weak var mode1: UIButton!
    @IBOutlet weak var mode2: UIButton!
    @IBOutlet weak var mode3: UIButton!
    @IBOutlet weak var mode4: UIButton!
    @IBOutlet weak var mode5: UIButton!
    @IBOutlet weak var mode6: UIButton!
    @IBOutlet weak var mode7: UIButton!
    
    @IBOutlet weak var header: UITextField!
    
    var backgroundImage: UIImageView!
    
    //Game Mode
    var chosenMode: Int!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func modeSelected(sender: AnyObject) {
        GameSingleton.sharedInstance.setGameMode(sender.tag)
        chosenMode = sender.tag
        var count: Int!
        if chosenMode == 1 {
            count = GameSingleton.sharedInstance.getPrivateCount()
        } else if chosenMode == 2 {
            count = GameSingleton.sharedInstance.getSharedCount()
        } else if chosenMode == 3 {
            count = GameSingleton.sharedInstance.getPrivateCount()
        } else if chosenMode == 4 {
            count = GameSingleton.sharedInstance.getPrivateCount()
        } else if chosenMode == 5 {
            count = GameSingleton.sharedInstance.getSharedCount()
        } else if chosenMode == 6 {
            count = GameSingleton.sharedInstance.getPrivateCount()
        } else if chosenMode == 7 {
            count = GameSingleton.sharedInstance.getSharedCount()
        }
        let tmp = GameSingleton.sharedInstance.getUserCountChosen()
        if count <  (tmp * 3){
            let alertController = UIAlertController(title: "Error", message:
                "Insufficient Images. Choose \(tmp * 3) or more to start", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            performSegueWithIdentifier("showKeyCode", sender: nil)
        }
    }
    
    func setup() {
        // Do any additional setup after loading the view.
        let image = UIImage(named: "startbackground.png")
        backgroundImage = UIImageView(image: image)
        backgroundImage.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgroundImage)
        
        mode1.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode1.layer.cornerRadius = 10.0
        mode1.tag = 1
        
        mode2.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode2.layer.cornerRadius = 10.0
        mode2.tag = 2
        
        mode3.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode3.layer.cornerRadius = 10.0
        mode3.tag = 3
        
        mode4.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode4.layer.cornerRadius = 10.0
        mode4.tag = 4
        
        mode5.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode5.layer.cornerRadius = 10.0
        mode5.tag = 5
        
        mode6.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode6.layer.cornerRadius = 10.0
        mode6.tag = 6
        
        mode7.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        mode7.layer.cornerRadius = 10.0
        mode7.tag = 7
        
        self.view.bringSubviewToFront(mode1)
        self.view.bringSubviewToFront(mode2)
        self.view.bringSubviewToFront(mode3)
        self.view.bringSubviewToFront(mode4)
        self.view.bringSubviewToFront(mode5)
        self.view.bringSubviewToFront(mode6)
        self.view.bringSubviewToFront(mode7)
        self.view.bringSubviewToFront(header)
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
