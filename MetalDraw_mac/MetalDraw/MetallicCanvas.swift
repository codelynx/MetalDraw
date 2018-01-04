//
//  MetallicCanvas.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/15/17.
//

import Cocoa
import MetalKit


class MetallicCanvas: MetallicScene {

	var isStatic: Bool {
		for layer in self.layers {
			if !layer.isStatic { return false }
		}
		return true
	}

	private (set) var layers = [MetallicCanvasLayer]()

	func makeRenderingTexture() -> MTLTexture? {
		guard let metallic = self.metallic else { return nil }
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metallic.pixelFormat, width: Int(self.width), height: Int(self.height), mipmapped: false)
		descriptor.usage = [.shaderRead, .shaderWrite]
		let texture = metallic.device.makeTexture(descriptor: descriptor)
		return texture
	}

	private var _canvasLayerGroups: [MetallicCanvasLayerGroup]?

	var canvasLayerGroups: [MetallicCanvasLayerGroup] {
		let layerGroups = _canvasLayerGroups ?? computeCanvasLayerGroups()
		_canvasLayerGroups = layerGroups
		return layerGroups
	}

	private func computeCanvasLayerGroups() -> [MetallicCanvasLayerGroup] {
		// flatten static layers
		var groups = [MetallicCanvasLayerGroup]()
		var group: MetallicCanvasLayerGroup?

		for layer in layers {
			if let group = group, group.isStatic && layer.isStatic {
				group.layers.append(layer)
			}
			else {
				let _group = MetallicCanvasLayerGroup(canvas: self, isStatic: layer.isStatic)
				_group.layers.append(layer)
				group = _group
				groups.append(_group)
			}
		}
		return groups
	}

	override func render(context: MetallicContext) {

		let commandQueue = context.commandQueue

/*
		guard let canvasTexture = self.canvasTexture else { return }

		// clear canvasTexture
		let renderPassDescriptor = MTLRenderPassDescriptor()
		renderPassDescriptor.colorAttachments[0].texture = canvasTexture
		renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1)
		renderPassDescriptor.colorAttachments[0].loadAction = .clear
		renderPassDescriptor.colorAttachments[0].storeAction = .store
		if let commandBuffer = commandQueue.makeCommandBuffer(),
			let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
			commandEncoder.endEncoding()
			commandBuffer.commit()
		}
*/

		// layer
		for layerGroup in canvasLayerGroups {

			// render on working texture
			let renderingTexture = self.makeRenderingTexture()!
			let renderPassDescriptor = MTLRenderPassDescriptor()
			renderPassDescriptor.colorAttachments[0].texture = renderingTexture
			renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1) // clear color
			renderPassDescriptor.colorAttachments[0].loadAction = .clear
			renderPassDescriptor.colorAttachments[0].storeAction = .store
			// you may be able to remove this extra commit, but should manage .clear and .load action properly
			if let commandBuffer = commandQueue.makeCommandBuffer(),
				let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				commandEncoder.endEncoding()
				commandBuffer.commit()
			}
			renderPassDescriptor.colorAttachments[0].loadAction = .load
			let scale = Float(1)
			let rect = self.bounds
			let center = CGPoint(rect.midXmidY)
			let t1 = CGAffineTransform(translationX: -center.x, y: -center.y)
			let t2 = CGAffineTransform(scaleX: 2.0 / CGFloat(rect.width), y: 2.0 / CGFloat(rect.height))
			let t3 = CGAffineTransform.identity // CGAffineTransform(scaleX: 1.0, y: -1.0)
			let transform = float4x4(affineTransform: t1 * t2 * t3)
			
            let state = MetallicState(renderPassDescriptor: renderPassDescriptor, transform: transform, scale: scale, dictionary: [:])
            let context2 = MetallicContext(metallic: context.metallic, state: state)
			layerGroup.render(context: context2)

			context.render(texture: renderingTexture, in: self.bounds)

		}
	}

	func prepareCanvas() {
	}

	override func prepareScene() {
		self.prepareCanvas()
	}

	// MARK: -

	func appendLayer(_ layer: MetallicCanvasLayer) {
		layer.canvas = self
		self.layers.append(layer)
		_canvasLayerGroups = nil
	}

	func bringLayer(toFront layer: MetallicCanvasLayer) {
		if let index = self.layers.index(of: layer) {
			let layer = self.layers.remove(at: index)
			self.layers.insert(layer, at: 0)
			_canvasLayerGroups = nil
		}
	}

	func sendLayer(toBack layer: MetallicCanvasLayer) {
		if let index = self.layers.index(of: layer) {
			let layer = self.layers.remove(at: index)
			self.layers.append(layer)
			_canvasLayerGroups = nil
		}
	}

	func removeLayer(_ layer: MetallicCanvasLayer) {
		if let index = self.layers.index(of: layer) {
			_ = self.layers.remove(at: index)
			_canvasLayerGroups = nil
		}
	}

	func insertLayer(_ layer: MetallicCanvasLayer, above: MetallicCanvasLayer) {
		// TODO: implement
		_canvasLayerGroups = nil
	}

	func insertLayer(_ layer: MetallicCanvasLayer, below: MetallicCanvasLayer) {
		// TODO: implement
		_canvasLayerGroups = nil
	}

	// MARK: -

	override func mouseDown(with event: MetallicEvent) {
    }

	override func mouseMoved(with event: MetallicEvent) {
    }

	override func mouseDragged(with event: MetallicEvent) {
    }

	override func mouseUp(with event: MetallicEvent) {
    }

}


