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
		return SampleScene(bounds: CGRect(x: 0, y: 0, width: 1024, height: 768))
	}()

	lazy var sampleCanvas: MettalicCanvasScene = {
		let canvas = MettalicCanvasScene(bounds: CGRect(x: 0, y: 0, width: 1024, height: 768))
		let layer1 = Sample1CanvasLayer(frame: Rect(x: 0, y: 0, width: 1024, height: 768))
		canvas.add(layer: layer1)
		return canvas
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.metallicView.scene = self.sampleCanvas
	}


}

