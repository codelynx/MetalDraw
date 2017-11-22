//
//  MetalicNode.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit


protocol MetalicNode {
	var parent: MetalicNode? { get }
	var subnodes: [MetalicNode] { get }
	func render(context: MetalicContext)
}

extension MetalicNode {
	var parent: MetalicNode? { return nil }
	var subnodes: [MetalicNode] { return [] }
}
