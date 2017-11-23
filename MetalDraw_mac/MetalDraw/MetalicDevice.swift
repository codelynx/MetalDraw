//
//  MetalicDevice.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

struct MetalicDevice {

	let device: MTLDevice

	static var shared: MetalicDevice? = {
		return MetalicDevice()
	}()

	private init?() {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.device = device
	}

	func makeBuffer<T>(items: [T], capacity: Int? = nil) throws -> MetalicBuffer<T> {
		return try MetalicBuffer(device: device, vertices: items, capacity: capacity)
	}

}
