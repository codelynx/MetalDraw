//
//  Stack.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Foundation

struct Stack<Element> {
	private var elements : [Element]

	init() {
		elements = []
	}

	mutating func push(_ element: Element) {
		elements.append(element)
	}

	mutating func pop() -> Element? {
		guard let last = elements.last else { return nil }
		defer {
			elements.removeLast()
		}
		return last
	}

	var last: Element? { return elements.last }
}

