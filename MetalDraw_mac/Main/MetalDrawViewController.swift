//
//  ViewController.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa

class MetalDrawViewController: NSViewController {

	@IBOutlet weak var metallicView: MetallicView!

	lazy var sampleScene: SampleScene = {
		return SampleScene(bounds: Rect(x: 0, y: 0, width: 1024, height: 768))
	}()

	lazy var sampleCanvas: MetallicCanvas = {
		let canvas = SimpleCanvas(bounds: Rect(x: 0, y: 0, width: 1024, height: 768))
		return canvas
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.metallicView.scene = self.sampleCanvas
	}

}

