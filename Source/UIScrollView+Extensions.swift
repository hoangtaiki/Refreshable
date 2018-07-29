//
//  UIScrollView+PullToRefresh.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

private var pullToRefreshKey: UInt8 = 0
public let pullToRefreshDefaultHeight: CGFloat = 50
private var loadMoreKey: UInt8 = 1
public let loadMoreDefaultHeight: CGFloat = 50

/// Pull To Refresh
public extension UIScrollView {

    private var pullToRefreshView: PullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &pullToRefreshKey) as? PullToRefreshView
        }
        set {
            pullToRefreshView?.removeFromSuperview()
            objc_setAssociatedObject(self, &pullToRefreshKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // Add pull to refresh view with default animator
    public func addPullToRefresh(action: @escaping (() -> ())) {
        let origin = CGPoint(x: 0, y: -pullToRefreshDefaultHeight)
        let size = CGSize(width: self.frame.size.width, height: pullToRefreshDefaultHeight)
        let frame = CGRect(origin: origin, size: size)
        pullToRefreshView = PullToRefreshView(action: action, frame: frame)

        addSubview(pullToRefreshView!)
    }

    public func addPullToRefresh(withAnimator animator: PullToRefreshDelegate & UIView,
                                 height: CGFloat = pullToRefreshDefaultHeight,
                                 action: @escaping (() -> ())) {
        let frame = CGRect(x: 0, y: -height, width: self.frame.size.width, height: height)
        pullToRefreshView = PullToRefreshView(action: action, frame: frame, animator: animator)

        addSubview(pullToRefreshView!)
    }

    // Start pull to refresh
    public func startPullToRefresh() {
        pullToRefreshView?.isLoading = true
    }

    // Stop pull to refresh
    public func stopPullToRefresh() {
        pullToRefreshView?.isLoading = false
    }
}


/// Infinity Scrolling
public extension UIScrollView {

    private var loadMoreView: LoadMoreView? {
        get {
            return objc_getAssociatedObject(self, &loadMoreKey) as? LoadMoreView
        }
        set {
            loadMoreView?.removeFromSuperview()
            objc_setAssociatedObject(self, &loadMoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // Add load more view with default animator
    public func addLoadMore(action: @escaping (() -> ())) {
        let size = CGSize(width: self.frame.size.width, height: loadMoreDefaultHeight)
        let frame = CGRect(origin: .zero, size: size)
        loadMoreView = LoadMoreView(action: action, frame: frame)
        loadMoreView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(loadMoreView!)
    }

    // Start load more
    public func startLoadMore() {
        loadMoreView?.isLoading = true
    }

    // Stop load more
    public func stopLoadMore() {
        loadMoreView?.isLoading = false
    }

    // Set enable/disable for loading more
    public func setLoadMoreEnable(_ enable: Bool) {
        loadMoreView?.isEnabled = enable
    }
}
