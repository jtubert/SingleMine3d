//
//  SimonSays.swift
//  SimonSays
//
//  Created by John Tubert on 12/19/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

import UIKit
import SceneKit
import Darwin

/*
extension Array {
    func shuffled() -> [T] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
}
*/

class SimonSays: SCNScene {
    
    var titleText:SCNText?
    var titleNode:SCNNode?
    var sphereHolder:SCNNode?
    
    var timer:NSTimer?
    
    var movesArray:[Int]
    
    var gameActive:Bool?
    
    
    
    
    func initialize(){
        
        self.createCameraAndLights()
        
        self.sphereHolder = SCNNode()
        self.sphereHolder?.position = SCNVector3(x: -2.6, y: -2.0, z: 0)
        self.rootNode.addChildNode(self.sphereHolder!)
        
        
        
        
        self.createGrid()
        
        self.titleNode = self.createText()
        self.rootNode.addChildNode(self.titleNode!)
        
        self.gameActive = false
        
    }
    
    func createGrid(){
        var totalItems = 16
        var space=CGFloat(100)
        var gridW=CGFloat(600)
        
        var x = sqrt(CGFloat(totalItems))
        
        var column = CGFloat(ceilf(Float(x)))
        var scale=((gridW-(space*(column-1)))/column)
        
        //println(scale)
        
        for i in 0...totalItems-1 {
            var x:CGFloat=0.0
            var y:CGFloat=0.0
            
            if(i <= Int(column)-1){
                x=(((scale+space)*CGFloat(i)))
                y=0
            }else{
                x=(((scale+space)*(CGFloat(i)-(floor(CGFloat(i)/column))*column)))
                y=(((scale+space)*(floor(CGFloat(i)/column))))
            }
            
            var sphereNode = self.createSphere(i,pos: SCNVector3(x: Float(x/100), y: Float(y/100), z: 0))
            
            sphereNode.scale = SCNVector3(x: Float(scale/100), y: Float(scale/100), z: Float(scale/100))
            
            self.sphereHolder?.addChildNode(sphereNode)
        }
        
        
        
        let radius: Double = 4.0
        var z: Double = radius
        let theta: Double = (M_PI) / Double(totalItems / 2)
        let incrementalY: Double = (M_PI) / Double(totalItems) * 2
        
        for index in 1...totalItems {
            
            var x = radius * sin(Double(index) * theta)
            var z = radius * cos(Double(index) * theta)
            
            let node = self.sphereHolder?.childNodes[index-1] as SCNNode
            //let node = SCNNode(geometry: _geometry)
            node.position = SCNVector3(x: Float(x), y: 0, z:Float(z))
            let rotation = Float(incrementalY) * Float(index)
            node.rotation = SCNVector4(x: 0, y: 1, z: 0, w: rotation)
        }
        
        
        var pos = SCNAction.moveTo(SCNVector3(x: 0, y: 0.0, z: 0), duration: 0.5)
        var circleAction = SCNAction.rotateToX(0, y: 2, z: 0, duration: 2)
        var wait = SCNAction.waitForDuration(0.5)
        
        
        
        
        
        
        self.sphereHolder?.runAction(SCNAction.sequence([pos,circleAction,wait]), completionHandler: { () -> Void in
            
            for i in 0...totalItems-1 {
                var node = self.sphereHolder?.childNodes[i] as SCNNode
                var x:CGFloat=0.0
                var y:CGFloat=0.0
                
                if(i <= Int(column)-1){
                    x=(((scale+space)*CGFloat(i)))
                    y=0
                }else{
                    x=(((scale+space)*(CGFloat(i)-(floor(CGFloat(i)/column))*column)))
                    y=(((scale+space)*(floor(CGFloat(i)/column))))
                }
                
                
                
                node.runAction(SCNAction.moveTo(SCNVector3(x: Float(x/100), y: Float(y/100), z: 0), duration: 0.5))
                
                node.rotation = SCNVector4(x: 0, y: 1, z: 0, w: 0)
            }
        })
        
        var wait2 = SCNAction.waitForDuration(3.0)
        var pos2 = SCNAction.moveTo(SCNVector3(x: -2.6, y: -2.0, z: 0), duration: 0.5)
        var circleAction2 = SCNAction.rotateToX(0, y: 0, z: 0, duration: 0.5)
        
        
        self.sphereHolder?.runAction(SCNAction.sequence([wait2, pos2,circleAction2]))
        
        
        
        
    }
    
    func startOver(){
        self.movesArray = [Int]()
    }
    
    func randomAnimationSequence(){
        var randomNum:Int = Int(arc4random_uniform(15)) + 1
        
        self.movesArray.append(randomNum)
        
        println(self.movesArray)
        
        self.animateNode(self.sphereHolder?.childNodes[randomNum] as SCNNode, win: true)
    }
    
    func looseAnimation(win:Bool){
        for i in 0...15 {
            
            var node = self.sphereHolder?.childNodes[i] as SCNNode
            // get its material
            let material = node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.25)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.25)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            if(win == true){
                material.emission.contents = UIColor.greenColor()
            }else{
                material.emission.contents = UIColor.redColor()
            }
            
            
            SCNTransaction.commit()

        }
    }

    
    
    func createSphere(index:Int, pos:SCNVector3) -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.firstMaterial?.diffuse.contents = self.getRandomColor()
        let materials = SCNMaterial()
        //materials.diffuse.contents = UIImage(named: "planet1")//+String(index))
        //sphereGeometry.materials = [materials]
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = pos
        sphereNode.name = "sphere"+String(index)
        //sphereNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(2, y: 3, z: 0, duration: 5)))
        
        return sphereNode
    }
    
    func getRandomColor() -> UIColor{
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func updateText(s:String, color:UIColor){
        self.titleText?.string = s
        self.titleText?.firstMaterial?.diffuse.contents  = color
        
        var minVec = UnsafeMutablePointer<SCNVector3>.alloc(0)
        var maxVec = UnsafeMutablePointer<SCNVector3>.alloc(1)
        if (self.titleNode?.getBoundingBoxMin(minVec, max: maxVec) != nil) {
            let distance = SCNVector3(
                x: maxVec.memory.x - minVec.memory.x,
                y: maxVec.memory.y - minVec.memory.y,
                z: maxVec.memory.z - minVec.memory.z)
            
            self.titleNode?.pivot = SCNMatrix4MakeTranslation(distance.x / 2, distance.y / 2, distance.z / 2)
            minVec.dealloc(0)
            maxVec.dealloc(1)
        }
        
        var r = CGFloat(360/180.0 * M_PI)
        self.titleNode?.runAction(SCNAction.rotateByX(0, y: r, z: 0, duration: 0.5))
        //self.titleNode?.runAction(SCNAction.scaleTo(0.3, duration: 0.5))
        
        
        
        
    }
    
    func createCameraAndLights(){
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        self.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        self.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.lightGrayColor()
        self.rootNode.addChildNode(ambientLightNode)
    }
    
    func createText() -> SCNNode{
        self.titleText = SCNText(string: "Simon Says!", extrusionDepth: 0.8)
        self.titleText?.flatness = 0.1
        
        //titleText.containerFrame = CGRect(x: 100, y: 10, width: 200, height: 50)
        self.titleText?.font = UIFont(name: "Dosis-SemiBold", size: 10)
        self.titleText?.firstMaterial?.diffuse.contents  = UIColor.whiteColor()
        self.titleText?.firstMaterial?.doubleSided = true
        let titleNode = SCNNode(geometry: self.titleText!)
        
        
        
        var minVec = UnsafeMutablePointer<SCNVector3>.alloc(0)
        var maxVec = UnsafeMutablePointer<SCNVector3>.alloc(1)
        if titleNode.getBoundingBoxMin(minVec, max: maxVec) {
            let distance = SCNVector3(
                x: maxVec.memory.x - minVec.memory.x,
                y: maxVec.memory.y - minVec.memory.y,
                z: maxVec.memory.z - minVec.memory.z)
            
            titleNode.pivot = SCNMatrix4MakeTranslation(distance.x / 2, distance.y / 2, distance.z / 2)
            minVec.dealloc(0)
            maxVec.dealloc(1)
        }
        
        titleNode.position = SCNVector3(x: 0.0, y: 5, z: 0)
        
        titleNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
        
        //titleNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        
        
        
        
        return titleNode
    }
    
    func animateNode(node:SCNNode, win:Bool){
        
        self.gameActive = false
        
        var posAction1 = SCNAction.moveTo(SCNVector3(x: node.position.x, y: node.position.y, z: -3.0), duration: 0.25)
        var posAction2 = SCNAction.moveTo(SCNVector3(x: node.position.x, y: node.position.y, z: 0), duration: 0.25)
        node.runAction(SCNAction.sequence([posAction1,posAction2]))
        
        // get its material
        let material = node.geometry!.firstMaterial!
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.25)
        
        // on completion - unhighlight
        SCNTransaction.setCompletionBlock {
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.25)
            
            material.emission.contents = UIColor.blackColor()
            
            self.gameActive = true
            
            SCNTransaction.commit()
            
            
        }
        
        if(win == true){
            material.emission.contents = UIColor.greenColor()
        }else{
            material.emission.contents = UIColor.redColor()
        }
        
        
        SCNTransaction.commit()
    }
    
    /*
    func animateSpheres(){
        /*
        var scale:float_t = 1.2
        sphereNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        sphereNode2.scale = SCNVector3(x: scale, y: scale, z: scale)
        sphereNode3.scale = SCNVector3(x: scale, y: scale, z: scale)
        */
        
        
        //var scaleAction = SCNAction.scaleTo(1, duration: 0.25)
        var posAction1 = SCNAction.moveTo(SCNVector3(x: -2.5, y: 0.0, z: 0.0), duration: 0.5)
        var posAction2 = SCNAction.moveTo(SCNVector3(x: 0, y: 0.0, z: 0.0), duration: 0.5)
        var posAction3 = SCNAction.moveTo(SCNVector3(x: 2.5, y: 0.0, z: 0.0), duration: 0.5)
        var wait1 = SCNAction.waitForDuration(0.5)
        var wait2 = SCNAction.waitForDuration(1)
        var wait3 = SCNAction.waitForDuration(1.5)
        self.sphereNode?.runAction(SCNAction.sequence([wait1,posAction1]))
        self.sphereNode2?.runAction(SCNAction.sequence([wait2,posAction2]))
        //self.sphereNode3?.runAction(SCNAction.sequence([wait3,posAction3]))
        
        self.sphereNode3?.runAction(SCNAction.sequence([wait3,posAction3]), completionHandler: { () -> Void in
            //
            var r = CGFloat(360/180.0 * M_PI)
            self.sphereHolder?.runAction(SCNAction.rotateByX(0, y:r, z: 0, duration: 1));
            //println("xxx")
        })
        
        /*
        var numberOfItems = 3
        let radius: Double = 30.0
        var x: Double = 0.0
        var z: Double = radius
        let theta: Double = (M_PI) / Double(numberOfItems / 2)
        let incrementalY: Double = (M_PI) / Double(numberOfItems) * 2
        
        //self.sphereHolder?.position = SCNVector3(x: 0, y: 4, z: 0)
        
        for index in 1...numberOfItems {
        
        x = radius * sin(Double(index) * theta)
        z = radius * cos(Double(index) * theta)
        
        let node = self.sphereHolder?.childNodes[index-1] as SCNNode
        //let node = SCNNode(geometry: _geometry)
        node.position = SCNVector3(x: Float(x), y: 0, z:Float(z))
        let rotation = Float(incrementalY) * Float(index)
        node.rotation = SCNVector4(x: 0, y: 1, z: 0, w: rotation)
        }
        
        */
        
    }
    */
    
    
    
    
    override init() {
        self.movesArray = [Int]()
        super.init()
        self.initialize()
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

