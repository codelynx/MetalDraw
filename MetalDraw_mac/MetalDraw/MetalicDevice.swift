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
		if let device = MTLCreateSystemDefaultDevice() {
			self.device = device
		}
		else {
			return nil
		}
	}

	func makeBuffer<T>(items: [T], capacity: Int? = nil) throws -> MetalicBuffer<T> {
		return try MetalicBuffer(device: device, vertices: items, capacity: capacity)
	}

}
