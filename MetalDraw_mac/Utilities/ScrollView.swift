//
//  ScrollView.swift
//  MetalDraw_mac
//
//  Created by Kaz Yoshikawa on 11/23/17.
//

import Cocoa

public protocol ScrollViewDelegate : class {
    func scrollViewDidChange(_ scrollView : ScrollView)
}

public class ScrollView : NSScrollView {
    public weak var delegate : ScrollViewDelegate? = nil

    open func configure() {

    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        _config()
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        _config()
        configure()
    }

    @objc private func _observeScrolling(_ notification : Notification) {
        delegate?.scrollViewDidChange(self)
    }

    private func _config() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_observeScrolling),
                                               name: NSView.boundsDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
