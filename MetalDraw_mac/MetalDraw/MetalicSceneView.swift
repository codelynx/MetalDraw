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
			setNeedsDisplay()
		}
	}

	override func layout() {
		super.layout()
		self.device = MetalicDevice.shared.device
		self.wantsLayer = true
		self.layer?.backgroundColor = NSColor.white.cgColor
		self.layer?.borderWidth = 1.0
		self.layer?.borderColor = NSColor.red.cgColor
		self.delegate = self
		
	}

	override var isFlipped: Bool { return true }

	// MARK: -

	var renderingTransform: CGAffineTransform? {
		guard let scene = self.scene else { return nil }
		let rect = scene.bounds
		let center = rect.midXmidY
		let t1 = CGAffineTransform(translationX: -center.x, y: -center.y)
		let t2 = CGAffineTransform(scaleX: 2.0 / rect.width, y: 2.0 / rect.height)
		let t3 = CGAffineTransform(scaleX: 1.0, y: -1.0)
		return t1 * t2 * t3
	}

	// MARK: -

	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		print("\(#function)")
	}

	func draw(in view: MTKView) {
		print("bounds: \(self.bounds)")
        guard let drawable = self.currentDrawable else { return }
        let commandQueue = MetalicDevice.shared.commandQueue

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture // error on simulator target
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store


        if let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
            commandEncoder.endEncoding()
            commandBuffer.commit()
        }

        if let scene = self.scene, let t = self.renderingTransform {
            let t = float4x4(affineTransform: t)
            let state = MetalicState(renderPassDescriptor: renderPassDescriptor, transform: t, dictionary: [:])
            let context = MetalicContext(commandQueue: commandQueue, state: state)
            scene.render(context: context)
        }

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
	}

	// MARK: -

	override func mouseDown(with event: NSEvent) {
		self.scene?.mouseDown(with: MetalicEvent(event: event, sceneView: self))
	}

	override func mouseMoved(with event: NSEvent) {
		self.scene?.mouseMoved(with: MetalicEvent(event: event, sceneView: self))
	}

	override func mouseDragged(with event: NSEvent) {
		self.scene?.mouseDragged(with: MetalicEvent(event: event, sceneView: self))
	}

	override func mouseUp(with event: NSEvent) {
		self.scene?.mouseUp(with: MetalicEvent(event: event, sceneView: self))
	}



}
