//
//  MTLDevice+Metallic.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

extension MTLDevice {

	func makeBuffer<T>(elements: [T]) -> MetallicBuffer<T>? {
		let buffer = try? MetallicBuffer(device: self, vertices: elements)
		return buffer
	}

}
