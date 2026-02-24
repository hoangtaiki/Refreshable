//
//  PullToRefreshAnimator.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 Hoangtaiki. All rights reserved.
//

import UIKit

/// Default implementation of pull to refresh animator using UIActivityIndicatorView
open class PullToRefreshAnimator: UIView, PullToRefreshDelegate {
    /// The activity indicator used for the loading animation
    open var spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth

        addSubview(spinner)
        spinner.isHidden = true
    }

    @available(*, unavailable, message: "init(coder:) is not available. Use init(frame:) instead.")
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        spinner.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }

    /// Handles state changes during the pull to refresh gesture
    /// - Parameters:
    ///   - view: The pull to refresh view
    ///   - state: The new state
    open func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        if state == .idle {
            spinner.isHidden = true
        } else if state == .pullToRefresh {
            spinner.isHidden = false
        }
    }

    /// Called when the pull to refresh animation should start
    /// - Parameter view: The pull to refresh view
    open func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        spinner.isHidden = false
        spinner.startAnimating()
    }

    /// Called when the pull to refresh animation should end
    /// - Parameter view: The pull to refresh view
    open func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        spinner.isHidden = true
        spinner.stopAnimating()
    }
}
