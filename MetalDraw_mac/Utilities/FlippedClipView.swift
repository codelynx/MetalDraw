//
//  FlippedClipView.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/20/17.
//

import Cocoa

#if os(macOS)
class FlippedClipView: NSClipView {

	override var isFlipped: Bool { return true }

}
#endif

