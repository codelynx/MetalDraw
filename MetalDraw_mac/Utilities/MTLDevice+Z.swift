//
//  MTLDevice+Z.swift
//  Silvershadow
//
//  Created by Kaz Yoshikawa on 1/10/17.
//  Copyright © 2017 Electricwoods LLC. All rights reserved.
//

import Foundation
import MetalKit

extension MTLDevice {

	var textureLoader: MTKTextureLoader {
		return MTKTextureLoader(device: self)
	}

/*
	func makeTexture(image: CGImage) -> MTLTexture? {
//		let options = [MTKTextureLoader.Option : Any]()
		var options: [MTKTextureLoader.Option : Any] = [
			MTKTextureLoader.Option.SRGB: false as NSNumber
		]

		do { return try self.textureLoader.newTexture(cgImage: image, options: options) }
		catch { fatalError("\(error)") }
	}
*/

	func makeTexture(named name: String) -> MTLTexture? {
		do { return try self.textureLoader.newTexture(name: "Particle", scaleFactor: 1, bundle: nil, options: nil) }
		catch { fatalError("\(error)") }
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
