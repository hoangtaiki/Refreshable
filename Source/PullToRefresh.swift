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
    private var insetTopDelta: CGFloat = 0

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                startLoading()
            } else {
                stopLoading()
            }
        }
    }

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
}

extension PullToRefreshView {

    private func handleScrollViewOffsetChange() {
        guard let scrollView = scrollView else { return }

        // If already in loading state, there are 2 cases when offset would change:
        // 1. Loading finished - the scrollView is scrolling back to its original content inset
        // 2. User scrolls up - in this case we updates scrollView's inset to its original value
        if isLoading {
            let contentOffset = scrollView.contentOffset
            var oldInset = scrollView.contentInset
            var insetTop = originalContentInsets.top

            if -contentOffset.y > originalContentInsets.top {
                insetTop = -contentOffset.y
            }

            if insetTop > frame.size.height + originalContentInsets.top {
                insetTop = frame.size.height + originalContentInsets.top
            }
            oldInset.top = insetTop

            scrollView.contentInset = oldInset
            insetTopDelta = originalContentInsets.top - insetTop

            return
        }

        var adjustedContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            adjustedContentInset = scrollView.adjustedContentInset
        }

        originalContentInsets = scrollView.contentInset

        // If not in pulled down state, simply return
        guard scrollView.contentOffset.y <= -adjustedContentInset.top else { return }

        // When scrollView's offset returns to the original content offset, change the state back to idle
        if scrollView.contentOffset.y == -adjustedContentInset.top {
            state = .idle

            // In pulled down state
        } else {
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
                    isLoading = true
                }
            }
        }
    }

    private func startLoading() {
        guard let scrollView = scrollView else { return }

        let frameHeight = frame.size.height
        let contentInset = scrollView.contentInset
        var contentOffset = CGPoint(x: 0, y: -frameHeight)
        if #available(iOS 11.0, *) {
            contentOffset.y = -scrollView.adjustedContentInset.top - frameHeight
        }
        UIView.animate(
            withDuration: 0.3,
            animations: {
                scrollView.contentInset = UIEdgeInsets(top: frameHeight + contentInset.top,
                                                       left: 0,
                                                       bottom: 0,
                                                       right: 0)
                scrollView.contentOffset = contentOffset

        }, completion: { _ in
            self.state = .loading
            self.loadingBlock?()
        })
    }

    private func stopLoading() {
        guard let scrollView = scrollView else { return }

        UIView.animate(
            withDuration: 0.3,
            animations: {
                var oldInset = scrollView.contentInset
                oldInset.top = oldInset.top + self.insetTopDelta
                scrollView.contentInset = oldInset

        }, completion: { _ in
            self.state = .idle
        })
    }
}
