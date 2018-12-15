//
//  PullToRefreshAnimator.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

open class PullToRefreshAnimator: UIView, PullToRefreshDelegate {

    open var spinner = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth

        addSubview(spinner)
        spinner.isHidden = true
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        spinner.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }

    open func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        switch state {
        case .idle:
            spinner.stopAnimating()
            spinner.isHidden = true
        case .pulling:
            spinner.stopAnimating()
            spinner.isHidden = false
        case .releaseToLoad:
            spinner.stopAnimating()
            spinner.isHidden = false
        case .loading:
            spinner.isHidden = false
            spinner.startAnimating()
        }
    }
}
