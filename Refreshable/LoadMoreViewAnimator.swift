//
//  LoadMoreViewAnimator.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/25/18.
//  Copyright © 2018 Hoangtaiki. All rights reserved.
//

import UIKit

/// Protocol for implementing custom load more animations and states
@objc
public protocol LoadMoreDelegate: AnyObject {
    /// The height of the load more view
    var height: CGFloat { get }

    /// Called when load more animation should start
    func didBeginRefreshing()
    /// Called when load more animation should end
    func didEndRefreshing()
}

/// Default load more animator implementation
open class LoadMoreAnimator: UIView, LoadMoreDelegate {
    /// The height of the load more view
    public let height: CGFloat = 50
    /// The activity indicator used for loading animation
    public let spinner = UIActivityIndicatorView(style: .medium)

    /// Creates a default footer load more animator
    /// - Returns: A new LoadMoreAnimator instance configured for use as a footer
    public static func footer() -> LoadMoreAnimator {
        LoadMoreAnimator()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        isHidden = true
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }

    @available(*, unavailable, message: "init(coder:) is not available. Use init(frame:) instead.")
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Begin the refreshing animation
    public func didBeginRefreshing() {
        isHidden = false
        spinner.startAnimating()
    }

    /// End the refreshing animation
    public func didEndRefreshing() {
        isHidden = true
        spinner.stopAnimating()
    }
}
