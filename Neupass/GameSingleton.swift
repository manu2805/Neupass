//
//  GameSingleton.swift
//  Neupass
//
//  Created by Manudeep N.s on 10/31/15.
//  Copyright (c) 2015 Manudeep Suresh. All rights reserved.
//

import Foundation
import Alamofire

class GameSingleton {
    static let sharedInstance = GameSingleton()
    
    //Properties for a single instance of the game
    private var gameScore: Int?
    private var gameHighScore: Int?
    private var blurRadius: Int?
    private var blurIterations: Int?
    private var userID: String?
    private var OS = 2
    private var totalImagesSelected: Int?
    private var imageSelectTime: NSDate?
    
    //Properties of the entering birth year view
    private var keyTimings: [NSDate] = []
    
    // METHODS
    private init() {
        self.gameScore = 0
        self.gameHighScore = 0
    }
    
    func setValues(blurRad: Int, blurIter: Int, userID: String) {
        self.blurRadius = blurRad
        self.blurIterations = blurIter
        self.userID = userID
    }
    
    func setSelectImageParams(totalImagesSelected: Int, imageSelectTime: NSDate) {
        self.totalImagesSelected = totalImagesSelected
        self.imageSelectTime = imageSelectTime
    }
    
    func setTimeForYear(keyTimings: [NSDate]) {
        self.keyTimings = keyTimings
        print(keyTimings)
    }
    
    func displayCurrentStatus() {
        print(self.blurRadius!)
        print(self.blurIterations!)
        print(self.userID!)
    }
    
    func blurRadVal() -> Int {
        return self.blurRadius!
    }
    
    func blurIterVal() -> Int {
        return self.blurIterations!
    }
    
    func totalImages() -> Int {
        return self.totalImagesSelected!
    }
    
    func imageTime() -> NSDate {
        return self.imageSelectTime!
    }
    
    func yearTimings() -> [NSDate] {
        return self.keyTimings
    }
    
    func user() -> String {
        return self.userID!
    }
    
    //Erase values when starting new game
    func clearOldVal() {
        self.keyTimings.removeAll()
    }
}