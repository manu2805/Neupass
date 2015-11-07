//
//  CorrectPictureCountViewController.swift
//  Neupass
//
//  Created by Manudeep N.s on 11/5/15.
//  Copyright © 2015 Manudeep Suresh. All rights reserved.
//

import UIKit

class CorrectPictureCountViewController: UIViewController {

    @IBOutlet weak var singleCorrect: UIButton!
    @IBOutlet weak var multipleCorrect: UIButton!
    
    var backgroundImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let image = UIImage(named: "startbackground.png")
        backgroundImage = UIImageView(image: image)
        backgroundImage.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(backgroundImage)
        
        self.view.bringSubviewToFront(singleCorrect)
        self.view.bringSubviewToFront(multipleCorrect)
        
        singleCorrect.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        singleCorrect.layer.cornerRadius = 10.0
        singleCorrect.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        singleCorrect.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        singleCorrect.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        singleCorrect.tag = 0
        
        multipleCorrect.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 0.4)
        multipleCorrect.layer.cornerRadius = 10.0
        multipleCorrect.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        multipleCorrect.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        multipleCorrect.imageView!.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        multipleCorrect.tag = 1
        
        self.navigationController?.navigationBarHidden = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    @IBAction func chosenCount(sender: AnyObject) {
        print("CHOSEN MODE")
        GameSingleton.sharedInstance.setUserMosaicCount(sender.tag)
        print(GameSingleton.sharedInstance.getUserCountChosen())
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
