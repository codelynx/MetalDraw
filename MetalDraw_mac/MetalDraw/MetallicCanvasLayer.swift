
//
//  MetallicLayer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/16/17.
//

import Foundation
import MetalKit


class MetallicCanvasLayer {

	var isDynamic: Bool = false
	var isHidden: Bool = false

	var frame: Rect = Rect.zero

	var bounds: Rect {
		return self.frame.offsetBy(point: self.frame.origin)
	}

	weak var canvas: MettalicCanvasScene?

	init(frame: Rect) {
		self.frame = frame
	}

	func render(context: MetallicContext) {
		
	}

}


