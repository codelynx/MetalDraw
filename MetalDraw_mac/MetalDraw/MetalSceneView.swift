//
//  MetalSceneView.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa

class MetalSceneView: NSView {
	
	override func layout() {
		super.layout()
		self.wantsLayer = true
		self.layer?.backgroundColor = NSColor.white.cgColor
	}
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.blue.set()
		NSBezierPath(ovalIn: self.bounds).stroke()
		
		NSColor.red.set()
		let path = NSBezierPath()
		path.move(to: self.bounds.midXminY)
		path.line(to: self.bounds.minXmaxY)
		path.line(to: self.bounds.maxXmaxY)
		path.close()
		path.stroke()
	}

	override var isFlipped: Bool { return true }

}
