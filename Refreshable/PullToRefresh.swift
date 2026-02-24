//
//  PullToRefresh.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 Hoangtaiki. All rights reserved.
//

import UIKit
import QuartzCore

/// Pull To Refresh State
/// - idle: Default state
/// - loading: When user has triggered refresh
/// - pullToRefresh: When scrollview is being pulled down
/// - releaseToRefresh: When scrolled distance is larger than view's height
public enum PullToRefreshState {
    case idle
    case loading
    case pullToRefresh
    case releaseToRefresh
}

/// Protocol for implementing custom pull to refresh animations
public protocol PullToRefreshDelegate: AnyObject {
    /// Called when refresh animation should start
    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView)
    /// Called when refresh animation should end
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView)
    /// Called when pull to refresh state changes
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState)
}

/// A view that provides pull-to-refresh functionality
public class PullToRefreshView: UIView {
    /// Whether the view is currently in loading state
    var isLoading: Bool = false {
        didSet {
            if isLoading != oldValue {
                if isLoading {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }

    private var observation: NSKeyValueObservation?
    private var scrollView: UIScrollView!
    private var originalContentInset = UIEdgeInsets.zero
    private var insetTopDelta: CGFloat = 0.0

    private var animator: PullToRefreshDelegate
    private var action: (() -> Void) = {}

    /// Convenience initializer with action and default animator
    /// - Parameters:
    ///   - action: The action to execute when refresh is triggered
    ///   - frame: The frame for the pull to refresh view
    public convenience init(action: @escaping (() -> Void), frame: CGRect) {
        var bounds = frame
        bounds.origin.y = 0
        let animator = PullToRefreshAnimator(frame: bounds)
        self.init(frame: frame, animator: animator)
        self.action = action
        addSubview(animator)
    }

    /// Convenience initializer with action and custom animator
    /// - Parameters:
    ///   - action: The action to execute when refresh is triggered
    ///   - frame: The frame for the pull to refresh view
    ///   - animator: The custom animator that conforms to PullToRefreshDelegate
    public convenience init(action: @escaping (() -> Void), frame: CGRect, animator: PullToRefreshDelegate & UIView) {
        self.init(frame: frame, animator: animator)
        self.action = action
        animator.frame = bounds
        addSubview(animator)
    }

    /// Designated initializer
    /// - Parameters:
    ///   - frame: The frame for the pull to refresh view
    ///   - animator: The animator that conforms to PullToRefreshDelegate
    public init(frame: CGRect, animator: PullToRefreshDelegate & UIView) {
        self.animator = animator
        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth

        // Setup accessibility
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("Pull to refresh", comment: "Accessibility label for pull to refresh")
        self.accessibilityHint = NSLocalizedString("Pull down to refresh content", comment: "Accessibility hint for pull to refresh")
    }

    @available(*, unavailable, message: "init(coder:) is not available. Use init(frame:animator:) instead.")
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func willMove(toSuperview newSuperview: UIView!) {
        super.willMove(toSuperview: newSuperview)

        guard newSuperview is UIScrollView else { return }

        observation?.invalidate()
        scrollView = newSuperview as? UIScrollView
        scrollView.alwaysBounceVertical = true
        originalContentInset = scrollView.contentInset

        observation = scrollView.observe(\.contentOffset, options: [.initial]) { [unowned self] _, _ in
            self.handleScrollViewOffsetChange()
        }
    }

    deinit {
        observation?.invalidate()
    }
}

extension PullToRefreshView {
    private func handleScrollViewOffsetChange() {
        // Why we need that code when isLoading?
        // We need handle two case
        // 1. It is normal case: Scroll and drag then scrollview will scroll to a postion and spin
        // After spin scrollview will scroll to original content inset
        // 2. After scrollview move to and spin. User scroll up. RefreshView and spinner is moved to offset
        // In this case we will update scrollview inset to default value
        if isLoading {
            let contentOffset = scrollView.contentOffset
            var oldInset = scrollView.contentInset
            var insetTop = originalContentInset.top

            if -contentOffset.y > originalContentInset.top {
                insetTop = -contentOffset.y
            }

            if insetTop > frame.size.height + originalContentInset.top {
                insetTop = frame.size.height + originalContentInset.top
            }
            oldInset.top = insetTop

            scrollView.contentInset = oldInset
            insetTopDelta = originalContentInset.top - insetTop
            return
        }

        var adjustedContentInset = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            adjustedContentInset = scrollView.adjustedContentInset
        }

        originalContentInset = scrollView.contentInset

        // We only trigger when use scroll down
        // And content offset must be less than -adjustedContentInset.top
        if scrollView.contentOffset.y < -adjustedContentInset.top {
            if abs(scrollView.contentOffset.y) - adjustedContentInset.top > frame.size.height {
                // After scrollview is scrolled down and it isn't dragged
                // We will animate scrollview (inset and offset) then start spinner animation
                if !scrollView.isDragging {
                    isLoading = true
                    animator.pullToRefresh(self, stateDidChange: .loading)
                } else {
                    animator.pullToRefresh(self, stateDidChange: .releaseToRefresh)
                }
            } else {
                animator.pullToRefresh(self, stateDidChange: .pullToRefresh)
            }
        }

        // When scrollview offset return to the original content offset
        // We will change state to idle and stop spinner
        if -scrollView.contentOffset.y == adjustedContentInset.top {
            animator.pullToRefresh(self, stateDidChange: .idle)
        }
    }

    private func startAnimating() {
        let frameHeight = frame.size.height
        let contentInset = scrollView.contentInset
        var contentOffset = CGPoint(x: 0, y: -frameHeight)
        if #available(iOS 11.0, *) {
            contentOffset.y = -scrollView.adjustedContentInset.top - frameHeight
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.scrollView.contentInset = UIEdgeInsets(top: frameHeight + contentInset.top, left: 0, bottom: 0, right: 0)
            self.scrollView.contentOffset = contentOffset
        }, completion: { _ in
            self.animator.pullToRefreshAnimationDidStart(self)
            self.action()
        })
    }

    private func stopAnimating() {
        UIView.animate(withDuration: 0.3, animations: {
            var oldInset = self.scrollView.contentInset
            oldInset.top += self.insetTopDelta
            self.scrollView.contentInset = oldInset
        }, completion: { _ in
            self.animator.pullToRefreshAnimationDidEnd(self)
        })
    }
}
