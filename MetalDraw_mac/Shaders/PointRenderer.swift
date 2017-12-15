//
//  PointRenderer.swift
//  TestPlot
//
//  Created by Kaz Yoshikawa on 2/24/17.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Foundation
import MetalKit
import simd


class PointRenderer: MetallicRenderer {

	let metallic: Metallic

	required init(metallic: Metallic) {
		self.metallic = metallic
	}

	struct Vertex {
		var x: Float
		var y: Float
		var width: Float
		var unused: Float
		var color: float4
		init(x: Float, y: Float, width: Float, r: Float, g: Float, b: Float, a: Float) {
			self.x = x
			self.y = y
			self.width = width
			self.unused = 0
			self.color = float4(r, g, b, a)
		}
		init(x: CGFloat, y: CGFloat, width: CGFloat, color: XColor) {
			self.x = Float(x)
			self.y = Float(y)
			self.width = Float(width)
			self.unused = 0
			let rgba = color.rgba
			self.color = float4(Float(rgba.r), Float(rgba.g), Float(rgba.b), Float(rgba.a))
		}
	}

	struct Uniforms {
		var transform: float4x4
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
//		vertexDescriptor.attributes[0].offset = 0
//		vertexDescriptor.attributes[0].format = .float2
//		vertexDescriptor.attributes[0].bufferIndex = 0
//		vertexDescriptor.attributes[1].offset = MemoryLayout<float4>.size
//		vertexDescriptor.attributes[1].format = .float4
//		vertexDescriptor.attributes[1].bufferIndex = 0

		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState? = {
		guard let library = library else { return nil }
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "point_vertex")!
		renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "point_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = self.pixelFormat
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
		
		let renderPipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
		return renderPipelineState
	}()

	func render(context: MetallicContext, vertexBuffer: MetallicBuffer<Vertex>) {
		let uniforms = Uniforms(transform: context.transform)
		let uniformsBuffer = context.makeBuffer(items: [uniforms])!

		let commandBuffer = commandQueue.makeCommandBuffer()!
		let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: context.renderPassDescriptor)!
		let renderPipelineState = self.renderPipelineState!

		encoder.setRenderPipelineState(renderPipelineState)
		encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
		encoder.setVertexBuffer(uniformsBuffer.buffer, offset: 0, index: 1)
		
		encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexBuffer.count)

		encoder.endEncoding()
		commandBuffer.commit()
	}
	
}

extension MetallicContext {

	typealias Vertex = PointRenderer.Vertex
	
	func renderPoints(points: [CGPoint], color: NSColor, width: CGFloat) {
		let renderer = metallic.renderer() as PointRenderer
		var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		color.getRed(&r, green: &g, blue: &b, alpha: &a)

		let vertices = points.map { Vertex(x: Float($0.x), y: Float($0.y), width: Float(width), r: Float(r), g: Float(g), b: Float(b), a: Float(a)) }
		guard let verticesBuffer = self.makeBuffer(items: vertices) else { fatalError() }
		renderer.render(context: self, vertexBuffer: verticesBuffer)
	}

	func renderPoints(points: [PointRenderer.Vertex]) {
		let renderer = metallic.renderer() as PointRenderer
		guard let verticesBuffer = self.makeBuffer(items: points) else { fatalError() }
		renderer.render(context: self, vertexBuffer: verticesBuffer)
	}
}


