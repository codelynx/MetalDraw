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
	private (set) var layers = [MetallicCanvasLayer]()

	func makeRenderingTexture() -> MTLTexture? {
		guard let metallic = self.metallic else { return nil }
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metallic.pixelFormat, width: Int(self.width), height: Int(self.height), mipmapped: false)
		let texture = self.metallic?.device.makeTexture(descriptor: descriptor)
		return texture
	}
/*
	func layerGroups() -> [[MetallicCanvasLayer]] {
		var layerGroups = [[MetallicCanvasLayer]]()
		var layerGroup = [MetallicCanvasLayer]()
		for layer in self.layers {
			if layer.isHidden { continue }
			if layer.isDynamic {
				if layerGroup.count == 0 {
					layerGroup.append(layer)
					layerGroups.append(layerGroup)
					layerGroup = [MetallicCanvasLayer]()
				}
				else {
					
				}
			}
		}
		return layerGroups
	}
*/

	override func render(context: MetallicContext) {

		let commandQueue = context.commandQueue

		// layer
		for layer in layers {

			// render on working texture
			let renderingTexture = self.makeRenderingTexture()!
			let renderPassDescriptor = MTLRenderPassDescriptor()
			renderPassDescriptor.colorAttachments[0].texture = renderingTexture
			renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0) // clear color
			renderPassDescriptor.colorAttachments[0].loadAction = .clear
			renderPassDescriptor.colorAttachments[0].storeAction = .store
			if let commandBuffer = commandQueue.makeCommandBuffer(),
				let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				commandEncoder.endEncoding()
				commandBuffer.commit()
			}
			let scale = Float(1)
			let rect = self.bounds
			let center = rect.midXmidY
			let t1 = CGAffineTransform(translationX: -center.x, y: -center.y)
			let t2 = CGAffineTransform(scaleX: 2.0 / rect.width, y: 2.0 / rect.height)
//			let t3 = CGAffineTransform(scaleX: 1.0, y: -1.0)
			let transform = float4x4(affineTransform: t1 * t2)
			
            let state = MetallicState(renderPassDescriptor: renderPassDescriptor, transform: transform, scale: scale, dictionary: [:])
            let context2 = MetallicContext(metallic: context.metallic, state: state)
			layer.render(context: context2)

			context.render(texture: renderingTexture, in: Rect(0, 0, 1024, 768))

		}
	}

	func add(layer: MetallicCanvasLayer) {
		layer.canvas = self
		self.layers.append(layer)
	}

}


