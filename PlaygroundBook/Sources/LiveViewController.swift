//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  An auxiliary source file which is part of the book-level auxiliary sources.
//  Provides the implementation of the "always-on" live view.
//
import UIKit
import PlaygroundSupport
import SceneKit
import ARKit

@available(iOS 11.0, *)
@objc(Book_Sources_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer, ARSCNViewDelegate, ARSessionDelegate {
    
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
        let width: CGFloat = 1.392
        let height: CGFloat = 1.5835
        let anaGeometry = SCNBox(width: width, height: 0.001, length: height, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "broken_floor.png")
        material.lightingModel = .physicallyBased
        anaGeometry.materials = [material]
        
        let anaNode = SCNNode(geometry: anaGeometry)
        anaNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            (hitResult.worldTransform.columns.3.y + 0.001),
            hitResult.worldTransform.columns.3.z
        )
        
        self.sceneView.scene.rootNode.addChildNode(anaNode)
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
