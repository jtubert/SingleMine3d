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

class GameViewController: UIViewController {
    
    var sphereNode:SCNNode?
    var sphereNode2:SCNNode?
    var sphereNode3:SCNNode?
    var scene:SCNScene?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialize()
    }
    
    func initialize(){
        self.scene = SCNScene()
        
        self.createCameraAndLights()
        
        let sphereHolder = SCNNode()
        self.scene?.rootNode.addChildNode(sphereHolder)
        
        self.sphereNode = self.createSphere(1,pos: SCNVector3(x: -2.5, y: 0.0, z: 12))
        sphereHolder.addChildNode(self.sphereNode!)
        
        self.sphereNode2 = self.createSphere(2,pos: SCNVector3(x: 0, y: 0.0, z: -12.0))
        sphereHolder.addChildNode(self.sphereNode2!)
        
        self.sphereNode3 = self.createSphere(3,pos: SCNVector3(x: 2.5, y: 0.0, z: 12.0))
        sphereHolder.addChildNode(self.sphereNode3!)
        
        self.animateSpheres()
        
        
        var titleNode = self.createText()
        self.scene?.rootNode.addChildNode(titleNode)
        
        
        self.createSceneView()

    }
    
    func createCameraAndLights(){
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        self.scene?.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        self.scene?.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.lightGrayColor()
        self.scene?.rootNode.addChildNode(ambientLightNode)
    }
    
    func createSceneView(){
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // set the scene to the view
        scnView.scene = self.scene
        
        scnView.autoenablesDefaultLighting = true
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        if let existingGestureRecognizers = scnView.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        scnView.gestureRecognizers = gestureRecognizers

    }
    
    func createText() -> SCNNode{
        let titleText = SCNText(string: "Ready?", extrusionDepth: 0.8)
        titleText.flatness = 0.1
        //titleText.containerFrame = CGRect(x: 100, y: 10, width: 200, height: 50)
        titleText.font = UIFont(name: "Dosis-SemiBold", size: 10)
        titleText.firstMaterial?.diffuse.contents  = UIColor.whiteColor()
        titleText.firstMaterial?.doubleSided = true
        let titleNode = SCNNode(geometry: titleText)
        
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
        
        titleNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        return titleNode
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
        self.sphereNode3?.runAction(SCNAction.sequence([wait3,posAction3]))

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
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        if let hitResults = scnView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                println(result.node.name)
                
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
    
    override func shouldAutorotate() -> Bool {
        return true
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
