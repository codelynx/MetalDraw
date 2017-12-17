//
//  MetallicCanvas.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/15/17.
//

import Cocoa
import MetalKit


class MettalicCanvasScene: MetallicScene {

	var isDymanic: Bool = false
	var layers = [MetallicCanvasLayer]()

	lazy var canvasTexture: MTLTexture? = {
		guard let metallic = self.metallic else { return nil }
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metallic.pixelFormat, width: Int(self.width), height: Int(self.height), mipmapped: false)
		let texture = self.metallic?.device.makeTexture(descriptor: descriptor)
		return texture
	}()

	func makeRenderingTexture() -> MTLTexture? {
		guard let metallic = self.metallic else { return nil }
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metallic.pixelFormat, width: Int(self.width), height: Int(self.height), mipmapped: false)
		let texture = self.metallic?.device.makeTexture(descriptor: descriptor)
		return texture
	}

	override func render(context: MetallicContext) {

		let commandQueue = context.commandQueue
		guard let canvasTexture = self.canvasTexture else { return }

		// clear canvasTexture
		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = canvasTexture
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		if let commandBuffer = commandQueue.makeCommandBuffer(),
			let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
			commandEncoder.endEncoding()
			commandBuffer.commit()
		}

		// layer
		for layer in layers {
			let renderingTexture = self.makeRenderingTexture()
			let renderPassDescriptor = MTLRenderPassDescriptor()
			renderPassDescriptor.colorAttachments[0].texture = renderingTexture
			renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
			renderPassDescriptor.colorAttachments[0].loadAction = .clear
			renderPassDescriptor.colorAttachments[0].storeAction = .store
			if let commandBuffer = commandQueue.makeCommandBuffer(),
				let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				commandEncoder.endEncoding()
				commandBuffer.commit()
			}
			let scale = Float(1)
            let state = MetallicState(renderPassDescriptor: renderPassDescriptor, transform: context.transform, scale: scale, dictionary: [:])
            let context = MetallicContext(metallic: context.metallic, state: state)
			layer.render(context: context)
			

		}
	}


}

