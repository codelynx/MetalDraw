//
//  MetalRenderContext.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import simd


struct MetallicState {
	var renderPassDescriptor: MTLRenderPassDescriptor
	var transform: float4x4
	var dictionary: [String: Any]
}


class MetallicContext {

	public let metallic: Metallic
	private var stack = Stack<MetallicState>()
	private var current: MetallicState

	init(metallic: Metallic, state: MetallicState) {
		self.metallic = metallic
		self.current = state
	}

    func push(state: MetallicState) {
		self.stack.push(self.current)
		self.current = state
	}

	func pop() {
		if let state = self.stack.pop() {
			self.current = state
		}
	}

	var commandQueue: MTLCommandQueue {
		return metallic.commandQueue
	}

	func makeCommandBuffer() -> MTLCommandBuffer? {
		return self.commandQueue.makeCommandBuffer()
	}

	var renderPassDescriptor: MTLRenderPassDescriptor {
		return self.current.renderPassDescriptor
	}

	var transform: float4x4 {
		return self.current.transform
	}

	subscript(key: String) -> Any? {
		get { return self.current.dictionary[key] }
		set { self.current.dictionary[key] = newValue }
	}

	var device: MTLDevice {
		return commandQueue.device
	}

	func makeBuffer<T>(items: [T]) -> MetallicBuffer<T>? {
		return device.makeBuffer(elements: items)
	}
	
	func renderer<T: MetallicRenderer>() -> T {
		return metallic.renderer()
	}
}


