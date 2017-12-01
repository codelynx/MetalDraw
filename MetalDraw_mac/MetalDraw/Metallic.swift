//
//  MetallicDevice.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import MetalKit

struct Metallic {

	let device: MTLDevice
	let commandQueue: MTLCommandQueue
	let library: MTLLibrary?

	
	private (set) static var shared = Metallic()

	private init() {
		guard let device = MTLCreateSystemDefaultDevice() else { fatalError("failed to create device: MTLCreateSystemDefaultDevice()") }
		guard let commandQueue = device.makeCommandQueue() else { fatalError("failed to make command queue: makeCommandQueue()") }
		self.device = device
		self.commandQueue = commandQueue
		self.library = device.makeDefaultLibrary()
	}
	
	// MARK: -

	private (set) var renderers = NSMapTable<NSString, AnyObject>.strongToWeakObjects()

	func renderer<T: MetallicRenderer>() -> T {
		let key = NSStringFromClass(T.self) as NSString
		if let renderer = renderers.object(forKey: key) {
			return renderer as! T
		}
		else {
			let renderer = T(metallic: self)
			renderers.setObject(renderer, forKey: key)
			return renderer
		}
	}

	// MARK: -
	
	private (set) var kernels = NSMapTable<NSString, AnyObject>.strongToWeakObjects()

	func renderer<T: MetalicKernel>() -> T {
		let key = NSStringFromClass(T.self) as NSString
		if let renderer = renderers.object(forKey: key) {
			return renderer as! T
		}
		else {
			let renderer = T(metallic: self)
			renderers.setObject(renderer, forKey: key)
			return renderer
		}
	}

}
