//
//  BezierShaders.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/8/17.
//

import Cocoa
import simd



class BezierRenderer: MetallicRenderer {

	struct VertexIn {
		var x: Float16
		var y: Float16
		var w1: Float16
		var w2: Float16
		static let zero = VertexIn(x: Float16.zero, y: Float16.zero, w1: Float16.zero, w2: Float16.zero)
	}

	struct Uniforms {
		var transform: float4x4
		var scale: Float
		var unused1, unused2, unused3: Float
		init(transform: float4x4, scale: Float) {
			self.transform = transform
			self.scale = scale
			(self.unused1, self.unused2, self.unused3) = (0, 0, 0)
		}
	}

	enum PathElementType: UInt8 {
		case lineTo = 1
		case quadCurveTo = 2
		case curveTo = 3
	}

	struct PathElement {
		var pathElementType: UInt8
		var unused1: UInt8
		var unused2: UInt8
		var unused3: UInt8

		var numberOfVertexes: UInt32

		var p0: Point
		var p1: Point
		var p2: Point
		var p3: Point

		var w1: Float
		var w2: Float

		init(type: PathElementType, numberOfVertexes: UInt32, p0: Point, p1: Point, p2: Point, p3: Point) {
			self.pathElementType = type.rawValue
			self.unused1 = 0
			self.unused2 = 0
			self.unused3 = 0
			self.numberOfVertexes = numberOfVertexes
			(self.p0, self.p1, self.p2, self.p3) = (p0, p1, p2, p3)
			(self.w1, self.w2) = (8, 16)
		}
	}


	let metallic: Metallic

	required init(metallic: Metallic) {
		self.metallic = metallic
	}

	// MARK: -

	lazy var library: MTLLibrary = {
		return self.device.makeDefaultLibrary()!
	}()

	lazy var computePipelineState: MTLComputePipelineState = {
		let function = self.library!.makeFunction(name: "bezier_kernel")!
		return try! self.device.makeComputePipelineState(function: function)
	}()

	var vertexDescriptor: MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<VertexIn>.stride
		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "bezier_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "bezier_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = metallic.pixelFormat
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		// I don't believe this but this is what it is...
		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
		renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

		return try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
	}()

	lazy var samplerState: MTLSamplerState? = {
		let descriptor = MTLSamplerDescriptor()
		descriptor.minFilter = .nearest
		descriptor.magFilter = .linear
		descriptor.sAddressMode = .repeat
		descriptor.tAddressMode = .repeat
		return self.device.makeSamplerState(descriptor: descriptor)!
	}()

	func render(context: MetallicContext, pathElement: PathElement, uniformsBuffer: MetallicBuffer<Uniforms>, brushTexture: MTLTexture) throws {

		let pathElementBuffer = try device.makeBuffer(items: [pathElement])
		let count = Int(pathElement.numberOfVertexes)
		let vertices = [VertexIn](repeating: VertexIn.zero, count: Int(count))
		let verticesBuffer = try device.makeBuffer(items: vertices)

		let commandBuffer = self.commandQueue.makeCommandBuffer()!
		let samplerState = self.samplerState!

		let computeEncoder = commandBuffer.makeComputeCommandEncoder()!

		computeEncoder.setComputePipelineState(self.computePipelineState)
		computeEncoder.setBuffer(pathElementBuffer.buffer, offset: 0, index: 0)
		computeEncoder.setBuffer(verticesBuffer.buffer, offset: 0, index: 1)
		let threadWidth = 64
		let threadsPerThreadgroup = MTLSizeMake(threadWidth, 1, 1)
		let threadgroupsPerGrid = MTLSizeMake((count + threadWidth - 1) / threadWidth, 1, 1)
		computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
		computeEncoder.endEncoding()

		let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: context.renderPassDescriptor)!

		renderEncoder.setRenderPipelineState(self.renderPipelineState)
		renderEncoder.setVertexBuffer(verticesBuffer.buffer, offset: 0, index: 0)
		renderEncoder.setVertexBuffer(uniformsBuffer.buffer, offset: 0, index: 1)
		renderEncoder.setFragmentTexture(brushTexture, index: 0)
		renderEncoder.setFragmentSamplerState(samplerState, index: 0)

		renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(count))
		renderEncoder.endEncoding()
		
		commandBuffer.commit()
	}

}


extension MetallicContext {

	public func renderPath(cgPath: CGPath, scale: Float) {

		typealias PathElement = BezierRenderer.PathElement
		typealias KernelOutVertexIn = BezierRenderer.VertexIn

		do {
			let renderer = self.renderer() as BezierRenderer
			let uniforms = BezierRenderer.Uniforms(transform: self.transform, scale: scale)
			let uniformsBuffer = try device.makeBuffer(items: [uniforms])
			let brushTexture = self.device.makeTexture(named: "test6")!

			var startPoint: CGPoint?
			var lastPoint: CGPoint?
			for pathElement in cgPath.pathElements {
				switch pathElement {
				case .moveTo(let p1):
					startPoint = p1
					lastPoint = p1
				case .lineTo(let p1):
					guard let p0 = lastPoint else { continue }
					let count = UInt32(ceil((p1 - p0).length))
					let pathElement = PathElement(type: .lineTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point.nan, p3: Point.nan)
					try renderer.render(context: self, pathElement: pathElement, uniformsBuffer: uniformsBuffer, brushTexture: brushTexture)
					lastPoint = p1
				case .quadCurveTo(let p1, let p2):
					guard let p0 = lastPoint else { continue }
					let count = UInt32(CGPath.quadraticCurveLength(p0, p1, p2))
					let pathElement = PathElement(type: .quadCurveTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point(p2), p3: Point.nan)
					try renderer.render(context: self, pathElement: pathElement, uniformsBuffer: uniformsBuffer, brushTexture: brushTexture)
					lastPoint = p2
				case .curveTo(let p1, let p2, let p3):
					guard let p0 = lastPoint else { continue }
					let count = UInt32(CGPath.approximateCubicCurveLength(p0, p1, p2, p3))
					let pathElement = PathElement(type: .curveTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point(p2), p3: Point(p3))
					try renderer.render(context: self, pathElement: pathElement, uniformsBuffer: uniformsBuffer, brushTexture: brushTexture)
					lastPoint = p3
 				case .closeSubpath:
					guard let p0 = lastPoint else { continue }
					guard let p1 = startPoint else { continue }
					let count = UInt32(ceil((p1 - p0).length))
					let pathElement = PathElement(type: .lineTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point.nan, p3: Point.nan)
					try renderer.render(context: self, pathElement: pathElement, uniformsBuffer: uniformsBuffer, brushTexture: brushTexture)
					lastPoint = nil
				}
			}
		}
		catch { print("\(error)") }
	}

}

