//
//  GameViewController.swift
//  game2
//
//  Created by John Tubert on 12/19/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameKit
import iAd

class GameViewController: UIViewController, GKGameCenterControllerDelegate, ADBannerViewDelegate {
    
    var sphereNode:SCNNode?
    var sphereNode2:SCNNode?
    var sphereNode3:SCNNode?
    var scene:SCNScene?
    
    var randomNum:UInt32?
    var currentLevel:Int = 0;
    var canUseGameCenter:Bool?
    var leaderboardIdentifier:String?
    var adBannerView:ADBannerView!
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var randonLabel: UILabel!
    
    @IBOutlet weak var scnView: SCNView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let scnView = self.view as SCNView
        let scene = Game()
        
        
        self.scnView?.scene = scene
        self.scnView?.backgroundColor = UIColor.blackColor()
        self.scnView?.autoenablesDefaultLighting = true
        //self.scnView?.allowsCameraControl = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        if let existingGestureRecognizers = self.scnView?.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        self.scnView?.gestureRecognizers = gestureRecognizers
        
        
        //self.messageLabel.text = "READY?"
        //self.messageLabel.font = UIFont(name: "Dosis-SemiBold", size: 16)
        self.highscoreLabel.text = "HIGHSCORE: " + String(self.savedHighestLevel)
        self.highscoreLabel.font = UIFont(name: "Dosis-SemiBold", size: 14)
        self.levelLabel.text = "LEVEL: " + String(self.currentLevel)
        self.levelLabel.font = UIFont(name: "Dosis-SemiBold", size: 14)
        //self.welcomeLabel.font =  UIFont(name: "Dosis-SemiBold", size: 16)
        //self.instructionsLabel.font =  UIFont(name: "Dosis-SemiBold", size: 14)
        
        self.loadAds()
        self.authGameCenter()
        createRandom()
    }
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //do nothing
        })
    }
    
    func win(){
        //self.messageLabel.text = "CONGRATS!"
        self.currentLevel++
        
        self.levelLabel.text = "LEVEL: " + String(self.currentLevel)
    }
    
    func loose(){
        //self.messageLabel.text = "GAME OVER!"
        //self.messageLabel.textColor = UIColor.redColor()
        self.currentLevel = 0;
        
        self.levelLabel.text = "LEVEL: " + String(self.currentLevel)
    }
    
    func playAgain(){
        //self.messageLabel.text = "PLAY AGAIN!"
        //self.messageLabel.textColor = UIColor.blackColor()
        
        //button1?.enabled = true;
        //button2?.enabled = true;
        //button3?.enabled = true;
    }

    
    var savedHighestLevel : Int {
        get {
            var returnValue: Int? = NSUserDefaults.standardUserDefaults().objectForKey("savedHighestLevel") as? Int
            if returnValue == nil //Check for first run of app
            {
                returnValue = 0 //Default value
            }
            return returnValue!
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "savedHighestLevel")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func updateHighScore(){
        if(self.currentLevel > self.savedHighestLevel){
            self.savedHighestLevel = self.currentLevel
            self.highscoreLabel.text = "HIGHSCORE: " + String(self.currentLevel)
            
            self.updateScore(self.currentLevel)
        }
    }
    
    func createRandom(){
        randomNum = arc4random_uniform(3) + 1
        var str:Int = Int(randomNum!)
        self.randonLabel.text = String(str)
    }
    
    func getHighScore(){
        
        var leaderboard:GKLeaderboard = GKLeaderboard()
        leaderboard.identifier = self.leaderboardIdentifier
        
        leaderboard.loadScoresWithCompletionHandler { (obj:[AnyObject]!, error:NSError!) -> Void in
            //println(leaderboard.localPlayerScore.value)
            if(leaderboard.localPlayerScore != nil){
                var score:Int = Int(leaderboard.localPlayerScore.value)
                
                self.updateScore(score)
                self.highscoreLabel.text = "HIGHSCORE: " + String(score)
            }
            
        }
        
    }
    
    func authGameCenter(){
        var localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler={(var gameCenterVC:UIViewController!, var gameCenterError:NSError!) -> Void in
            if gameCenterVC != nil {
                self.presentViewController(gameCenterVC, animated: true, completion: { () -> Void in
                    
                })
            }
            else if localPlayer.authenticated == true {
                self.canUseGameCenter = true
                println("authenticated!!!")
                println(localPlayer.alias)
                
                //self.messageLabel.text = "READY "+localPlayer.alias.uppercaseString+"?"
                
                
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier : String!, error : NSError!) -> Void in
                    if error != nil {
                        println(error.localizedDescription)
                    } else {
                        self.leaderboardIdentifier = leaderboardIdentifier
                        println(leaderboardIdentifier)
                        
                        self.getHighScore()
                    }
                })
                
            } else  {
                self.canUseGameCenter = false
                println("NOT authenticated")
            }
            
            if gameCenterError != nil {
                println("Game Center error: \(gameCenterError)")
            }
        }
    }
    
    func updateScore(score:Int){
        if(self.leaderboardIdentifier != nil){
            var scoreObj:GKScore = GKScore(leaderboardIdentifier: self.leaderboardIdentifier)
            scoreObj.value = Int64(score)
            scoreObj.context = 0
            
            GKScore.reportScores([scoreObj], withCompletionHandler: {(error) -> Void in
                println("Score updated")
            })
        }
        
    }
    
    func loadAds(){
        self.adBannerView = ADBannerView(frame: CGRect.zeroRect)
        self.adBannerView.center = CGPoint(x: self.adBannerView.center.x, y: view.bounds.size.height - self.adBannerView.frame.size.height / 2)
        self.adBannerView.delegate = self
        //self.adBannerView.hidden = true
        view.addSubview(self.adBannerView)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!){
        self.adBannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        if(error != nil){
            self.adBannerView.hidden = true
        }else{
            self.adBannerView.hidden = false
        }
    }

    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        //let scnView = self.view as SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = self.scnView?.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                //println(result.node.name)
                
                self.buttonWasTapped(result.node.name!)
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = UIColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.redColor()
                
                SCNTransaction.commit()
            }
        }
    }
    
    func buttonWasTapped(buttonName:String){
        if(buttonName == "sphere1"){
            //println("Button 1")
            if(randomNum == 1){
                //button1?.backgroundColor = UIColor.greenColor()
                win()
            }else{
                //button1?.backgroundColor = UIColor.redColor()
                loose()
            }
            
        }
        
        if(buttonName == "sphere2"){
            //println("Button 2")
            if(randomNum == 2){
                //button2?.backgroundColor = UIColor.greenColor()
                win()
            }else{
                //button2?.backgroundColor = UIColor.redColor()
                loose()
            }
        }
        
        if(buttonName == "sphere3"){
            //println("Button 3")
            if(randomNum == 3){
                //button3?.backgroundColor = UIColor.greenColor()
                win()
            }else{
                //button3?.backgroundColor = UIColor.redColor()
                loose()
            }
        }
        
        createRandom()
        updateHighScore()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
