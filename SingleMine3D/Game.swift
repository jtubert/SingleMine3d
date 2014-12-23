//
//  GameViewController.swift
//  game2
//
//  Created by John Tubert on 12/19/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

import UIKit
import SceneKit

class Game: SCNScene {
    
    var sphereNode:SCNNode?
    var sphereNode2:SCNNode?
    var sphereNode3:SCNNode?
    var titleText:SCNText?
    var titleNode:SCNNode?
    var sphereHolder:SCNNode?
    
    
    func initialize(){
        
        self.createCameraAndLights()
        
        self.sphereHolder = SCNNode()
        self.rootNode.addChildNode(self.sphereHolder!)
        
        self.sphereNode = self.createSphere(1,pos: SCNVector3(x: -2.5, y: 0.0, z: 12))
        self.sphereHolder?.addChildNode(self.sphereNode!)
        
        self.sphereNode2 = self.createSphere(2,pos: SCNVector3(x: 0, y: 0.0, z: -12.0))
        self.sphereHolder?.addChildNode(self.sphereNode2!)
        
        self.sphereNode3 = self.createSphere(3,pos: SCNVector3(x: 2.5, y: 0.0, z: 12.0))
        self.sphereHolder?.addChildNode(self.sphereNode3!)
        
        self.animateSpheres()
        
        
        self.titleNode = self.createText()
        self.rootNode.addChildNode(self.titleNode!)
        
        //self.updateText("xxxx")
        
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
        self.titleText = SCNText(string: "Ready?", extrusionDepth: 0.8)
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
        
        titleNode.position = SCNVector3(x: 0.0, y: 2.5, z: 0)
        
        titleNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
        
        //titleNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        
        
        
        
        return titleNode
    }
    
    
    func animateNode(node:SCNNode, win:Bool){
        var posAction1 = SCNAction.moveTo(SCNVector3(x: node.position.x, y: node.position.y, z: -5.0), duration: 0.5)
        var posAction2 = SCNAction.moveTo(SCNVector3(x: node.position.x, y: node.position.y, z: 0), duration: 0.5)
        node.runAction(SCNAction.sequence([posAction1,posAction2]))
        
        // get its material
        let material = node.geometry!.firstMaterial!
        
        
        
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
        
        if(win == true){
            material.emission.contents = UIColor.greenColor()
        }else{
            material.emission.contents = UIColor.redColor()
        }
        
        
        SCNTransaction.commit()
    }
    
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
    
    func createSphere(index:Int, pos:SCNVector3) -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.firstMaterial?.diffuse.contents = UIColor.greenColor()
        let materials = SCNMaterial()
        materials.diffuse.contents = UIImage(named: "planet"+String(index))
        sphereGeometry.materials = [materials]
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.position = pos
        sphereNode.name = "sphere"+String(index)
        sphereNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(2, y: 3, z: 0, duration: 5)))
        
        return sphereNode
    }
    
    
    override init() {
        super.init()
        self.initialize()
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
