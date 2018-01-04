//
//  SampleCanvasScene.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/22/17.
//

import Foundation
import MetalKit


class SimpleCanvas: MetallicCanvas {

	var activeStroke: CGMutablePath?

	lazy var overlay: SimpleCanvasLayer = {
		return SimpleCanvasLayer(canvas: self)
	}()

	lazy var underlay: SimpleCanvasLayer = {
		return SimpleCanvasLayer(canvas: self)
	}()

	override func prepareCanvas() {
		self.appendLayer(self.underlay)
		self.appendLayer(self.overlay)
	}

	// MARK: -

	override func mouseDown(with event: MetallicEvent) {
		print("\(#function)")
		guard let point = self.locationInScene(event) else { return }
		let bezierPath = CGMutablePath()
		bezierPath.move(to: point)
		self.activeStroke = bezierPath
		self.overlay.strokes.append(bezierPath)
    }

	override func mouseMoved(with event: MetallicEvent) {
		print("\(#function)")
    }

	override func mouseDragged(with event: MetallicEvent) {
		print("\(#function)")
		guard let point = self.locationInScene(event) else { return }
		guard let activeStroke = self.activeStroke else { return }
		activeStroke.addLine(to: point)
		self.setNeedsDisplay()
    }

	override func mouseUp(with event: MetallicEvent) {
		print("\(#function)")
		guard let point = self.locationInScene(event) else { return }
		guard let activeStroke = self.activeStroke else { return }
//		guard let cgPath = activeStroke.cgPath else { return }
		activeStroke.addLine(to: point)
		self.underlay.strokes += self.overlay.strokes
		self.setNeedsDisplay()
    }

}

