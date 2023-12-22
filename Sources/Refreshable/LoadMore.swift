//
//  LoadMore.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/25/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

private func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
        case let (l?, r?):
            return l <= r
        case (nil, _?):
            return true
        default:
            return false
    }
}

private enum LoadMoreState {
    case idle
    case refreshing
}

class LoadMoreView: UIView {
    
    weak var delegate: LoadMorable?
    var refreshAction: (() -> Void)?
    
    var isEnabled = true {
        didSet {
            if isEnabled != oldValue {
                if !isEnabled {
                    hide()
                } else {
                    show()
                }
            }
        }
    }
    
    private var state: LoadMoreState = .idle {
        didSet {
            if state != oldValue && state == .refreshing {
                delegate?.didBeginRefreshing()
                refreshAction?()
            }
        }
    }
    
    private var attachedScrollView: UIScrollView!
    private var contentSizeObservation: NSKeyValueObservation?
    private var contentOffsetObservation: NSKeyValueObservation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        autoresizingMask = .flexibleWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // Reset default content inset
        if newSuperview == nil {
            resetDefaultContentInset()
            return
        }
        
        guard let scrollview = newSuperview as? UIScrollView else {
            return
        }
        
        attachedScrollView = scrollview
        attachedScrollView.alwaysBounceVertical = true
        
        updateContentInset()
        updateFrame()
        addObservations()
    }
    
    func beginRefreshing() {
        if window != nil {
            state = .refreshing
        } else {
            if state != .refreshing {
                state = .idle
            }
        }
    }
    
    func endRefreshing() {
        state = .idle
        delegate?.didEndRefreshing()
    }
    
    private func addObservations() {
        addContentSizeObservation()
        addContentOffsetObservation()
    }
    
    private func removeObservations() {
        contentSizeObservation = nil
        contentOffsetObservation = nil
    }
    
    private func updateContentInset() {
        if isHidden { return  }
        
        var contentInset = attachedScrollView.contentInset
        let bottom = contentInset.bottom + frame.height
        
        contentInset.bottom = bottom
        attachedScrollView.contentInset = contentInset
    }
    
    private func resetDefaultContentInset() {
        // Update default content inset
        var contentInset = attachedScrollView.contentInset
        let bottom = contentInset.bottom - frame.height
        contentInset.bottom = bottom
        attachedScrollView.contentInset = contentInset
    }
    
    private func updateFrame() {
        let origin = CGPoint(x: 0, y: attachedScrollView.contentSize.height)
        frame = CGRect(origin: origin, size: frame.size)
    }
    
    private func addContentSizeObservation() {
        contentSizeObservation = attachedScrollView?.observe(\.contentSize) { [weak self] (_, _) in
            guard let `self` = self else { return }
            
            // Not handle in case load more is not enabled or load more is hidden
            if !self.isEnabled || self.isHidden { return }
            
            self.updateFrame()
        }
    }
    
    private func addContentOffsetObservation() {
        contentOffsetObservation = attachedScrollView?.observe(\.contentOffset, options: [.new, .old]) { [weak self] (_, change) in
            guard let `self` = self else { return }
            
            // Not handle in case load more is not enabled or load more is hidden
            if !self.isEnabled || self.isHidden { return }
            
            if self.state == .refreshing {
                return
            }
            
            let contentInset = self.attachedScrollView.contentInset
            let contentSize = self.attachedScrollView.contentSize
            let contentOffset = self.attachedScrollView.contentOffset
            let scrollViewHeight = self.attachedScrollView.frame.size.height
            let originY = self.frame.origin.y
            
            // Only handle incase content height + inset top > scrollview height
            if contentInset.top + contentSize.height > scrollViewHeight {
                // Check is scrolled to end of scrollview
                if contentOffset.y > originY - scrollViewHeight + contentInset.bottom {
                    // Only start refreshing more when new offset > old offset
                    if change.newValue?.y <= change.oldValue?.y {
                        return
                    }
                    
                    self.beginRefreshing()
                }
            }
        }
    }
    
    deinit {
        removeObservations()
    }
}

extension LoadMoreView {
    
    private func hide() {
        isHidden = true
        resetDefaultContentInset()
    }
    
    private func show() {
        isHidden = false
        updateContentInset()
    }
}
