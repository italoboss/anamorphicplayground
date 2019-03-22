//
//  PageThreeLiveViewController.swift
//  Book_Sources
//
//  Created by Italo Boss on 21/03/19.
//

import UIKit
import PlaygroundSupport
import SceneKit
import ARKit

@available(iOS 11.0, *)
@objc(Book_Sources_LiveViewController)
public class PageThreeLiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer, ARSCNViewDelegate, ARSessionDelegate {
    
    public var sceneView: ARSCNView!
    public var planes = [OverlayPlane]()
    public var addedAnamorphic = false
    
    public var sessionInfoLabel: UILabel?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        // self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        registerGestureRecognizers()
        addSessionInfo()
    }
    
    public func addSessionInfo() {
        sessionInfoLabel = UILabel()
        self.view.addSubview(sessionInfoLabel!)
        sessionInfoLabel!.backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        sessionInfoLabel!.text = ""
        sessionInfoLabel!.translatesAutoresizingMaskIntoConstraints = false
        sessionInfoLabel!.numberOfLines = 0
        
        let horizontalConstraint = NSLayoutConstraint(item: sessionInfoLabel!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute:NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 10)
        let verticalConstraint = NSLayoutConstraint(item: sessionInfoLabel!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 20)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    /*
     *  ARKIT Delegate Methods
     */
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            
            let plane = OverlayPlane(anchor: planeAnchor)
            plane.setVisibility(!self.addedAnamorphic)
            self.planes.append(plane)
            node.addChildNode(plane)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            let unwPlane = self.planes.filter { p in
                return p.anchor.identifier == anchor.identifier
                }.first
            
            guard let plane = unwPlane, let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            plane.update(anchor: planeAnchor)
        }
    }
    
    
    /*
     *  GESTURES
     */
    public func registerGestureRecognizers(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        if !addedAnamorphic, let sceneView = recognizer.view as? ARSCNView {
            let touchLocation = recognizer.location(in: sceneView)
            
            let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if !hitTestResult.isEmpty {
                print("Hit a plane!")
                guard let hitResult = hitTestResult.first else {
                    return
                }
                addAnamorphicPlane(at: hitResult)
            }
        }
    }
    
    public func addAnamorphicPlane(at hitResult: ARHitTestResult) {
        var width: CGFloat = 0.94906
        var height: CGFloat = 1.0
        
        let wGeometry = SCNBox(width: width, height: height, length: 0.000001, chamferRadius: 0)
        let wMaterial = SCNMaterial()
        wMaterial.diffuse.contents = UIImage(named: "wwdc_oblique_one.png")
        wMaterial.lightingModel = .physicallyBased
        wGeometry.materials = [wMaterial]
        
        let wNode = SCNNode(geometry: wGeometry)
        wNode.position = SCNVector3(
            (hitResult.worldTransform.columns.3.x - 0.34),
            (hitResult.worldTransform.columns.3.y + 1.4),
            hitResult.worldTransform.columns.3.z
        )
        wNode.rotation = SCNVector4(0, 1, 0, Float.pi/4)
        
        width = 0.97721
        height = 1.0
        
        let swGeometry = SCNBox(width: width, height: height, length: 0.000001, chamferRadius: 0)
        let swMaterial = SCNMaterial()
        swMaterial.diffuse.contents = UIImage(named: "wwdc_oblique_two.png")
        swMaterial.lightingModel = .physicallyBased
        swGeometry.materials = [swMaterial]
        
        let swNode = SCNNode(geometry: swGeometry)
        swNode.position = SCNVector3(
            (hitResult.worldTransform.columns.3.x + 0.34),
            (hitResult.worldTransform.columns.3.y + 1.4),
            hitResult.worldTransform.columns.3.z
        )
        swNode.rotation = SCNVector4(0, 1, 0, -(Float.pi/4))
        
        self.sceneView.scene.rootNode.addChildNode(wNode)
        self.sceneView.scene.rootNode.addChildNode(swNode)
        
        addedAnamorphic = true
        for plane in planes {
            plane.setVisibility(false)
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    }
    
    
    // MARK: - ARSessionDelegate
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel?.text = "Session was interrupted"
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel?.text = "Session interruption ended"
    }
    
    public func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Move the device around to detect surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited: Move the device more \nslowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited: Point the device at an \narea with visible surface detail, or \nimprove lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            message = ""
        }
        
        sessionInfoLabel?.text = message
        sessionInfoLabel?.isHidden = message.isEmpty
    }

}
