//
//  MetallicCanvasLayerGroup.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/24/17.
//

import Foundation
import MetalKit


class MetallicCanvasLayerGroup {

	unowned var canvas: MetallicCanvas
	var needsUpdate = true
	let isStatic: Bool

	var layers = [MetallicCanvasLayer]() {
		didSet {
			self.needsUpdate = true
		}
	}

	init(canvas: MetallicCanvas, isStatic: Bool) {
		self.canvas = canvas
		self.isStatic = isStatic
    }

	private var _texture: MTLTexture?

	var texture: MTLTexture {
		let texture: MTLTexture = _texture ?? makeTexture()
		_texture = texture
		return texture
	}

	private func makeTexture() -> MTLTexture {
		self.needsUpdate = true
		guard let device = self.canvas.metallic?.device else { fatalError() }
		guard let pixelFormat = canvas.metallic?.pixelFormat else { fatalError() }

		let (width, height) = (Int(canvas.width), Int(canvas.height))
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
		descriptor.storageMode = .managed
		descriptor.usage = [.shaderRead, .shaderWrite]
		guard let texture = device.makeTexture(descriptor: descriptor) else { fatalError() }
		return texture
	}

	private func releaseTexture() {
		_texture = nil
	}

	func render(context: MetallicContext) {
		let texture = self.texture

		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = texture
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1) // clear color
		renderPassDescriptor.colorAttachments[0].storeAction = .store

		// clear texture
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		if let commandBuffer = context.commandQueue.makeCommandBuffer(),
			let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
			commandEncoder.endEncoding()
			commandBuffer.commit()
		}
		renderPassDescriptor.colorAttachments[0].loadAction = .load

		let scale = Float(1)
		let rect = self.canvas.bounds
		let center = rect.midXmidY
		let t1 = CGAffineTransform(translationX: CGFloat(-center.x), y: CGFloat(-center.y))
		let t2 = CGAffineTransform(scaleX: 2.0 / CGFloat(rect.width), y: 2.0 / CGFloat(rect.height))
		let t3 = CGAffineTransform.identity // CGAffineTransform(scaleX: 1.0, y: -1.0)
		let transform = float4x4(affineTransform: t1 * t2 * t3)

		let state = MetallicState(renderPassDescriptor: renderPassDescriptor, transform: transform, scale: scale, dictionary: [:])
		let context2 = MetallicContext(metallic: context.metallic, state: state)

		for layer in layers {
			layer.render(context: context2)
			context.render(texture: texture, in: canvas.bounds)
		}

		context.render(texture: texture, in: canvas.bounds)
	}

}

extension MetallicCanvasLayerGroup: Equatable {

	static func == (lhs: MetallicCanvasLayerGroup, rhs: MetallicCanvasLayerGroup) -> Bool {
		return Set<MetallicCanvasLayer>(lhs.layers) == Set<MetallicCanvasLayer>(rhs.layers)
	}

}
