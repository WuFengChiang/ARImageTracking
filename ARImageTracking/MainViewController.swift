//
//  MainViewController.swift
//  ARImageTracking
//
//  Created by wuufone on 2019/7/24.
//  Copyright © 2019 江武峯. All rights reserved.
//

import UIKit
import ARKit

class MainViewController: UIViewController {

    @IBOutlet weak var arScnView: ARSCNView!
    @IBOutlet weak var imageInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageInfoLabel.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        let arReferenceImages = ARReferenceImage.referenceImages(inGroupNamed: "ARResources", bundle: nil)
        configuration.trackingImages = arReferenceImages!
        configuration.maximumNumberOfTrackedImages = 2
        self.arScnView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

// MARK: - ARSCNViewDelegate
extension MainViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            addOverlayOnImage(anchor: imageAnchor, node: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            guard imageAnchor.isTracked else {
                self.hideImageInfoLabel()
                return
            }
            showImageInfoLabel()
            showImageInfo(imageName: imageAnchor.referenceImage.name!)
        }
    }
}

// MARK: -

extension MainViewController {
    private func addOverlayOnImage(anchor imageAnchor: ARImageAnchor, node: SCNNode) {
        let imageWidth = imageAnchor.referenceImage.physicalSize.width
        let imageHeight = imageAnchor.referenceImage.physicalSize.height
        let plane = SCNPlane(width: imageWidth, height: imageHeight)
        plane.materials.first?.diffuse.contents = UIColor.purple.withAlphaComponent(0.9)
        plane.materials.first?.isDoubleSided = true
        let imageOverlayNode = SCNNode(geometry: plane)
        imageOverlayNode.eulerAngles = SCNVector3Make(0.5*Float.pi, 0, 0)
        node.addChildNode(imageOverlayNode)
    }
    
    private func showImageInfo(imageName: String) {
        DispatchQueue.main.async {
            self.imageInfoLabel.text = "偵測到：\(imageName)"
        }
    }
    
    private func showImageInfoLabel() {
        DispatchQueue.main.async {
            self.imageInfoLabel.isHidden = false
        }
    }
    
    private func hideImageInfoLabel() {
        DispatchQueue.main.async {
            self.imageInfoLabel.isHidden = true
        }
    }
}
