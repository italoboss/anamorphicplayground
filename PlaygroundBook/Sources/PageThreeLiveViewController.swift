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
    var planeHitResult: ARHitTestResult? = nil
    
    public var selectedStyle: TextStyle? = nil
    public var leftNode: SCNNode?
    public var rightNode: SCNNode?
    
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
                self.planeHitResult = hitResult
                DispatchQueue.main.async {
                    self.addAnamorphicPlane(at: hitResult)
                }
            }
        }
    }
    
    public func addAnamorphicPlane(at hitResult: ARHitTestResult) {
        
        let materials = getMaterials()
        let widths = getWidths()
        
        var width: CGFloat = widths[0]
        let height: CGFloat = 1.0
        
        let leftGeometry = SCNBox(width: width, height: height, length: 0.000001, chamferRadius: 0)
        leftGeometry.materials = [materials[0]]
        
        leftNode = SCNNode(geometry: leftGeometry)
        leftNode?.position = SCNVector3(
            (hitResult.worldTransform.columns.3.x + 0.00075 - Float(width/4)),
            (hitResult.worldTransform.columns.3.y + 1.4),
            hitResult.worldTransform.columns.3.z
        )
        leftNode?.rotation = SCNVector4(0, 1, 0, Float.pi/3)
        
        width = widths[1]
        
        let rightGeometry = SCNBox(width: width, height: height, length: 0.000001, chamferRadius: 0)
        rightGeometry.materials = [materials[1]]
        
        rightNode = SCNNode(geometry: rightGeometry)
        rightNode?.position = SCNVector3(
            (hitResult.worldTransform.columns.3.x - 0.00075 + Float(width/4)),
            (hitResult.worldTransform.columns.3.y + 1.4),
            hitResult.worldTransform.columns.3.z
        )
        rightNode?.rotation = SCNVector4(0, 1, 0, -(Float.pi/3))
        
        self.sceneView.scene.rootNode.addChildNode(leftNode!)
        self.sceneView.scene.rootNode.addChildNode(rightNode!)
        
        addedAnamorphic = true
        for plane in planes {
            plane.setVisibility(false)
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case let PlaygroundValue.integer(style) = message else {
            self.selectedStyle = nil
            return
        }
        self.selectedStyle = TextStyle(rawValue: style)
        DispatchQueue.main.async {
            self.leftNode?.removeFromParentNode()
            self.rightNode?.removeFromParentNode()
            self.leftNode = nil
            self.rightNode = nil
            if let hitResult = self.planeHitResult {
                self.addAnamorphicPlane(at: hitResult)
            }
        }
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
    
    public func getMaterials() -> [SCNMaterial] {
        let lMaterial = SCNMaterial()
//        lMaterial.lightingModel = .physicallyBased
        let rMaterial = SCNMaterial()
//        rMaterial.lightingModel = .physicallyBased
        lMaterial.diffuse.contents = UIImage(named: "wwdc_left.png")
        rMaterial.diffuse.contents = UIImage(named: "wwdc_right.png")
        
        guard let style = self.selectedStyle else {
            return [lMaterial, rMaterial]
        }
        switch style {
        case .pixel:
            lMaterial.diffuse.contents = UIImage(named: "wwdc_left.png")
            rMaterial.diffuse.contents = UIImage(named: "wwdc_right.png")
        case .retro:
            lMaterial.diffuse.contents = UIImage(named: "write_left.png")
            rMaterial.diffuse.contents = UIImage(named: "write_right.png")
        case .comic:
            lMaterial.diffuse.contents = UIImage(named: "blow_left.png")
            rMaterial.diffuse.contents = UIImage(named: "blow_right.png")
        }
        
        return [lMaterial, rMaterial]
    }
    
    public func getWidths() -> [CGFloat] {
        var wLeft: CGFloat = 0.52956
        var wRight: CGFloat = 0.53057
        
        guard let style = self.selectedStyle else {
            return [wLeft, wRight]
        }
        switch style {
        case .pixel:
            wLeft = 0.52956
            wRight = 0.53057
        case .retro:
            wLeft = 0.53057
            wRight = 0.53208
        case .comic:
            wLeft = 0.53208
            wRight = 0.53208
        }
        
        return [wLeft, wRight]
    }

}
