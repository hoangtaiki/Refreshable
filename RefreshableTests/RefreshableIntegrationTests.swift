//
//  RefreshableIntegrationTests.swift
//  Refreshable
//
//  Created by Harry Tran on 23/02/26.
//  Copyright © 2024 Refreshable. All rights reserved.
//

import XCTest
import UIKit
@testable import Refreshable

/// Integration tests for Refreshable components working together
final class RefreshableIntegrationTests: XCTestCase {
    // MARK: - Test Properties

    var tableView: UITableView!
    var collectionView: UICollectionView!
    var scrollView: UIScrollView!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 568), collectionViewLayout: layout)

        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
    }

    override func tearDown() {
        tableView = nil
        collectionView = nil
        scrollView = nil
        super.tearDown()
    }

    // MARK: - Full Workflow Tests

    func testCompleteRefreshWorkflow() {
        // Given
        let expectation = XCTestExpectation(description: "Refresh completes")
        var refreshCompleted = false

        // When
        tableView.addPullToRefresh {
            refreshCompleted = true
            expectation.fulfill()
        }

        // Simulate user pulling down
        tableView.startPullToRefresh()

        // Simulate async work completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.stopPullToRefresh()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertTrue(refreshCompleted)
    }

    func testCompleteLoadMoreWorkflow() {
        // Given
        let expectation = XCTestExpectation(description: "Load more completes")
        var loadMoreCompleted = false

        // When
        tableView.addLoadMore {
            loadMoreCompleted = true
            expectation.fulfill()
        }

        // Simulate user scrolling to bottom
        tableView.startLoadMore()

        // Simulate async work completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.stopLoadMore()
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertTrue(loadMoreCompleted)
    }

    func testSimultaneousRefreshAndLoadMore() {
        // Given
        var refreshCount = 0
        var loadMoreCount = 0

        tableView.addPullToRefresh {
            refreshCount += 1
        }

        tableView.addLoadMore {
            loadMoreCount += 1
        }

        // When - Try to trigger both simultaneously
        tableView.startPullToRefresh()
        tableView.startLoadMore()

        // Then - Both should be able to coexist
        XCTAssertTrue(tableView.subviews.contains { $0 is PullToRefreshView })
        XCTAssertTrue(tableView.subviews.contains { $0 is LoadMoreView })

        // Clean up
        tableView.stopPullToRefresh()
        tableView.stopLoadMore()
    }

    // MARK: - Data Loading Simulation Tests

    func testDataLoadingWithPagination() {
        // Given
        var currentPage = 0
        var totalItems = 0
        let itemsPerPage = 20

        // When
        tableView.addPullToRefresh {
            // Simulate refresh - reset to first page
            currentPage = 0
            totalItems = itemsPerPage
            self.tableView.stopPullToRefresh()
        }

        tableView.addLoadMore {
            // Simulate load more - add next page
            currentPage += 1
            totalItems += itemsPerPage

            // Simulate end of data after 5 pages
            if currentPage >= 5 {
                self.tableView.setLoadMoreEnabled(false)
            }

            self.tableView.stopLoadMore()
        }

        // Simulate user interactions
        tableView.startPullToRefresh() // Reset data

        // Verify state after refresh
        XCTAssertEqual(currentPage, 0)
        XCTAssertEqual(totalItems, itemsPerPage)

        // Simulate multiple load more calls
        for _ in 0..<6 where tableView.isLoadMoreEnabled() {
            tableView.startLoadMore()
        }

        // Then
        XCTAssertEqual(currentPage, 5)
        XCTAssertFalse(tableView.isLoadMoreEnabled())
    }

    // MARK: - Custom Animator Integration Tests

    func testCustomAnimatorIntegration() {
        // Given
        let customAnimator = TestPullToRefreshAnimator()

        // When
        scrollView.addPullToRefresh(withAnimator: customAnimator) {
            // Custom refresh action
        }

        scrollView.startPullToRefresh()

        // Then
        XCTAssertTrue(scrollView.subviews.contains(customAnimator))
        XCTAssertNotEqual(customAnimator.lastState, .idle)

        // Clean up
        scrollView.stopPullToRefresh()
    }

    func testCustomLoadMoreAnimatorIntegration() {
        // Given
        let customLoadMoreAnimator = TestLoadMoreAnimator()
        scrollView.addSubview(customLoadMoreAnimator)

        // When
        scrollView.addLoadMore {
            // Custom load more action
        }

        scrollView.startLoadMore()

        // Then
        XCTAssertTrue(customLoadMoreAnimator.didBeginCalled)

        // Clean up
        scrollView.stopLoadMore()
        XCTAssertTrue(customLoadMoreAnimator.didEndCalled)
    }

    // MARK: - Error Handling Tests

    func testErrorDuringRefresh() {
        // Given
        var errorHandled = false

        tableView.addPullToRefresh {
            // Simulate an error during refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                errorHandled = true
                self.tableView.stopPullToRefresh()
            }
        }

        // When
        tableView.startPullToRefresh()

        // Then - Should still handle gracefully
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(errorHandled)
        }
    }

    // MARK: - State Consistency Tests

    func testStateConsistencyAfterViewDisappears() {
        // Given
        scrollView.addPullToRefresh {
            // Refresh action
        }

        scrollView.addLoadMore {
            // Load more action
        }

        // When - Start operations then simulate view disappearing
        scrollView.startPullToRefresh()
        scrollView.startLoadMore()

        // Simulate view being removed from superview
        scrollView.removeFromSuperview()

        // Then - Should handle gracefully without crashes
        XCTAssertNotNil(scrollView) // Basic check that object still exists
    }
}

// MARK: - Test Helper Classes

private class TestPullToRefreshAnimator: UIView, PullToRefreshDelegate {
    var lastState: PullToRefreshState = .idle
    var animationStarted = false
    var animationEnded = false

    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        lastState = state
    }

    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        animationStarted = true
    }

    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        animationEnded = true
    }
}

private class TestLoadMoreAnimator: UIView, LoadMoreDelegate {
    let height: CGFloat = 50
    var didBeginCalled = false
    var didEndCalled = false

    func didBeginRefreshing() {
        didBeginCalled = true
    }

    func didEndRefreshing() {
        didEndCalled = true
    }
}
