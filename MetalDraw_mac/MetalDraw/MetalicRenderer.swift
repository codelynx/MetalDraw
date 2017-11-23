//
//  MetalicRenderer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

protocol MetalicRenderer {
	static var device: MetalicDevice { get }

}

extension MetalicRenderer {
	static var device: MetalicDevice { return .shared }

}
