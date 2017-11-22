//
//  MetalRenderContext.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import simd


struct MetalicState {
	var renderPassDescriptor: MTLRenderPassDescriptor
	var transform: float4x4
	var dictionary: [String: Any]
}


class MetalicContext {
	private let commandQueue: MTLCommandQueue
	private var stack = Stack<MetalicState>()
	private var current: MetalicState

	init(commandQueue: MTLCommandQueue, state: MetalicState) {
		self.commandQueue = commandQueue
		self.current = state
	}


	func push(state: MetalicState) {
		self.stack.push(self.current)
		self.current = state
	}
	
	func pop() {
		if let state = self.stack.pop() {
			self.current = state
		}
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
	
	func makeBuffer<T>(items: [T]) -> MetalicBuffer<T>? {
		return device.makeBuffer(elements: items)
	}
}


