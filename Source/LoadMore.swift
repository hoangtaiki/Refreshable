//
//  LoadMore.swift
//  Refreshable
//
//  Created by Hoangtaiki on 7/25/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

public protocol LoadMoreDelegate: class {
    func loadMoreDidStart(view: LoadMoreView)
    func loadMoreDidEnd(view: LoadMoreView)
}

public class LoadMoreView: UIView {

    private let height: CGFloat

    private weak var scrollView: UIScrollView?

    private var contentOffsetObservation: NSKeyValueObservation?
    private var contentSizeObservation: NSKeyValueObservation?
    private var panStateObservation: NSKeyValueObservation?

    private weak var delegate: LoadMoreDelegate?

    private var loadingBlock: (() -> ())?

    // Default is true. When you set false load more view will be hide
    var isEnabled: Bool = true {
        didSet {
            guard let scrollView = scrollView else { return }

            if isEnabled {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: frame.size.width, height: height)
            } else {
                frame = CGRect(x: 0, y: scrollView.contentSize.height, width: frame.size.width, height: 0)
            }
        }
    }

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
                contentView: (LoadMoreDelegate & UIView)? = nil,
                loadingBlock: (() -> ())?)
    {
        self.height = frame.height

        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth

        let contentView = contentView ?? LoadMoreAnimator(frame: bounds)
        contentView.frame = bounds
        addSubview(contentView)

        self.delegate = contentView
        self.loadingBlock = loadingBlock
    }

    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            removeKeyValueObervation()

        } else {
            guard let scrollView = newSuperview as? UIScrollView else { return }
            self.scrollView = scrollView

            scrollView.alwaysBounceVertical = true

            addKeyValueObservations()
        }
    }

    deinit {
        removeKeyValueObervation()
    }
}

extension LoadMoreView {

    private func startLoading() {
        guard let scrollView = scrollView else { return }

        delegate?.loadMoreDidStart(view: self)

        let frameHeight = frame.height
        let contentSizeHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        let contentInsetBottom = scrollView.contentInset.bottom

        UIView.animate(
            withDuration: 0.3,
            animations: {
                scrollView.contentOffset.y = frameHeight + contentSizeHeight - scrollViewHeight + contentInsetBottom
                scrollView.contentInset.bottom += frameHeight

        }, completion: { _ in
            self.loadingBlock?()
        })
    }

    private func stopLoading() {
        guard let scrollView = scrollView else { return }

        delegate?.loadMoreDidEnd(view: self)

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset.bottom -= self.frame.height
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        })
    }


    private func addKeyValueObservations() {
        guard let scrollView = scrollView else { return }

        contentOffsetObservation = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
            self?.handleContentOffsetChange()
        }

        contentSizeObservation = scrollView.observe(\.contentSize) { [weak self] scrollView, _ in
            self?.handleContentSizeChange()
        }
    }

    private func removeKeyValueObervation() {
        contentOffsetObservation?.invalidate()
        contentSizeObservation?.invalidate()

        contentOffsetObservation = nil
        contentSizeObservation = nil
    }

    private func handleContentOffsetChange() {
        guard let scrollView = scrollView else { return }

        if isLoading || !isEnabled { return }

        if scrollView.contentSize.height <= scrollView.bounds.height { return }
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom {
            isLoading = true
        }
    }

    private func handleContentSizeChange() {
        guard let scrollView = scrollView else { return }

        frame = CGRect(x: 0, y: scrollView.contentSize.height, width: frame.size.width, height: frame.size.height)
    }
}
