//
//  SampleCanvasLayer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/17/17.
//

import Foundation
import CoreGraphics
import MetalKit


class Sample1CanvasLayer: MetallicCanvasLayer {

	let pt1 = ColorRenderer.Vertex(x: 512, y: 0, z: 0, w: 1, r: 1, g: 0, b: 0, a: 0.5) // (a)
	let pt2 = ColorRenderer.Vertex(x: 0, y: 768, z: 0, w: 1, r: 0, g: 1, b: 0, a: 0.5) // (b)
	let pt3 = ColorRenderer.Vertex(x: 1024, y: 768, z: 0, w: 1, r: 0, g: 0, b: 1, a: 0.5) // (c)

	override func render(context: MetallicContext) {
		context.renderColor(verticies: [pt1, pt2, pt3])
	}

}

