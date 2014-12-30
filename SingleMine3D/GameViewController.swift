//
//  GameViewController.swift
//  SingleMine3D
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
    var game:SimonSays?
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var startAgainButton: UIButton!
    
    var scnView: SCNView?
    var movesArray:[Int] = []
    
    var gameActive:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameActive = false
        
        //self.game = Game() as Game
        self.game = SimonSays() as SimonSays
        
        self.scnView = SCNView()
        self.scnView?.frame = self.view.frame
        
        self.scnView?.scene = self.game
        self.scnView?.backgroundColor = UIColor.blackColor()
        self.scnView?.autoenablesDefaultLighting = true
        //self.scnView?.allowsCameraControl = true
        
        self.view.insertSubview(self.scnView!, atIndex: 0)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        if let existingGestureRecognizers = self.scnView?.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        self.scnView?.gestureRecognizers = gestureRecognizers
        
        
        self.highscoreLabel.text = "HIGHSCORE: " + String(self.savedHighestLevel)
        self.highscoreLabel.font = UIFont(name: "Dosis-SemiBold", size: 14)
        self.levelLabel.text = "LEVEL: " + String(self.currentLevel)
        self.levelLabel.font = UIFont(name: "Dosis-SemiBold", size: 14)
        
        startAgainButton.hidden = false
        
        self.loadAds()
        
        self.authGameCenter()
        //createRandom()
        
        //animationSequence()
    }
    
    @IBAction func startAgain(sender: UIButton) {
        self.playAgain(true)
    }
    
    @IBAction func showLeaderboard(sender: UIButton) {
        var gameCenterVC:GKGameCenterViewController = GKGameCenterViewController()
        gameCenterVC.gameCenterDelegate = self
        self.presentViewController(gameCenterVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //do nothing
        })
    }
    
    func win(){
        self.game?.updateText("CONGRATS!", color:UIColor.whiteColor())
        self.currentLevel++
        self.levelLabel.text = "LEVEL: " + String(self.currentLevel)
        
        self.game?.looseAnimation(true)
        
        animationSequence()
        
        
    }
    
    func loose(){
        self.game?.updateText("GAME OVER!", color:UIColor.redColor())
        self.currentLevel = 0;
        self.levelLabel.text = "LEVEL: " + String(self.currentLevel)
        
        startAgainButton.hidden = false
        
        self.game?.looseAnimation(false)
        
        self.gameActive = false
        
    }
    
    func playAgain(firstTime:Bool){
        if(firstTime == true){
            self.game?.updateText("PAY ATTENTION!", color:UIColor.whiteColor())
        }else{
            self.game?.updateText("PLAY AGAIN!", color:UIColor.whiteColor())
        }
        
        self.gameActive = true
        
        startAgainButton.hidden = true
        self.currentLevel = 0;
        animationSequence()
        
        
    }
    
    func animationSequence(){
        
        //self.playAgain()
        
        self.movesArray = []
        
        self.game?.startOver()
        
        for i in 0...self.currentLevel {
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(i+1), target: self.game!, selector:  Selector("randomAnimationSequence"), userInfo: nil, repeats: false)
        }
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
        //self.randonLabel.text = String(str)
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
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = self.scnView?.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                if(self.gameActive == true && self.game?.gameActive == true){
                    self.buttonWasTapped(result.node!)
                }
                
                
            }
        }
    }
    
    
    func checkMoves() -> Bool{
        if(self.movesArray[self.movesArray.count-1] != self.game?.movesArray[self.movesArray.count-1]){
            return false
        }else{
            return true
        }

    }
    
    func buttonWasTapped(node:SCNNode){
        var buttonName = node.name
        var splitted: [String] = buttonName!.componentsSeparatedByString("sphere")
        var buttonNum = (splitted[1] as String).toInt()
        self.movesArray.append(buttonNum!)
        
        var winOrLoose = self.checkMoves()
        
        if(winOrLoose == false){
            self.loose()
        }
        
        if(winOrLoose == true && self.movesArray.count == self.game?.movesArray.count){
            self.win()
        }
        
        //animate and flash color red if loose and green if won
        self.game?.animateNode(node, win: winOrLoose)
        
        
        //createRandom()
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
