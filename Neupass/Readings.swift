//
//  Readings.swift
//  Neupass
//
//  Created by Manudeep N.s on 10/31/15.
//  Copyright © 2015 Manudeep Suresh. All rights reserved.
//

import Foundation

class Readings: NSObject, NSCoding {
    var userID: String! // Check
    var showTime: Double! // Check
    var tapTime: Double! // Check
    var correct: Int! // Check
    var correctPosition: Int! //Check
    var tapPosition: Int! //Check
    var totalSelectedImages: Int! //Check
    var totalSharedImages: Int!
    var totalCamoImages: Int!
    var blurRadius: Int! //Check
    var blurIterations: Int! //Check
    
    //Timings for year
    var keyTimings: [Double]! //Check
    var imageSelectTime: Double! //Cheeck
    
    var deviceType: Int! //Check
    var playMode: Int! //Check
    var sharedCount: Int!
    var hashVal: NSString!
    
    override init() {
        userID = GameSingleton.sharedInstance.user()
        showTime = (NSDate().timeIntervalSince1970)
        totalSelectedImages = GameSingleton.sharedInstance.totalImages()
        keyTimings = GameSingleton.sharedInstance.yearTimings()
        totalCamoImages = GameSingleton.sharedInstance.getCamoCount()
        blurRadius = GameSingleton.sharedInstance.blurRadVal()
        blurIterations = GameSingleton.sharedInstance.blurIterVal()
        deviceType = 2
        playMode = GameSingleton.sharedInstance.getGameMode().hashValue + 1
        sharedCount = GameSingleton.sharedInstance.getSharedCount()
        let tmp = GameSingleton.sharedInstance.getGameMode().hashValue + 1
        if (tmp == 1 || tmp == 3 || tmp == 4 || tmp == 6) {
            imageSelectTime = GameSingleton.sharedInstance.getPrivateTime()
        } else {
            imageSelectTime = GameSingleton.sharedInstance.getShareTime()
        }
    }
    
    
    //MARK: - For inserting into plist
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userID, forKey:"userID")
        aCoder.encodeObject(showTime, forKey:"showTime")
        aCoder.encodeObject(tapTime, forKey:"tapTime")
        aCoder.encodeObject(correct, forKey:"correct")
        aCoder.encodeObject(correctPosition, forKey:"correctPosition")
        aCoder.encodeObject(tapPosition, forKey:"tapPosition")
        aCoder.encodeObject(totalSelectedImages, forKey:"totalSelectedImages")
        aCoder.encodeObject(totalCamoImages, forKey:"totalCamoImages")
        aCoder.encodeObject(blurRadius, forKey:"blurRadius")
        aCoder.encodeObject(blurIterations, forKey:"blurIterations")
        aCoder.encodeObject(keyTimings, forKey:"keyTimings")
        aCoder.encodeObject(imageSelectTime, forKey:"imageSelectTime")
        aCoder.encodeObject(deviceType, forKey:"deviceType")
        aCoder.encodeObject(sharedCount, forKey:"sharedCount")
        aCoder.encodeObject(hashVal, forKey:"hashVal")
    }
    
    
    required init (coder aDecoder: NSCoder) {
        self.userID = aDecoder.decodeObjectForKey("userID") as! String
        self.showTime = aDecoder.decodeObjectForKey("showTime") as! Double
        self.tapTime = aDecoder.decodeObjectForKey("tapTime") as! Double
        self.correct = aDecoder.decodeObjectForKey("correct") as! Int
        self.correctPosition = aDecoder.decodeObjectForKey("correctPosition") as! Int
        self.tapPosition = aDecoder.decodeObjectForKey("tapPosition") as! Int
        self.totalSelectedImages = aDecoder.decodeObjectForKey("totalSelectedImages") as! Int
        self.totalCamoImages = aDecoder.decodeObjectForKey("totalCamoImages") as! Int
        self.blurRadius = aDecoder.decodeObjectForKey("blurRadius") as! Int
        self.blurIterations = aDecoder.decodeObjectForKey("blurIterations") as! Int
        self.keyTimings = aDecoder.decodeObjectForKey("keyTimings") as! [Double]
        self.imageSelectTime = aDecoder.decodeObjectForKey("imageSelectTime") as! Double
        self.deviceType = aDecoder.decodeObjectForKey("deviceType") as! Int
        self.playMode = aDecoder.decodeObjectForKey("playMode") as! Int
        self.sharedCount = aDecoder.decodeObjectForKey("sharedCount") as! Int
        self.hashVal = aDecoder.decodeObjectForKey("hashVal") as! NSString
    }
}