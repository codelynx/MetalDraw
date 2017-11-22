//
//  MTLDevice+Metalic.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

extension MTLDevice {

	func makeBuffer<T>(elements: [T]) -> MetalicBuffer<T>? {
		let buffer = try? MetalicBuffer(device: self, vertices: elements)
		return buffer
	}

}
