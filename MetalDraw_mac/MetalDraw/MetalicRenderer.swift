//
//  MetalicRenderer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

protocol MetalicRenderer {
	static var device: MTLDevice? { get }
	static var library: MTLLibrary? { get }
}

extension MetalicRenderer {
	static var device: MTLDevice? { return MetalicDevice.shared?.device }
	static var library: MTLLibrary? { return self.device?.makeDefaultLibrary() }
}
