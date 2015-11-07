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
    private var privateSelectTime: Double?
    private var shareSelectTime: Double?
    private var imageShareTime: Double?
    private var correctPerMosaic: Int?
    private var userCountChosen: Int?
    
    //Properties of the entering birth year view
    private var keyTimings: [Double] = []
    
    //Images Chosen
    private var privatePictures: [UIImage] = []
    private var sharedPictures: [UIImage] = []
    
    //Game Mode
    private var chosenMode: GameModes!
    
    //Camouflage indices
    private var indices: [Int] = []
    
    //Name of User
    private var userName: String!
    
    // METHODS
    private init() {
        self.gameScore = 0
        self.gameHighScore = 0
    }
    
    func setValues(blurRad: Int, blurIter: Int) {
        self.blurRadius = blurRad
        self.blurIterations = blurIter
    }
    
    func setUserID(userID: String) {
        self.userID = userID
    }
    
    func setUserName(username: String) {
        self.userName = username
    }
    
    func setCorrectImages(correctCount: Int) {
        self.correctPerMosaic = correctCount
    }
    
    func setPrivatePictures(privatePictures: [UIImage]) {
        self.privatePictures.removeAll()
        self.privatePictures = privatePictures
        print("IN SINGLETON \(self.privatePictures.count)")
    }

    func setSharedPictures(sharedPictures: [UIImage]) {
        self.sharedPictures.removeAll()
        self.sharedPictures = sharedPictures
    }
    
    func setGameMode(tag: Int) {
        switch(tag) {
        case 1:
            chosenMode = GameModes.User
        case 2:
            chosenMode = GameModes.Roommate
        case 3:
            chosenMode = GameModes.RoommateVsUser
        case 4:
            chosenMode = GameModes.FriendVsUser
        case 5:
            chosenMode = GameModes.FriendVsRoommate
        case 6:
            chosenMode = GameModes.StrangerVsUser
        case 7:
            chosenMode = GameModes.StrangerVsShared
        default:
            chosenMode = GameModes.User
        }

    }
    
    func getPrivatePictures() -> [UIImage] {
        return self.privatePictures
    }
    
    func getSharedPictures() -> [UIImage] {
        return self.sharedPictures
    }
    
    func setSelectImageParamsPrivate(totalImagesSelected: Int, imageSelectTime: Double) {
        self.totalImagesSelected = totalImagesSelected
        self.privateSelectTime = imageSelectTime
    }
    
    func setSelectImageParamsShared(totalImagesSelected: Int, imageSelectTime: Double) {
        self.totalImagesSelected = totalImagesSelected
        self.shareSelectTime = imageSelectTime
    }
    
    func setTimeForYear(keyTimings: [Double]) {
        self.keyTimings = keyTimings
        print(keyTimings)
    }
    
    func setIndices(indices: [Int]) {
        self.indices = indices
    }
    
    func setUserMosaicCount(index: Int) {
        if index == 0 {
            self.userCountChosen = 1
        } else {
            self.userCountChosen = self.correctPerMosaic
        }
    }
    
    func getIndices() -> [Int] {
        return self.indices
    }
   
    func printIndexCount() {
        print(self.indices.count)
    }
    
    func displayCurrentStatus() {
        //print(self.blurRadius!)
        //print(self.blurIterations!)
        //print(self.userID!)
    }
    
    func displayPictureCount() {
        print("PRIVATE \(self.privatePictures.count)")
        print("SHARED \(self.sharedPictures.count)")
    }
    
    func blurRadVal() -> Int {
        return self.blurRadius!
    }
    
    func blurIterVal() -> Int {
        return self.blurIterations!
    }
    
    func totalImages() -> Int {
        return self.privatePictures.count
    }
    
    func imageTime() -> Double {
        return self.privateSelectTime!
    }
    
    func yearTimings() -> [Double] {
        return self.keyTimings
    }
    
    func user() -> String {
        return self.userID!
    }
    
    //Func get appropriate picture
    func getPictures() -> [UIImage] {
        switch (chosenMode!) {
        case GameModes.User, GameModes.RoommateVsUser, GameModes.FriendVsUser, GameModes.StrangerVsUser:
            return privatePictures
        case GameModes.Roommate, GameModes.FriendVsRoommate, GameModes.StrangerVsShared:
            return sharedPictures
        }
    }
    
    func getSharedCount() -> Int {
        return sharedPictures.count
    }
    
    func getPrivateCount() -> Int {
        return privatePictures.count
    }
    
    func getUsername() -> String {
        return self.userName
    }
    
    //Erase values when starting new game
    func clearOldVal() {
        self.keyTimings.removeAll()
    }
    
    func getGameMode() -> GameModes{
        return self.chosenMode
    }
    
    func getCamoCount() -> Int {
        return indices.count
    }
    
    func getPrivateTime() -> Double {
        print(self.privateSelectTime)
        return self.privateSelectTime!
    }
    
    func getShareTime() -> Double {
        return self.shareSelectTime!
    }
    
    func correctPicture() -> Int {
        return self.correctPerMosaic!
    }
    
    func getUserCountChosen() -> Int {
        return self.userCountChosen!
    }
}