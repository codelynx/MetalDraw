//
//  Extensions.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/23/17.
//

import Cocoa
import MetalKit

extension NSView {
    func setNeedsDisplay() {
        setNeedsDisplay(bounds)
    }

    @inline(__always) @nonobjc final
    func location(for event : NSEvent) -> NSPoint {
        return convert(event.locationInWindow, from: nil)
    }
}

extension UnsafeMutablePointer {
    @inline(__always)
    init(buffer: MTLBuffer) {
        self.init(OpaquePointer(buffer.contents()))
    }
}

extension UnsafeMutableBufferPointer {
    @inline(__always)
    init(buffer : MTLBuffer, count: Int) {
        self.init(start: .init(buffer: buffer), count: count)
    }
}
