//
//  MetallicEvent.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/23/17.
//

import AppKit

class MetallicEvent {

	let event: NSEvent
	let sceneView: MetallicSceneView
	
	init(event: NSEvent, sceneView: MetallicSceneView) {
		self.event = event
		self.sceneView = sceneView
	}

	var locationInWindow: CGPoint {
		return self.event.locationInWindow
	}

}
