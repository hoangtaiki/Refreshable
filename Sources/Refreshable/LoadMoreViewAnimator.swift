//
//  LoadMoreAnimator.swift
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

@objc protocol LoadMorable: AnyObject {
    
    var height: CGFloat { get }
    
    func didBeginRefreshing()
    func didEndRefreshing()
}

open class LoadMoreAnimator: UIView, LoadMorable {
    
    let height: CGFloat = 50
    let spinner = UIActivityIndicatorView(style: .medium)
    
    static func footer() -> LoadMoreAnimator {
        return LoadMoreAnimator()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        isHidden = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didBeginRefreshing() {
        isHidden = false
        spinner.startAnimating()
    }
    
    func didEndRefreshing() {
        isHidden = true
        spinner.stopAnimating()
    }
}
