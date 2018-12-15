//
//  PullToRefresh.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit
import QuartzCore

/// Pull to refresh states:
/// idle - The initial state, as well as when pull is cancelled or finished.
/// pulling - When scrollView is being dragged but not to the loading threshold yet
/// releaseToLoad - When scrollView is dragged over the threshold, and releasing would lead to loading
/// loading - loading data state
public enum PullToRefreshState {
    case idle
    case pulling
    case releaseToLoad
    case loading
}

public protocol PullToRefreshDelegate: class {
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState)
}

public class PullToRefreshView: UIView {

    var state: PullToRefreshState = .idle {
        didSet {
            guard state != oldValue else { return }
            delegate?.pullToRefresh(self, stateDidChange: state)
        }
    }

    private weak var scrollView: UIScrollView?

    private var observation: NSKeyValueObservation?

    private weak var delegate: PullToRefreshDelegate?

    private var loadingBlock: (() -> ())?

    private var originalContentInsets: UIEdgeInsets = .zero

    // MARK: Public

    public func startLoading() {
        guard let scrollView = scrollView else { return }
        guard state != .loading else { return }

        state = .loading

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.top = self.originalContentInsets.top + self.frame.size.height

        }, completion: { _ in
            // Call loadingBlock after animation in case it's UI blocking which could cause jittering
            self.loadingBlock?()
        })
    }

    public func stopLoading() {
        guard let scrollView = scrollView else { return }
        guard state == .loading else { return }

        self.state = .idle

        UIView.animate(withDuration: 0.3) {
            scrollView.contentInset = self.originalContentInsets
        }
    }

    // MARK: Lifecycle
    
    public init(frame: CGRect,
                contentView: (PullToRefreshDelegate & UIView)? = nil,
                loadingBlock: (() -> ())? = nil)
    {
        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth

        let contentView = contentView ?? PullToRefreshAnimator(frame: bounds)
        contentView.frame = bounds
        addSubview(contentView)

        self.delegate = contentView
        self.loadingBlock = loadingBlock
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func willMove(toSuperview newSuperview: UIView!) {
        super.willMove(toSuperview: newSuperview)

        observation?.invalidate()

        guard let scrollView = newSuperview as? UIScrollView else { return }
        self.scrollView = scrollView

        scrollView.alwaysBounceVertical = true
        originalContentInsets = scrollView.contentInset

        observation = scrollView.observe(\.contentOffset, options: [.initial]) { [unowned self] (sc, change) in
            self.handleScrollViewOffsetChange()
        }
    }

    deinit {
        observation?.invalidate()
    }

    private func handleScrollViewOffsetChange() {
        guard let scrollView = scrollView else { return }

        if state == .loading {
            // If in loading state and scrolled more than the intended, set contentInset to originalInset + frame.height
            if scrollView.contentOffset.y < -originalContentInsets.top - frame.size.height {
                scrollView.contentInset.top = originalContentInsets.top + frame.size.height
            }
            return
        }

        var adjustedContentInset: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            adjustedContentInset = scrollView.adjustedContentInset
        }

        // If not in pulled down state, reset to idle & return
        guard scrollView.contentOffset.y < -adjustedContentInset.top else {
            state = .idle
            return
        }

        // In pulled down state
        let diff = abs(scrollView.contentOffset.y) - adjustedContentInset.top

        // If the diff is smaller than the refresh view frame, the state is pulling
        if diff <= frame.size.height {
            state = .pulling

            // If the diff passed the view frame threshold
        } else {
            // If still dragging , change the state to release to load
            if scrollView.isDragging {
                state = .releaseToLoad

                // If not dragging anymore, change the state to loading
            } else {
                startLoading()
            }
        }
    }
}
