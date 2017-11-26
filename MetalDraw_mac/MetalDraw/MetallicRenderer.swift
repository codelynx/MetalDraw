//
//  MetallicRenderer.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit

protocol MetallicRenderer {
	static var device: MetallicDevice { get }

}

extension MetallicRenderer {
	static var device: MetallicDevice { return .shared }

}
