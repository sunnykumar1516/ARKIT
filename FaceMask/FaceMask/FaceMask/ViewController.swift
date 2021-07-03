//
//  ViewController.swift
//  FaceMask
//
//  Created by Sunny Kumar on 03/07/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    
    @IBOutlet weak var motion: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    
    lazy var rightEyeNode = SCNReferenceNode(named: "eye")
    lazy var leftEyeNode = SCNReferenceNode(named: "eye")
    
    var opctController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        node.addChildNode(leftEyeNode)
        node.addChildNode(rightEyeNode)
        
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
                let faceAnchor = anchor as? ARFaceAnchor
                else { return }
            
            faceGeometry.update(from: faceAnchor.geometry)
        
        findExpression(anchor: faceAnchor)
        
        if(opctController) {
            faceGeometry.firstMaterial?.transparency = .zero
        }
        
        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
    }
    
    func findExpression(anchor: ARFaceAnchor)  {
        let leftEye = anchor.blendShapes[.eyeBlinkLeft]
        let rightEye = anchor.blendShapes[.eyeBlinkRight]
        
        DispatchQueue.main.async {
            if(leftEye?.decimalValue ?? 0 > 0.5) {
                self.motion.text = "Left eye closed"
            } else if(rightEye?.decimalValue ?? 0 > 0.5) {
                self.motion.text = "Right eye closed"
            }
        }
    }
    
    @IBAction func toggleController(_ sender: Any) {
        opctController = !opctController
    }
    
}

extension SCNReferenceNode {
    convenience init(named resourceName: String, loadImmediately: Bool = true) {
        let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "art.scnassets")!
        self.init(url: url)!
        if loadImmediately {
            self.load()
        }
    }
}
