//
//  NSImage+Z.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/13/17.
//

import AppKit


extension NSImage {

	convenience init?(named name: String) {
		self.init(named: NSImage.Name(name))
	}

}
