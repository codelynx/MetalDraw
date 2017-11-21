//
//  MetalDrawView.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa

class MetalDrawView: NSView {

	var scene: MetalScene? {
		didSet {
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
		scrollView.allowsMagnification = true
		NotificationCenter.default.addObserver(self, selector: #selector(MetalDrawView.scrollContentDidChange(_:)),
					name: NSView.boundsDidChangeNotification, object: nil)

		return scrollView
	}()

	private (set) lazy var sceneView: MetalSceneView = {
		let sceneView = MetalSceneView(frame: CGRect.zero)
		sceneView.translatesAutoresizingMaskIntoConstraints = false
		return sceneView
	}()

	private lazy var setup: (()->()) = {
		self.sceneView.frame = CGRect(x: 0, y: 0, width: 2000, height: 2000)
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
		return {}
	}()

	@objc func scrollContentDidChange(_ notification: Notification) {
		print("-----")
		print("\(#function)")

		print(self.window!.contentView!.constraintsAffectingLayout(for: .horizontal))
		print(self.window!.contentView!.constraintsAffectingLayout(for: .vertical))
	}
	
	var allowsMagnification: Bool {
		get { return self.scrollView.allowsMagnification }
		set { self.scrollView.allowsMagnification = newValue }
	}
}
