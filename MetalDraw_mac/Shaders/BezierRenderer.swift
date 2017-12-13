//
//  BezierShaders.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/8/17.
//

import Cocoa
import simd



class BezierRenderer: MetallicRenderer {

	struct KernelOutVertexIn {
		var x: Float16
		var y: Float16
		static let zero = KernelOutVertexIn(x: Float16.zero, y: Float16.zero)
	}

	struct Uniforms {
		var transform: float4x4
	}

	enum PathElementType: UInt8 {
		case lineTo = 2
		case quadCurveTo = 3
		case curveTo = 4
	}

	struct PathElement {
		var pathElementType: PathElementType
		var unused1: UInt8
		var unused2: UInt8
		var unused3: UInt8

		var numberOfVertexes: UInt32

		var p0: Point
		var p1: Point
		var p2: Point
		var p3: Point

		init(type: PathElementType, numberOfVertexes: UInt32, p0: Point, p1: Point, p2: Point, p3: Point) {
			self.pathElementType = type
			self.unused1 = 0
			self.unused2 = 0
			self.unused3 = 0
			self.numberOfVertexes = numberOfVertexes
			(self.p0, self.p1, self.p2, self.p3) = (p0, p1, p2, p3)
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

		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].format = .half2
		vertexDescriptor.attributes[0].bufferIndex = 0

		vertexDescriptor.layouts[0].stepFunction = .perVertex
		vertexDescriptor.layouts[0].stride = MemoryLayout<KernelOutVertexIn>.stride

		return vertexDescriptor
	}

	lazy var renderPipelineState: MTLRenderPipelineState = {
		let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
		renderPipelineDescriptor.vertexDescriptor = self.vertexDescriptor
		renderPipelineDescriptor.vertexFunction = self.library.makeFunction(name: "bezier_vertex")!
		renderPipelineDescriptor.fragmentFunction = self.library.makeFunction(name: "bezier_fragment")!

		renderPipelineDescriptor.colorAttachments[0].pixelFormat = .`default`
		renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
		renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
		renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

		// I don't believe this but this is what it is...
		renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
		renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
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

	func render(pathElement: PathElement, context: MetallicContext) throws {

		let pathElementBuffer = try device.makeBuffer(items: [pathElement])
		let count = min(Int(pathElement.numberOfVertexes), 1000)
		var vertices = [KernelOutVertexIn](repeating: KernelOutVertexIn.zero, count: Int(count))
		let verticesBuffer = try device.makeBuffer(items: vertices)

		let commandBuffer = self.commandQueue.makeCommandBuffer()!
		let uniformsBuffer = context["uniforms"] as! MetallicBuffer<Uniforms>
		
		let brushTexture = context["brush"] as! MTLTexture

		guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }

		computeEncoder.setComputePipelineState(self.computePipelineState)
		computeEncoder.setBuffer(pathElementBuffer.buffer, offset: 0, index: 0)
		computeEncoder.setBuffer(verticesBuffer.buffer, offset: 0, index: 1)
		let threadgroupsPerGrid = MTLSizeMake(1, 1, 1)
		let threadsPerThreadgroup = MTLSizeMake(count, 1, 1)
		computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
		computeEncoder.endEncoding()

		guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: context.renderPassDescriptor) else { return }

		renderEncoder.setRenderPipelineState(self.renderPipelineState)
		renderEncoder.setVertexBuffer(verticesBuffer.buffer, offset: 0, index: 0)
		renderEncoder.setVertexBuffer(uniformsBuffer.buffer, offset: 0, index: 1)

		renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Int(count))
		renderEncoder.endEncoding()
		
		commandBuffer.commit()
	}

}


extension MetallicContext {

	public func renderPath(cgPath: CGPath) {

		typealias PathElement = BezierRenderer.PathElement
		typealias KernelOutVertexIn = BezierRenderer.KernelOutVertexIn

		do {
			let renderer = self.renderer() as BezierRenderer
			let uniforms = BezierRenderer.Uniforms(transform: self.transform)
			let uniformsBuffer = try device.makeBuffer(items: [uniforms])
			self["uniforms"] = uniformsBuffer

//			guard let image: CGImage = NSImage(named: "Particle")?.cgImage else { fatalError() }
			let brushTexture = self.device.makeTexture(named: "Particle")!
			
			self["brush"] = brushTexture

			var startPoint: CGPoint?
			var lastPoint: CGPoint?
			for pathElement in cgPath.pathElements {
				switch pathElement {
				case .moveTo(let p1):
					startPoint = p1
					lastPoint = p1
				case .lineTo(let p1):
					guard let p0 = startPoint else { continue }
					let count = UInt32(ceil((p1 - p0).length))
					let pathElement = PathElement(type: .lineTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point.nan, p3: Point.nan)
					try renderer.render(pathElement: pathElement, context: self)
					lastPoint = p1
				case .quadCurveTo(let p1, let p2):
					guard let p0 = startPoint else { continue }
					let count = UInt32(CGPath.quadraticCurveLength(p0, p1, p2))
					let pathElement = PathElement(type: .quadCurveTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point(p2), p3: Point.nan)
					try renderer.render(pathElement: pathElement, context: self)
					lastPoint = p2
				case .curveTo(let p1, let p2, let p3):
					guard let p0 = startPoint else { continue }
					let count = UInt32(CGPath.approximateCubicCurveLength(p0, p1, p2, p3))
					let pathElement = PathElement(type: .curveTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point(p2), p3: Point(p3))
					try renderer.render(pathElement: pathElement, context: self)
					lastPoint = p3
				case .closeSubpath:
					guard let p0 = lastPoint else { continue }
					guard let p1 = startPoint else { continue }
					let count = UInt32(ceil((p1 - p0).length))
					let pathElement = PathElement(type: .lineTo, numberOfVertexes: count, p0: Point(p0), p1: Point(p1), p2: Point.nan, p3: Point.nan)
					try renderer.render(pathElement: pathElement, context: self)
					lastPoint = nil
				}
			}
		}
		catch { print("\(error)") }
	}

}

