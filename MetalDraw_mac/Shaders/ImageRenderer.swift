//
//	ImageRenderer.swift
//	Silvershadow
//
//	Created by Kaz Yoshikawa on 12/22/15.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import MetalKit
import simd

//
//	ImageRenderer
//

class ImageRenderer: MetallicRenderer {

	let metallic: Metallic

	// MARK: -

	struct Vertex {
		var x, y, z, w, u, v: Float
        var unused: float2
        init(x: Float, y: Float, z: Float, w: Float, u: Float, v: Float) {
            self.x = x
            self.y = y
            self.z = z
            self.w = w
            self.u = u
            self.v = v
            self.unused = float2(0)
        }
	}

	struct Uniforms {
		var transform: float4x4
	}

	required init(metallic: Metallic) {
		self.metallic = metallic
	}

	static func vertices(for rect: Rect) -> [Vertex] {
		let (l, r, t, b) = (rect.minX, rect.maxX, rect.maxY, rect.minY)

		//	vertex	(y)		texture	(v)
		//	1---4	(1) 	a---d 	(0)
		//	|	|			|	|
		//	2---3 	(0)		b---c 	(1)
		//

		return [
			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 0),		// 1, a
			Vertex(x: l, y: b, z: 0, w: 1, u: 0, v: 1),		// 2, b
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 1),		// 3, c

			Vertex(x: l, y: t, z: 0, w: 1, u: 0, v: 0),		// 1, a
			Vertex(x: r, y: b, z: 0, w: 1, u: 1, v: 1),		// 3, c
			Vertex(x: r, y: t, z: 0, w: 1, u: 1, v: 0),		// 4, d
		]
	}

	func vertices(for rect: Rect) -> [Vertex] {
		return ImageRenderer.vertices(for: rect)
	}

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.size
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState? = {
		guard let library = library else { return nil }

		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "image_vertex")!
		renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "image_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = metallic.pixelFormat
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha // .one
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha // .one
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

		return try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
	}()

	lazy var colorSamplerState: MTLSamplerState? = {
		let descriptor = MTLSamplerDescriptor()
		descriptor.minFilter = .nearest
		descriptor.magFilter = .linear
		descriptor.sAddressMode = .repeat
		descriptor.tAddressMode = .repeat
		return self.device.makeSamplerState(descriptor: descriptor)
	}()

	func vertexBuffer(for vertices: [Vertex]) -> MetallicBuffer<Vertex>? {
		return try? self.device.makeBuffer(items: vertices)
	}

	func vertexBuffer(for rect: Rect) -> MetallicBuffer<Vertex>? {
		return try? self.device.makeBuffer(items: ImageRenderer.vertices(for: rect))
	}
	
	// MARK: -

	func makeTexture(ciImage: CIImage) -> MTLTexture? {
		return self.metallic.makeTexture(ciImage: ciImage)
	}

	func makeTexture(cgImage: CGImage) -> MTLTexture? {
		let ciImage = CIImage(cgImage: cgImage)
		return self.makeTexture(ciImage: ciImage)
	}

	func makeTexture(named name: String) -> MTLTexture? {
		guard let image = XImage(named: name) else { return nil }
		guard let data = image.tiffRepresentation else { return nil }
		guard let ciImage = CIImage(data: data) else { return nil }
		return makeTexture(ciImage: ciImage)
	}

	// MARK: -

	func renderTexture(context: MetallicContext, texture: MTLTexture, in rect: Rect) {
		guard let renderPipelineState = self.renderPipelineState else { return }
	
		let uniforms = Uniforms(transform: context.transform)
		let uniformsBuffer = try! self.device.makeBuffer(items: [uniforms])

		let vertexBuffer = self.vertexBuffer(for: rect)!

		let commandBuffer = context.makeCommandBuffer()!
		let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: context.renderPassDescriptor)!
		encoder.pushDebugGroup("image")
		encoder.setRenderPipelineState(renderPipelineState)

		encoder.setFrontFacing(.clockwise)
		encoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
		encoder.setVertexBuffer(uniformsBuffer.buffer, offset: 0, index: 1)

		encoder.setFragmentTexture(texture, index: 0)
		encoder.setFragmentSamplerState(self.colorSamplerState, index: 0)

		encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexBuffer.count)
		encoder.popDebugGroup()
		encoder.endEncoding()

		commandBuffer.commit()
		//commandBuffer.waitUntilCompleted()
	}
}


extension MetallicContext {

	func render(texture: MTLTexture, in rect: Rect) {
		let renderer = self.metallic.renderer() as ImageRenderer
		renderer.renderTexture(context: self, texture: texture, in: rect)
	}

	func render(image: XImage?, in rect: Rect) {
		let cgImage = image!.cgImage!
		let texture = self.metallic.makeTexture(cgImage: cgImage)!
		self.render(texture: texture, in: rect)
	}

}

