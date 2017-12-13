//
//  NSBezierPath+Z.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 12/9/17.
//

import AppKit

/*
public extension NSBezierPath {

	public var cgPath: CGPath {
		let path = CGMutablePath()
		var points = [CGPoint](repeating: .zero, count: 3)
		for i in 0 ..< self.elementCount {
			let type = self.element(at: i, associatedPoints: &points)
			switch type {
			case .moveToBezierPathElement: path.move(to: points[0])
			case .lineToBezierPathElement: path.addLine(to: points[0])
			case .curveToBezierPathElement: path.addCurve(to: points[2], control1: points[0], control2: points[1])
			case .closePathBezierPathElement: path.closeSubpath()
			}
		}
		return path
	}

}
*/
