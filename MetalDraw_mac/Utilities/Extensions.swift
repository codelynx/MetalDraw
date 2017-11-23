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
}

extension UnsafeMutableBufferPointer {
    @inline(__always)
    init(buffer : MTLBuffer, count: Int) {
        let ptr = UnsafeMutablePointer<Element>(OpaquePointer(buffer.contents()))
        self.init(start: ptr, count: count)
    }
}
