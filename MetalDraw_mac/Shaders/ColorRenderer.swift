//
//  ColorRenderer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import simd

class ColorRenderer: MetallicRenderer {

	struct Vertex {
		var x, y, z, w, r, g, b, a: Float
	}

	struct Uniforms {
		var transform: float4x4
	}

	static var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .float2
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 4
		vertexDescriptor.attributes[1].format = .float4
		vertexDescriptor.attributes[1].bufferIndex = 0

		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	static var renderPipelineState: MTLRenderPipelineState? = {
//        guard let device = device else { return nil }
		let library = device.library
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
		renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "color_vertex")!
		renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "color_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = .default
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

		let renderPipelineState = try? device.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
		return renderPipelineState
	}()

	static func render(context: MetallicContext, vertexBuffer: MetallicBuffer<Vertex>) {
		var uniforms = Uniforms(transform: context.transform)
		let uniformsBuffer = device.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.size, options: [])

		if let commandBuffer = device.commandQueue.makeCommandBuffer(),
		   let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: context.renderPassDescriptor),
		   let renderPipelineState = renderPipelineState {
			encoder.setRenderPipelineState(renderPipelineState)
			encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
			encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
			print("\(#function)")
			encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexBuffer.count)

			encoder.endEncoding()
			commandBuffer.commit()
		}
		else { print("warning: \(#file):\(#line) - \(#function)") }
	}

	static var heap: MTLHeap? = {
		let descriptor = MTLHeapDescriptor()
		descriptor.storageMode = .shared
		descriptor.size = 1024 * 1024
		return device.device.makeHeap(descriptor: descriptor)
	}()
}

extension MetallicContext {

	func renderColor(verticies: [ColorRenderer.Vertex]) {
		if let buffer = self.makeBuffer(items: verticies) {
			ColorRenderer.render(context: self, vertexBuffer: buffer)
		}
	}
}

