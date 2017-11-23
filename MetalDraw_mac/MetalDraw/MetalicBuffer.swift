//
//	VertexBuffer.swift
//	Silvershadow
//
//	Created by Kaz Yoshikawa on 1/11/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import MetalKit

enum MetalicError: Error {
	case failedMakingBuffer
}


//
//	VertexBuffer
//

class MetalicBuffer<T> {

    var device: MTLDevice {
        return buffer.device
    }

	private(set) var buffer: MTLBuffer
	private(set) var count: Int
	private(set) var capacity: Int

	init(device: MTLDevice, vertices: [T], capacity: Int? = nil) throws {
		assert(vertices.count <= capacity ?? vertices.count)

		self.count = vertices.count
		let capacity = capacity ?? vertices.count
		let length = MemoryLayout<T>.stride * capacity
		self.capacity = capacity
		if let buffer = device.makeBuffer(bytes: vertices, length: length, options: [.storageModeShared]) {
			self.buffer = buffer
		}
		else { throw MetalicError.failedMakingBuffer }
	}

	deinit {
//		buffer.setPurgeableState(.empty)
	}

	func append(_ vertices: [T]) throws {
		if self.count + vertices.count < self.capacity {
			let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
			for index in 0 ..< vertices.count {
				vertexArray[self.count + index] = vertices[index]
			}
			self.count += vertices.count
		}
		else {
			let count = self.count
			let length = MemoryLayout<T>.stride * (count + vertices.count)
			guard let buffer = self.device.makeBuffer(length: length, options: [.storageModeShared]) else { throw MetalicError.failedMakingBuffer }

			let sourceArray = UnsafeMutableBufferPointer<T>(buffer: self.buffer, count: count)

			let destinationArray = UnsafeMutableBufferPointer<T>(buffer: self.buffer, count: count + vertices.count)

			(0 ..< count).forEach { destinationArray[$0] = sourceArray[$0] }
			(0 ..< vertices.count).forEach { destinationArray[count + $0] = vertices[$0] }

			self.count = count + vertices.count
			self.capacity = self.count

			self.buffer = buffer
		}
	}

	func set(_ vertices: [T]) throws {
		if vertices.count < self.capacity {

			let destinationArray = UnsafeMutableBufferPointer<T>(buffer: buffer, count: count + vertices.count)
			(0 ..< vertices.count).forEach { destinationArray[$0] = vertices[$0]  }
			self.count = vertices.count
		}
		else {
			let bytes = MemoryLayout<T>.size * vertices.count
			guard let buffer = device.makeBuffer(bytes: vertices, length: bytes, options: [.storageModeShared]) else { throw MetalicError.failedMakingBuffer }
			self.count = vertices.count
			self.capacity = vertices.count
			self.buffer = buffer
		}
	}

	var vertices: [T] {
		let vertexArray = UnsafeMutablePointer<T>(OpaquePointer(self.buffer.contents()))
		return (0 ..< count).map { vertexArray[$0] }
	}

}

