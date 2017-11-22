//
//  MetalicScene.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import MetalKit


class MetalicScene: MetalicNode, Equatable {
	var bounds: CGRect
	var subnodes = [MetalicNode]()

	var width: CGFloat { return bounds.width }
	var height: CGFloat { return bounds.height }

	init(bounds: CGRect) {
		self.bounds = bounds
	}

	func render(context: MetalicContext) {
		
	}

	func setNeedsDisplay() {
		NotificationCenter.default.post(name: .displayMetalicScene, object: self)
	}

	static func == (lhs: MetalicScene, rhs: MetalicScene) -> Bool {
		return lhs === rhs
	}
}
