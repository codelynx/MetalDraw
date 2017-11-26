//
//  MetallicScene.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import MetalKit


class MetallicScene: MetallicNode, Equatable {

	var bounds: CGRect
	var subnodes = [MetallicNode]()

	var width: CGFloat { return bounds.width }
	var height: CGFloat { return bounds.height }

	init(bounds: CGRect) {
		self.bounds = bounds
	}

	func render(context: MetallicContext) {
		
	}

	func setNeedsDisplay() {
		NotificationCenter.default.post(name: .displayMetallicScene, object: self)
	}

	static func == (lhs: MetallicScene, rhs: MetallicScene) -> Bool {
		return lhs === rhs
	}

	// MARK: -

	func locationInScene(_ event: MetallicEvent) -> CGPoint? {
        return event.sceneView.convert(event.locationInWindow, from: nil)
	}

    func mouseDown(with event: MetallicEvent) {
		//let pt = self.locationInScene(event)
    }

    func mouseMoved(with event: MetallicEvent) {
    }

    func mouseDragged(with event: MetallicEvent) {
    }

    func mouseUp(with event: MetallicEvent) {
    }

}
