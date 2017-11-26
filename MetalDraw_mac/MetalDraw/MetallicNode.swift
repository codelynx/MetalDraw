//
//  MetallicNode.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/21/17.
//

import Foundation
import MetalKit


protocol MetallicNode {
	var parent: MetallicNode? { get }
	var subnodes: [MetallicNode] { get }
	func render(context: MetallicContext)
}

extension MetallicNode {
	var parent: MetallicNode? { return nil }
	var subnodes: [MetallicNode] { return [] }
}
