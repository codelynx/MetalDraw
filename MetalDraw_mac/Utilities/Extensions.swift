//
//  Extensions.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/23/17.
//

import Cocoa

extension NSView {
    func setNeedsDisplay() {
        setNeedsDisplay(bounds)
    }
}
