//
//  UIScrollView+Extensions.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 Hoangtaiki. All rights reserved.
//

import UIKit

/// Constant for pull to refresh view association
private var pullToRefreshKey: UInt8 = 0
/// Default height for pull to refresh view
public let pullToRefreshDefaultHeight: CGFloat = 50
/// Constant for load more view association
private var loadMoreKey: UInt8 = 1
/// Default height for load more view
public let loadMoreDefaultHeight: CGFloat = 50

/// Pull To Refresh functionality for UIScrollView
public extension UIScrollView {
    private var pullToRefreshView: PullToRefreshView? {
        get {
            objc_getAssociatedObject(self, &pullToRefreshKey) as? PullToRefreshView
        }
        set {
            pullToRefreshView?.removeFromSuperview()
            objc_setAssociatedObject(self, &pullToRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Add pull to refresh view with default animator
    /// - Parameter action: The action to execute when refresh is triggered
    func addPullToRefresh(action: @escaping (() -> Void)) {
        let origin = CGPoint(x: 0, y: -pullToRefreshDefaultHeight)
        let size = CGSize(width: self.frame.size.width, height: pullToRefreshDefaultHeight)
        let frame = CGRect(origin: origin, size: size)
        pullToRefreshView = PullToRefreshView(action: action, frame: frame)

        guard let refreshView = pullToRefreshView else { return }
        addSubview(refreshView)
    }

    /// Add pull to refresh with a custom animator
    /// - Parameters:
    ///   - animator: The custom animator that conforms to PullToRefreshDelegate
    ///   - height: The height of the pull to refresh view (default: 50)
    ///   - action: The action to execute when refresh is triggered
    func addPullToRefresh(
        withAnimator animator: PullToRefreshDelegate & UIView,
        height: CGFloat = pullToRefreshDefaultHeight,
        action: @escaping (() -> Void)
    ) {
        let frame = CGRect(x: 0, y: -height, width: self.frame.size.width, height: height)
        pullToRefreshView = PullToRefreshView(action: action, frame: frame, animator: animator)

        guard let refreshView = pullToRefreshView else { return }
        addSubview(refreshView)
    }

    /// Programmatically start the pull to refresh animation
    func startPullToRefresh() {
        pullToRefreshView?.isLoading = true
    }

    /// Stop the pull to refresh animation
    func stopPullToRefresh() {
        pullToRefreshView?.isLoading = false
    }
}

/// Load More (Infinite Scrolling) functionality for UIScrollView
public extension UIScrollView {
    private var loadMoreView: LoadMoreView? {
        get {
            objc_getAssociatedObject(self, &loadMoreKey) as? LoadMoreView
        }
        set {
            loadMoreView?.removeFromSuperview()
            objc_setAssociatedObject(self, &loadMoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Add load more view with default animator    
    /// - Parameter action: The action to execute when load more is triggered
    func addLoadMore(action: @escaping () -> Void) {
        let animator = LoadMoreAnimator()
        let size = CGSize(width: frame.size.width, height: animator.height)
        let frame = CGRect(origin: .zero, size: size)
        loadMoreView = LoadMoreView(frame: frame)
        loadMoreView?.refreshAction = action
        loadMoreView?.delegate = animator

        guard let loadView = loadMoreView else { return }
        insertSubview(loadView, at: 0)

        animator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        animator.frame = loadView.bounds
        loadView.addSubview(animator)
    }

    /// Programmatically start the load more animation
    func startLoadMore() {
        loadMoreView?.beginRefreshing()
    }

    /// Stop the load more animation
    func stopLoadMore() {
        loadMoreView?.endRefreshing()
    }

    /// Enable or disable the load more functionality
    /// - Parameter enable: Whether load more should be enabled
    func setLoadMoreEnabled(_ enable: Bool) {
        loadMoreView?.isEnabled = enable
    }

    /// Check if load more is currently enabled
    /// - Returns: True if load more is enabled, false otherwise
    func isLoadMoreEnabled() -> Bool {
        guard let view = loadMoreView else {
            return false
        }
        return view.isEnabled
    }
}
