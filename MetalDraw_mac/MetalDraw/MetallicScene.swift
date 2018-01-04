//
//  MetallicScene.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import MetalKit


class MetallicScene: MetallicNode, Equatable {

	fileprivate (set) var metallic: Metallic? {
		didSet {
			self.prepareScene()
		}
	}

	var bounds: Rect
	var subnodes = [MetallicNode]()

	var width: Float { return bounds.width }
	var height: Float { return bounds.height }

	init(bounds: Rect) {
		self.bounds = bounds
	}

	func render(context: MetallicContext) {
	}

	func setNeedsDisplay() {
		NotificationCenter.default.post(name: .displayScene, object: nil)
	}
	
	func prepareScene() {
	}

	// MARK: -

	static func == (lhs: MetallicScene, rhs: MetallicScene) -> Bool {
		return lhs === rhs
	}

	// MARK: -

	func locationInScene(_ event: MetallicEvent) -> CGPoint? {
        return event.sceneView.convert(event.locationInWindow, from: nil)
	}

	// MARK: -

    func mouseDown(with event: MetallicEvent) {
    }

    func mouseMoved(with event: MetallicEvent) {
    }

    func mouseDragged(with event: MetallicEvent) {
    }

    func mouseUp(with event: MetallicEvent) {
    }

}

extension MetallicSceneView {

	func sceneDidSet() {
		self.scene?.metallic = self.metallic
	}

}

