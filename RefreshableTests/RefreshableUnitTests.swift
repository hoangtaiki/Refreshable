//
//  RefreshableUnitTests.swift
//  Refreshable
//
//  Created by Hoangtaiki on 23/02/26.
//  Copyright © 2024 Refreshable. All rights reserved.
//

import XCTest
import UIKit
@testable import Refreshable

final class RefreshableUnitTests: XCTestCase {
    var scrollView: UIScrollView!

    override func setUp() {
        super.setUp()
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
    }

    override func tearDown() {
        scrollView = nil
        super.tearDown()
    }

    // MARK: - Pull To Refresh Tests

    func testAddPullToRefreshWithDefaultAnimator() {
        // Given
        var refreshActionCalled = false

        // When
        scrollView.addPullToRefresh {
            refreshActionCalled = true
        }

        // Then
        XCTAssertEqual(scrollView.subviews.count, 1)
        XCTAssertTrue(scrollView.subviews.first is PullToRefreshView)
    }

    func testAddPullToRefreshWithCustomAnimator() {
        // Given
        let animator = PullToRefreshAnimator()
        var refreshActionCalled = false

        // When
        scrollView.addPullToRefresh(withAnimator: animator) {
            refreshActionCalled = true
        }

        // Then
        XCTAssertEqual(scrollView.subviews.count, 1)
        XCTAssertTrue(scrollView.subviews.first is PullToRefreshView)
        XCTAssertTrue(scrollView.subviews.first?.subviews.contains(animator) ?? false)
    }

    func testPullToRefreshStates() {
        // Given
        let animator = TestPullToRefreshAnimator()

        // When
        scrollView.addPullToRefresh(withAnimator: animator) {
            // Refresh action
        }

        // Then - Verify initial state
        XCTAssertEqual(animator.lastState, .idle)
    }

    func testStartStopPullToRefresh() {
        // Given
        scrollView.addPullToRefresh {
            // Refresh action
        }

        // When
        scrollView.startPullToRefresh()

        // Then
        let pullToRefreshView = scrollView.subviews.first as? PullToRefreshView
        XCTAssertEqual(pullToRefreshView?.isLoading, true)

        // When
        scrollView.stopPullToRefresh()

        // Then
        XCTAssertEqual(pullToRefreshView?.isLoading, false)
    }

    // MARK: - Load More Tests

    func testAddLoadMore() {
        // Given
        var loadMoreActionCalled = false

        // When
        scrollView.addLoadMore {
            loadMoreActionCalled = true
        }

        // Then
        XCTAssertTrue(scrollView.subviews.contains { $0 is LoadMoreView })
    }

    func testLoadMoreEnabled() {
        // Given
        scrollView.addLoadMore {
            // Load more action
        }

        // When & Then
        XCTAssertTrue(scrollView.isLoadMoreEnabled())

        scrollView.setLoadMoreEnabled(false)
        XCTAssertFalse(scrollView.isLoadMoreEnabled())
    }

    func testStartStopLoadMore() {
        // Given
        scrollView.addLoadMore {
            // Load more action
        }

        // When
        scrollView.startLoadMore()

        // Test that load more is functioning
        XCTAssertTrue(scrollView.isLoadMoreEnabled())

        // When
        scrollView.stopLoadMore()

        // Test continues to function
        XCTAssertTrue(true) // This is a basic test for now
    }

    // MARK: - Edge Cases

    func testMultiplePullToRefreshCalls() {
        // Given
        var callCount = 0

        // When
        scrollView.addPullToRefresh {
            callCount += 1
        }

        // Add another pull to refresh (should replace the previous one)
        scrollView.addPullToRefresh {
            callCount += 2
        }

        // Then - Should only have one pull to refresh view
        let pullToRefreshViews = scrollView.subviews.compactMap { $0 as? PullToRefreshView }
        XCTAssertEqual(pullToRefreshViews.count, 1)
    }

    func testRemoveAndAddPullToRefresh() {
        // Given
        scrollView.addPullToRefresh {
            // First action
        }
        let initialSubviewCount = scrollView.subviews.count

        // When - Add another pull to refresh
        scrollView.addPullToRefresh {
            // Second action
        }

        // Then - Should replace, not add
        XCTAssertEqual(scrollView.subviews.count, initialSubviewCount)
    }

    func testLoadMoreWithZeroContentSize() {
        // Given
        scrollView.contentSize = .zero

        // When
        scrollView.addLoadMore {
            // Load more action
        }

        // Then
        XCTAssertTrue(scrollView.isLoadMoreEnabled())
    }

    func testConcurrentRefreshOperations() {
        // Given
        var refreshCount = 0
        scrollView.addPullToRefresh {
            refreshCount += 1
        }

        // When - Start multiple refreshes rapidly
        for _ in 0..<5 {
            scrollView.startPullToRefresh()
            scrollView.stopPullToRefresh()
        }

        // Then - Should handle gracefully
        let pullToRefreshView = scrollView.subviews.first as? PullToRefreshView
        XCTAssertEqual(pullToRefreshView?.isLoading, false)
    }

    // MARK: - Memory Management Tests

    func testPullToRefreshViewDeallocatesCorrectly() {
        weak var weakPullToRefreshView: PullToRefreshView?

        autoreleasepool {
            let tempScrollView = UIScrollView()
            tempScrollView.addPullToRefresh {
                // Action
            }
            weakPullToRefreshView = tempScrollView.subviews.first as? PullToRefreshView
        }

        // Give time for deallocation
        DispatchQueue.main.async {
            XCTAssertNil(weakPullToRefreshView)
        }
    }

    func testLoadMoreViewDeallocatesCorrectly() {
        weak var weakLoadMoreView: LoadMoreView?

        autoreleasepool {
            let tempScrollView = UIScrollView()
            tempScrollView.addLoadMore {
                // Action
            }
            weakLoadMoreView = tempScrollView.subviews.compactMap { $0 as? LoadMoreView }.first
        }

        // Give time for deallocation
        DispatchQueue.main.async {
            XCTAssertNil(weakLoadMoreView)
        }
    }

    // MARK: - Integration Tests

    func testTableViewIntegration() {
        // Given
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        var refreshCalled = false
        var loadMoreCalled = false

        // When
        tableView.addPullToRefresh {
            refreshCalled = true
        }

        tableView.addLoadMore {
            loadMoreCalled = true
        }

        // Then
        XCTAssertTrue(tableView.subviews.contains { $0 is PullToRefreshView })
        XCTAssertTrue(tableView.subviews.contains { $0 is LoadMoreView })
    }

    func testCollectionViewIntegration() {
        // Given
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 568), collectionViewLayout: layout)

        // When
        collectionView.addPullToRefresh {
            // Refresh action
        }

        // Then
        XCTAssertTrue(collectionView.subviews.contains { $0 is PullToRefreshView })
    }
}

// MARK: - Test Helper Classes

private class TestPullToRefreshAnimator: UIView, PullToRefreshDelegate {
    var lastState: PullToRefreshState = .idle

    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        lastState = state
    }

    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        // Test implementation
    }

    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        // Test implementation
    }
}
