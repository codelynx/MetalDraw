//
//  MetallicRenderer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

protocol MetallicRenderer: class {
	var metallic: Metallic { get }
	var device: MTLDevice { get }
	var library: MTLLibrary? { get }
	var commandQueue: MTLCommandQueue? { get }
	init(metallic: Metallic)
}

extension MetallicRenderer {
	var device: MTLDevice { return metallic.device }
	var library: MTLLibrary? { return metallic.library }
	var commandQueue: MTLCommandQueue? { return metallic.commandQueue }
}

// MARK: -

protocol MetalicKernel: class {
	var metallic: Metallic { get }
	var device: MTLDevice { get }
	var library: MTLLibrary? { get }
	var commandQueue: MTLCommandQueue? { get }
	init(metallic: Metallic)
}

extension MetalicKernel {
	var device: MTLDevice { return metallic.device }
	var library: MTLLibrary? { return metallic.library }
	var commandQueue: MTLCommandQueue? { return metallic.commandQueue }
}
