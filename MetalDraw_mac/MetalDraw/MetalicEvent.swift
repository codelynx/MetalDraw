//
//  MetalicEvent.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/23/17.
//

import AppKit

class MetalicEvent {

	let event: NSEvent
	let sceneView: MetalicSceneView
	
	init(event: NSEvent, sceneView: MetalicSceneView) {
		self.event = event
		self.sceneView = sceneView
	}

	var locationInWindow: CGPoint {
		return self.event.locationInWindow
	}

}
