//
//  TextLoadingAnimator.swift
//  iOS Example
//
//  Created by Hoangtaiki on 7/29/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit
import Refreshable

class TextLoadingAnimator: UIView, PullToRefreshDelegate {

    let spinner = UIActivityIndicatorView(style: .gray)

    let titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.init(white: 0.625, alpha: 1.0)
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth

        addSubview(spinner)
        addSubview(titleLabel)
        spinner.isHidden = true
        titleLabel.isHidden = true
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        UIView.performWithoutAnimation {
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
            spinner.center = CGPoint(x: titleLabel.frame.origin.x - 16.0, y: frame.size.height * 0.5)
        }
    }

    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        if state == .idle {
            spinner.isHidden = true
            titleLabel.isHidden = true
        } else if state == .pullToRefresh {
            spinner.isHidden = false
            titleLabel.isHidden = false
        }

        // Update text for title lable
        switch state {
        case .pullToRefresh:
            titleLabel.text = "Pulling"
        case .releaseToRefresh:
            titleLabel.text = "Release to start refresh"
        case .loading:
            titleLabel.text = "Loading..."
        default: break
        }

        self.setNeedsLayout()
    }

    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        spinner.isHidden = false
        spinner.startAnimating()

        titleLabel.isHidden = false
    }

    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        spinner.isHidden = true
        spinner.stopAnimating()

        titleLabel.isHidden = true
    }

}
