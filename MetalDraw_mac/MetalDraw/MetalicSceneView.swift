//
//  MetalicSceneView.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import MetalKit

class MetalicSceneView: MTKView, MTKViewDelegate {

	var scene: MetalicScene? {
		didSet {
			self.setNeedsDisplay(self.bounds)
		}
	}

	override func layout() {
		super.layout()
		self.device = MetalicDevice.shared?.device
		self.wantsLayer = true
		self.layer?.backgroundColor = NSColor.white.cgColor
		self.delegate = self
	}

	override var isFlipped: Bool { return true }

	// MARK: -

	private (set) lazy var commandQueue: MTLCommandQueue? = {
		if let device = MetalicView.device,
		   let queue = self.device?.makeCommandQueue() {
			return queue
		}
		return nil
	}()

	// MARK: -

	var drawingTransform: CGAffineTransform? {
		if let contentView = self.window?.contentView,
		   let scene = self.scene {
			let rectInWindow = self.convert(self.bounds, to: contentView)
			let transform0 = CGAffineTransform(translationX: 0, y: self.bounds.height).scaledBy(x: 1, y: -1)
			let transform1 = scene.bounds.transform(to: rectInWindow)
			let transform2 = self.bounds.transform(to: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
			let transform3 = CGAffineTransform.identity.translatedBy(x: 0, y: +1).scaledBy(x: 1, y: -1).translatedBy(x: 0, y: 1)
			#if os(iOS)
			let transform = transform1 * transform2 * transform3
			#elseif os(macOS)
			let transform = transform0 * transform1 * transform2
			#endif
			return transform
		}
		return nil
	}

	var renderingTransform: CGAffineTransform? {
		guard let scene = self.scene else { return nil }
		guard let contentView = self.window?.contentView else { return nil }
		let targetRect = self.convert(self.bounds, to: contentView)
		let deviceRect = CGRect(x: -1, y: -1, width: 2, height: 2)
		let transform = targetRect.transform(to: deviceRect)

/*
//		let targetRect = contentView.convert(self.contentView.bounds, to: self.mtkView)

		let transform0 = CGAffineTransform(translationX: 0, y: self.contentView.bounds.height).scaledBy(x: 1, y: -1)
		let transform1 = scene.bounds.transform(to: targetRect)
		let transform2 = self.mtkView.bounds.transform(to: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
		let transform3 = CGAffineTransform.identity.translatedBy(x: 0, y: +1).scaledBy(x: 1, y: -1).translatedBy(x: 0, y: 1)
		#if os(iOS)
		let transform = transform1 * transform2 * transform3
		#elseif os(macOS)
		let transform = transform0 * transform1 * transform2
		#endif
*/
		return transform
	}

	// MARK: -

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		print("\(#function)")
	}

	func draw(in view: MTKView) {
		if let drawable = self.currentDrawable,
		   let commandQueue = self.commandQueue {

			let renderPassDescriptor = MTLRenderPassDescriptor()
			renderPassDescriptor.colorAttachments[0].texture = drawable.texture // error on simulator target
			renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 0, 1)
			renderPassDescriptor.colorAttachments[0].loadAction = .clear
			renderPassDescriptor.colorAttachments[0].storeAction = .store

			if let commandBuffer = self.commandQueue?.makeCommandBuffer(),
			   let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
				commandEncoder.endEncoding()
				commandBuffer.commit()
			}

			if let scene = self.scene {
				let t = float4x4(1)
				let state = MetalicState(renderPassDescriptor: renderPassDescriptor, transform: t, dictionary: [:])
				let context = MetalicContext(commandQueue: commandQueue, state: state)
				scene.render(context: context)
			}

			if let commandBuffer = commandQueue.makeCommandBuffer() {
				commandBuffer.present(drawable)
				commandBuffer.commit()
			}
		}
	}

	func setNeedsDisplay() {
		self.setNeedsDisplay(self.bounds)
	}
}
