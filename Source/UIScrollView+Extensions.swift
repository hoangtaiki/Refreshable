//
//  UIScrollView+PullToRefresh.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

private var pullToRefreshKey: UInt8 = 0
private var loadMoreKey: UInt8 = 1

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

    public func addPullToRefresh(height: CGFloat = 50,
                                 contentView: (PullToRefreshDelegate & UIView)? = nil,
                                 loadingBlock: @escaping (() -> ()))
    {
        let frame = CGRect(x: 0, y: -height, width: self.frame.size.width, height: height)
        let pullToRefreshView = PullToRefreshView(frame: frame, contentView: contentView, loadingBlock: loadingBlock)

        addSubview(pullToRefreshView)

        self.pullToRefreshView = pullToRefreshView
    }

    public func startPullToRefresh() {
        pullToRefreshView?.isLoading = true
    }

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
    public func addLoadMore(height: CGFloat = 50,
                            contentView: (LoadMoreDelegate & UIView)? = nil,
                            loadingBlock: @escaping (() -> ()))
    {
        let size = CGSize(width: self.frame.size.width, height: height)
        let frame = CGRect(origin: .zero, size: size)
        loadMoreView = LoadMoreView(frame: frame, contentView: contentView, loadingBlock: loadingBlock)
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
