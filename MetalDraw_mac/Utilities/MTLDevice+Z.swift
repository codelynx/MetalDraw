//
//  MTLDevice+Z.swift
//  Silvershadow
//
//  Created by Kaz Yoshikawa on 1/10/17.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Foundation
import AppKit
import MetalKit
import Cocoa

extension MTLDevice {

	var textureLoader: MTKTextureLoader {
		return MTKTextureLoader(device: self)
	}

	func makeTexture(named name: String) -> MTLTexture? {
		let filepath = Bundle.main.path(forResource: "test5", ofType: "png")!
		let data = try! Data(contentsOf: URL(fileURLWithPath: filepath))
		do {
			let texture = try self.textureLoader.newTexture(data: data, options: nil)
			print("pixelFormat=\(texture.pixelFormat.rawValue)")
			return texture
		}
		catch { print("\(error)"); fatalError("\(error)") }
		return nil
	}

	#if os(iOS)
	func makeHeap(size: Int) -> MTLHeap {
		let descriptor = MTLHeapDescriptor()
		descriptor.storageMode = .shared
		descriptor.size = size
		return self.makeHeap(descriptor: descriptor)
	}
	#endif
}
