//
//	CoreGraphics+Z.swift
//	ZKit
//
//	Created by Kaz Yoshikawa on 12/12/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

import Foundation
import CoreGraphics
import QuartzCore
import simd

infix operator •
infix operator ×


extension CGRect {
    init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }

	var cgPath: CGPath {
		return CGPath(rect: self, transform: nil)
	}

	func cgPath(cornerRadius: CGFloat) -> CGPath {

		//	+7-------------6+
		//	0				5
		//	|				|
		//	1				4
		//	+2-------------3+

		let cornerRadius = min(size.width * 0.5, size.height * 0.5, cornerRadius)
		let path = CGMutablePath()
		path.move(to: minXmidY + CGPoint(x: 0, y: cornerRadius)) // (0)
		path.addLine(to: minXmaxY - CGPoint(x: 0, y: cornerRadius)) // (1)
		path.addQuadCurve(to: minXmaxY + CGPoint(x: cornerRadius, y: 0), control: minXmaxY) // (2)
		path.addLine(to: maxXmaxY - CGPoint(x: cornerRadius, y: 0)) // (3)
		path.addQuadCurve(to: maxXmaxY - CGPoint(x: 0, y: cornerRadius), control: maxXmaxY) // (4)
		path.addLine(to: maxXminY + CGPoint(x: 0, y: cornerRadius)) // (5)
		path.addQuadCurve(to: maxXminY - CGPoint(x: cornerRadius, y: 0), control: maxXminY) // (6)
		path.addLine(to: minXminY + CGPoint(x: cornerRadius, y: 0)) // (7)
		path.addQuadCurve(to: minXminY + CGPoint(x: 0, y: cornerRadius), control: minXminY) // (0)
		path.closeSubpath()
		return path
	}

	var minXminY: CGPoint { return CGPoint(x: minX, y: minY) }
	var midXminY: CGPoint { return CGPoint(x: midX, y: minY) }
	var maxXminY: CGPoint { return CGPoint(x: maxX, y: minY) }

	var minXmidY: CGPoint { return CGPoint(x: minX, y: midY) }
	var midXmidY: CGPoint { return CGPoint(x: midX, y: midY) }
	var maxXmidY: CGPoint { return CGPoint(x: maxX, y: midY) }

	var minXmaxY: CGPoint { return CGPoint(x: minX, y: maxY) }
	var midXmaxY: CGPoint { return CGPoint(x: midX, y: maxY) }
	var maxXmaxY: CGPoint { return CGPoint(x: maxX, y: maxY) }

	func aspectFill(_ size: CGSize) -> CGRect {
		let result: CGRect
		let margin: CGFloat
		let horizontalRatioToFit = size.width / size.width
		let verticalRatioToFit = size.height / size.height
		let imageHeightWhenItFitsHorizontally = horizontalRatioToFit * size.height
		let imageWidthWhenItFitsVertically = verticalRatioToFit * size.width
		if (imageHeightWhenItFitsHorizontally > size.height) {
			margin = (imageHeightWhenItFitsHorizontally - size.height) * 0.5
			result = CGRect(x: minX, y: minY - margin, width: size.width * horizontalRatioToFit, height: size.height * horizontalRatioToFit)
		}
		else {
			margin = (imageWidthWhenItFitsVertically - size.width) * 0.5
			result = CGRect(x: minX - margin, y: minY, width: size.width * verticalRatioToFit, height: size.height * verticalRatioToFit)
		}
		return result
	}

	func aspectFit(_ size: CGSize) -> CGRect {
		let widthRatio = self.size.width / size.width
		let heightRatio = self.size.height / size.height
		let ratio = min(widthRatio, heightRatio)
		let width = size.width * ratio
		let height = size.height * ratio
		let xmargin = (self.size.width - width) / 2.0
		let ymargin = (self.size.height - height) / 2.0
		return CGRect(x: minX + xmargin, y: minY + ymargin, width: width, height: height)
	}

	func transform(to rect: CGRect) -> CGAffineTransform {
		var t = CGAffineTransform.identity
		t = t.translatedBy(x: -minX, y: -minY)
		t = t.scaledBy(x: 1 / width, y: 1 / height)
		t = t.scaledBy(x: rect.width, y: rect.height)
		t = t.translatedBy(x: rect.minX * width / rect.width, y: rect.minY * height / rect.height)
		return t
	}

}

extension CGSize {

	func aspectFit(_ size: CGSize) -> CGSize {
		let widthRatio = self.width / size.width
		let heightRatio = self.height / size.height
		let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
		let width = size.width * ratio
		let height = size.height * ratio
		return CGSize(width: width, height: height)
	}

	static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
		return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
	}
}


extension CGAffineTransform {

	static func * (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
		return lhs.concatenating(rhs)
	}

}

extension float4x4 {
	init(affineTransform: CGAffineTransform) {
		let t = CATransform3DMakeAffineTransform(affineTransform)
		self.init(
					float4(Float(t.m11), Float(t.m12), Float(t.m13), Float(t.m14)),
					float4(Float(t.m21), Float(t.m22), Float(t.m23), Float(t.m24)),
					float4(Float(t.m31), Float(t.m32), Float(t.m33), Float(t.m34)),
					float4(Float(t.m41), Float(t.m42), Float(t.m43), Float(t.m44)))
	}
}


// MARK: -

protocol FloatCovertible {
	var floatValue: Float { get }
}

extension CGFloat: FloatCovertible {
	var floatValue: Float { return Float(self) }
}

extension Int: FloatCovertible {
	var floatValue: Float { return Float(self) }
}

extension Float: FloatCovertible {
	var floatValue: Float { return self }
}

// MARK: -

protocol CGFloatCovertible {
	var cgFloatValue: CGFloat { get }
}

extension CGFloat: CGFloatCovertible {
	var cgFloatValue: CGFloat { return self }
}

extension Int: CGFloatCovertible {
	var cgFloatValue: CGFloat { return CGFloat(self) }
}

extension Float: CGFloatCovertible {
	var cgFloatValue: CGFloat { return CGFloat(self) }
}



// MARK: -

struct Point: Hashable, CustomStringConvertible {

	var x: Float
	var y: Float

	static func - (lhs: Point, rhs: Point) -> Point {
		return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func + (lhs: Point, rhs: Point) -> Point {
		return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func * (lhs: Point, rhs: Float) -> Point {
		return Point(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	static func / (lhs: Point, rhs: Float) -> Point {
		return Point(x: lhs.x / rhs, y: lhs.y / rhs)
	}

	static func • (lhs: Point, rhs: Point) -> Float { // dot product
		return lhs.x * rhs.x + lhs.y * rhs.y
	}

	static func × (lhs: Point, rhs: Point) -> Float { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}

	init<X: FloatCovertible, Y: FloatCovertible>(_ x: X, _ y: Y) {
		self.x = x.floatValue
		self.y = y.floatValue
	}
	init<X: FloatCovertible, Y: FloatCovertible>(x: X, y: Y) {
		self.x = x.floatValue
		self.y = y.floatValue
	}
	init(_ point: CGPoint) {
		self.x = Float(point.x)
		self.y = Float(point.y)
	}

	var length²: Float {
		return (x * x) + (y * y)
	}

	var length: Float {
		return sqrt(self.length²)
	}

	var normalized: Point {
		let length = self.length
		return Point(x: x/length, y: y/length)
	}

	func angle(to: Point) -> Float {
		return atan2(to.y - self.y, to.x - self.x)
	}

	func angle(from: Point) -> Float {
		return atan2(self.y - from.y, self.x - from.x)
	}

	var hashValue: Int { return self.x.hashValue &- self.y.hashValue }

	static func == (lhs: Point, rhs: Point) -> Bool {
		return lhs.x == rhs.y && lhs.y == rhs.y
	}

	var description: String {
		return "(x:\(x), y:\(y))"
	}
	
	static let zero = Point(x: 0, y: 0)
	static let nan = Point(x: Float.nan, y: Float.nan)

	func offsetBy(x: Float, y: Float) -> Point {
		return Point(x: self.x + x, y: self.y + y)
	}
}


struct Size: CustomStringConvertible {
	var width: Float
	var height: Float

	init<W: FloatCovertible, H: FloatCovertible>(_ width: W, _ height: H) {
		self.width = width.floatValue
		self.height = height.floatValue
	}

	init<W: FloatCovertible, H: FloatCovertible>(width: W, height: H) {
		self.width = width.floatValue
		self.height = height.floatValue
	}
	init(_ size: CGSize) {
		self.width = Float(size.width)
		self.height = Float(size.height)
	}
	var description: String {
		return "(w:\(width), h:\(height))"
	}
}


struct Rect: CustomStringConvertible {
	var origin: Point
	var size: Size

	init(origin: Point, size: Size) {
		self.origin = origin; self.size = size
	}
	init(_ origin: Point, _ size: Size) {
		self.origin = origin; self.size = size
	}
	init<X: FloatCovertible, Y: FloatCovertible, W: FloatCovertible, H: FloatCovertible>(_ x: X, _ y: Y, _ width: W, _ height: H) {
		self.origin = Point(x: x, y: y)
		self.size = Size(width: width, height: height)
	}
	init<X: FloatCovertible, Y: FloatCovertible, W: FloatCovertible, H: FloatCovertible>(x: X, y: Y, width: W, height: H) {
		self.origin = Point(x: x, y: y)
		self.size = Size(width: width, height: height)
	}
	init(_ rect: CGRect) {
		self.origin = Point(rect.origin)
		self.size = Size(rect.size)
	}

	var width: Float { return size.width }
	var height: Float { return size.height }

	var minX: Float { return min(origin.x, origin.x + size.width) }
	var maxX: Float { return max(origin.x, origin.x + size.width) }
	var midX: Float { return (origin.x + origin.x + size.width) / 2.0 }
	var minY: Float { return min(origin.y, origin.y + size.height) }
	var maxY: Float { return max(origin.y, origin.y + size.height) }
	var midY: Float { return (origin.y + origin.y + size.height) / 2.0 }

	var minXminY: Point { return Point(x: minX, y: minY) }
	var midXminY: Point { return Point(x: midX, y: minY) }
	var maxXminY: Point { return Point(x: maxX, y: minY) }

	var minXmidY: Point { return Point(x: minX, y: midY) }
	var midXmidY: Point { return Point(x: midX, y: midY) }
	var maxXmidY: Point { return Point(x: maxX, y: midY) }

	var minXmaxY: Point { return Point(x: minX, y: maxY) }
	var midXmaxY: Point { return Point(x: midX, y: maxY) }
	var maxXmaxY: Point { return Point(x: maxX, y: maxY) }

	var cgRectValue: CGRect { return CGRect(x: CGFloat(origin.x), y: CGFloat(origin.y), width: CGFloat(size.width), height: CGFloat(size.height)) }
	var description: String { return "{Rect: (\(origin.x),\(origin.y))-(\(size.width), \(size.height))}" }

	static var zero = Rect(x: 0, y: 0, width: 0, height: 0)
	
	func offsetBy(x: Float, y: Float) -> Rect {
		return Rect(origin: self.origin.offsetBy(x: x, y: y), size: self.size)
	}

	func offsetBy(point: Point) -> Rect {
		return Rect(origin: self.origin + point, size: self.size)
	}

	func insetBy(dx: Float, dy: Float) -> Rect {
		return Rect(CGRect(self).insetBy(dx: CGFloat(dx), dy: CGFloat(dy)))
	}
}

// MARK: -

protocol PointConvertible {
	var pointValue: Point { get }
}

extension Point: PointConvertible {
	var pointValue: Point { return self }
}

extension CGPoint: PointConvertible {
	var pointValue: Point { return Point(self) }
}


// MARK: -

extension CGPoint {

	init(_ point: Point) {
		self.init(x: CGFloat(point.x), y: CGFloat(point.y))
	}

	static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
	}

	static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}

	static func • (lhs: CGPoint, rhs: CGPoint) -> CGFloat { // dot product
		return lhs.x * rhs.x + lhs.y * rhs.y
	}

	static func × (lhs: CGPoint, rhs: CGPoint) -> CGFloat { // cross product
		return lhs.x * rhs.y - lhs.y * rhs.x
	}

	var length²: CGFloat {
		return (x * x) + (y * y)
	}

	var length: CGFloat {
		return sqrt(self.length²)
	}

	var normalized: CGPoint {
		return self / length
	}
}

extension CGPoint {
	init<X: CGFloatCovertible, Y: CGFloatCovertible>(_ x: X, _ y: Y) {
		self.x = x.cgFloatValue
		self.y = y.cgFloatValue
	}
}


extension CGSize {
	init(_ size: Size) {
		self.init(width: CGFloat(size.width), height: CGFloat(size.height))
	}

	init<W: CGFloatCovertible, H: CGFloatCovertible>(_ width: W, _ height: H) {
		self.width = width.cgFloatValue
		self.height = height.cgFloatValue
	}
}

extension CGRect {
	init(_ rect: Rect) {
		self.init(origin: CGPoint(rect.origin), size: CGSize(rect.size))
	}

	init<X: CGFloatCovertible, Y: CGFloatCovertible, W: CGFloatCovertible, H: CGFloatCovertible>(_ x: X, _ y: Y, _ width: W, _ height: H) {
		self.origin = CGPoint(x, y)
		self.size = CGSize(width, height)
	}
}
