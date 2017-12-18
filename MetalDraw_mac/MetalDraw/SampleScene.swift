//
//  SampleScene.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import AppKit


class SampleScene: MetallicScene {

	typealias Vertex = ColorRenderer.Vertex

	//		  a
	//		 / \
	//		b---c

	let pt1 = ColorRenderer.Vertex(x: 512, y: 0, z: 0, w: 1, r: 1, g: 0, b: 0, a: 0.5) // (a)
	let pt2 = ColorRenderer.Vertex(x: 0, y: 768, z: 0, w: 1, r: 0, g: 1, b: 0, a: 0.5) // (b)
	let pt3 = ColorRenderer.Vertex(x: 1024, y: 768, z: 0, w: 1, r: 0, g: 0, b: 1, a: 0.5) // (c)

	lazy var pointVertices: [PointRenderer.Vertex] = {
		
		return (1..<100).map { _ in
				PointRenderer.Vertex(x: Float(arc4random() % 1000), y: Float(arc4random() % 1000), width: Float(arc4random() % 32) + 8,
						r: Float(arc4random() % 256) / 256, g: Float(arc4random() % 256) / 256, b: Float(arc4random() % 256) / 256, a: 1.0) }
	}()


//	let pt1 = ColorRenderer.Vertex(x: 0, y: -1, z: 0, w: 1, r: 1, g: 0, b: 0, a: 0.5)
//	let pt2 = ColorRenderer.Vertex(x: -1, y: 1, z: 0, w: 1, r: 0, g: 1, b: 0, a: 0.5)
//	let pt3 = ColorRenderer.Vertex(x: +1, y: 1, z: 0, w: 1, r: 0, g: 0, b: 1, a: 0.5)

	override func render(context: MetallicContext) {

		let image = NSImage(named: "dandelion.png")!
		context.render(image: image, in: Rect(0, 0, 1113, 768))

		context.renderColor(verticies: [pt1, pt2, pt3])
		context.renderPoints(points: self.pointVertices)

		let cgPath = NSBezierPath(ovalIn: self.bounds.insetBy(dx: 128, dy: 128)).cgPath
		context.renderPath(cgPath: cgPath, scale: context.scale)
	}
}

