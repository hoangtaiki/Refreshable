//
//  UIScrollView+PullToRefresh.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

private var pullToRefreshKey: UInt8 = 0
private let pullToRefreshDefaultHeight: CGFloat = 50

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

    public func addPullToRefreshWithAction(_ action: @escaping (() -> ())) {
        let frame = CGRect(x: 0, y: -pullToRefreshDefaultHeight, width: self.frame.size.width, height: pullToRefreshDefaultHeight)
        pullToRefreshView = PullToRefreshView(action: action, frame: frame)
        addSubview(pullToRefreshView!)
    }

    public func startPullToRefresh() {
        pullToRefreshView?.isLoading = true
    }

    public func stopPullToRefresh() {
        pullToRefreshView?.isLoading = false
    }

}
