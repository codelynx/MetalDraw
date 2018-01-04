
//
//  MetallicLayer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/16/17.
//

import Foundation
import MetalKit


class MetallicCanvasLayer {

	var isStatic: Bool = true
	var isHidden: Bool = false

	var frame: Rect = Rect.zero

	var bounds: Rect {
		return self.canvas.bounds
	}

	unowned var canvas: MetallicCanvas

	var metallic: Metallic? { return canvas.metallic }

	init(canvas: MetallicCanvas) {
		self.canvas = canvas
	}

	func render(context: MetallicContext) {
	}

}

extension MetallicCanvasLayer: Equatable, Hashable {

	static func == (lhs: MetallicCanvasLayer, rhs: MetallicCanvasLayer) -> Bool {
		return lhs === rhs
	}

    var hashValue: Int {
		return ObjectIdentifier(self).hashValue
    }
}

