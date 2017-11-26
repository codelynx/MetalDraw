//
//  MetallicDevice.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import MetalKit

struct MetallicDevice {
    static let shared = MetallicDevice()
	let device: MTLDevice
    let library: MTLLibrary
    let commandQueue: MTLCommandQueue

	private init() {
        guard let device = MTLCreateSystemDefaultDevice(),
            let library = device.makeDefaultLibrary(),
            let commandQueue = device.makeCommandQueue() else { fatalError("failed to initialize device") }
        self.device = device
        self.library = library
        self.commandQueue = commandQueue
	}

	func makeBuffer<T>(items: [T], capacity: Int? = nil) throws -> MetallicBuffer<T> {
		return try MetallicBuffer(device: device, vertices: items, capacity: capacity)
	}

}
