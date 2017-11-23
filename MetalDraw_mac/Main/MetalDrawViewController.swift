//
//  ViewController.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa

class MetalDrawViewController: NSViewController {

	@IBOutlet weak var metalicView: MetalicView!

	lazy var sampleScene: SampleScene = {
		return SampleScene(bounds: CGRect(x: 0, y: 0, width: 1024, height: 768))
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.metalicView.scene = self.sampleScene
	}

	override var representedObject: Any? {
		didSet {
		}
	}

}

