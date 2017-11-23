//
//  MetalDrawView.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa
import MetalKit

extension NSNotification.Name {
	static let displayMetalicScene = NSNotification.Name("DisplayMetalicScene")
}

extension Selector {
	//static let metalicSceneNeedsDisplay = #selector(MetalicView.metalicSceneNeedsDisplay(:_))
}

class MetalicView: NSView {

	static let device = MetalicDevice.shared

	static let pixelFormat = MTLPixelFormat.bgra8Unorm

	var scene: MetalicScene? {
		get { return self.sceneView.scene }
		set {
			self.sceneView.scene = newValue
			if let scene = scene {
				self.sceneView.frame = CGRect(x: 0, y: 0, width: scene.width, height: scene.height)
			}
		}
	}

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
	
	override func layout() {
		super.layout()
		self.setup()
	}

	private (set) lazy var clipView: NSClipView = {
		let clipView = FlippedClipView(frame: self.bounds)
		clipView.translatesAutoresizingMaskIntoConstraints = false
		return clipView
	}()

	private (set) lazy var scrollView: NSScrollView = {
		let scrollView = NSScrollView(frame: self.bounds)
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = true
		scrollView.borderType = .noBorder
		scrollView.drawsBackground = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.allowsMagnification = false
		NotificationCenter.default.addObserver(self, selector: #selector(MetalicView.scrollContentDidChange(_:)),
					name: NSView.boundsDidChangeNotification, object: nil)

		return scrollView
	}()

	private (set) lazy var sceneView: MetalicSceneView = {
		let sceneView = MetalicSceneView(frame: CGRect.zero)
		sceneView.translatesAutoresizingMaskIntoConstraints = false
		return sceneView
	}()

	private lazy var setup: (()->()) = {
		self.sceneView.frame = CGRect(x: 0, y: 0, width: 1024, height: 768)
		self.addSubview(self.scrollView)
		self.scrollView.contentView = self.clipView
		self.clipView.addSubview(self.sceneView);
		self.scrollView.documentView = self.sceneView
		
		self.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
		self.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
		self.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor).isActive = true
		self.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor).isActive = true

		self.scrollView.topAnchor.constraint(equalTo: self.clipView.topAnchor).isActive = true
		self.scrollView.bottomAnchor.constraint(equalTo: self.clipView.bottomAnchor).isActive = true
		self.scrollView.leftAnchor.constraint(equalTo: self.clipView.leftAnchor).isActive = true
		self.scrollView.rightAnchor.constraint(equalTo: self.clipView.rightAnchor).isActive = true

		self.scrollView.maxMagnification = 4
		self.scrollView.minMagnification = 0.5

		NotificationCenter.default.addObserver(self, selector: #selector(MetalicView.displayScene), name:.displayMetalicScene, object: self)
		self.enableSetNeedsDisplay = true
		return {}
	}()

	@objc func displayScene(_ notification: NSNotification) {
		if let sourceScene = notification.object as? MetalicScene, let destinationScene = self.scene, sourceScene == destinationScene {
			self.sceneView.setNeedsDisplay(self.bounds)
		}
	}

	@objc func scrollContentDidChange(_ notification: Notification) {
		self.sceneView.setNeedsDisplay(self.sceneView.bounds)
	}
	
	var allowsMagnification: Bool {
		get { return self.scrollView.allowsMagnification }
		set { self.scrollView.allowsMagnification = newValue }
	}

	var maxMagnification: CGFloat {
		get { return self.scrollView.maxMagnification }
		set { self.scrollView.maxMagnification = newValue }
	}

	var minMagnification: CGFloat {
		get { return self.scrollView.minMagnification }
		set { self.scrollView.minMagnification = newValue }
	}

	var enableSetNeedsDisplay: Bool {
		get { return self.sceneView.enableSetNeedsDisplay }
		set { self.sceneView.enableSetNeedsDisplay = newValue }
	}

}
