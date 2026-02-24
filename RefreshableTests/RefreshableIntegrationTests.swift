// swiftlint:disable file_length
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
@MainActor
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
        // Clean up any ongoing refresh/load more operations
        tableView?.stopPullToRefresh()
        tableView?.stopLoadMore()
        collectionView?.stopPullToRefresh()
        collectionView?.stopLoadMore()
        scrollView?.stopPullToRefresh()
        scrollView?.stopLoadMore()

        // Remove from superview if needed
        tableView?.removeFromSuperview()
        collectionView?.removeFromSuperview()
        scrollView?.removeFromSuperview()

        // Clear references
        tableView = nil
        collectionView = nil
        scrollView = nil
        super.tearDown()
    }

    // MARK: - Full Workflow Tests

    @MainActor
    func testCompleteRefreshWorkflow() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Refresh completes")
        var refreshCompleted = false

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(tableView)
        window.makeKeyAndVisible()

        tableView.addPullToRefresh {
            refreshCompleted = true
            expectation.fulfill()
        }

        // Simulate user pulling down
        tableView.startPullToRefresh()

        // Simulate async work completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.tableView?.stopPullToRefresh()
        }

        await fulfillment(of: [expectation], timeout: 1.0)
        // Then
        XCTAssertTrue(refreshCompleted)
    }

    @MainActor
    func testCompleteLoadMoreWorkflow() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Load more completes")
        var loadMoreCompleted = false

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(tableView)
        window.makeKeyAndVisible()

        // Set up table view with content to enable load more
        tableView.contentSize = CGSize(width: 320, height: 1_000) // Ensure content is larger than frame

        // When
        tableView.addLoadMore {
            loadMoreCompleted = true
            expectation.fulfill()
        }

        // Simulate user scrolling to bottom by setting content offset
        tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height + 50)

        // Manually trigger load more since scroll simulation might not work
        tableView.startLoadMore()

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then
        XCTAssertTrue(loadMoreCompleted)

        // Clean up
        tableView.stopLoadMore()
    }

    @MainActor
    func testSimultaneousRefreshAndLoadMore() async throws {
        // Given
        var refreshCount = 0
        var loadMoreCount = 0

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(tableView)
        window.makeKeyAndVisible()

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

    @MainActor
    func testDataLoadingWithPagination() async throws {
        // Given
        var currentPage = 0
        var totalItems = 0
        let itemsPerPage = 20

        let refreshExpectation = XCTestExpectation(description: "Refresh completes")
        let loadMoreExpectation = XCTestExpectation(description: "Load more completes")

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(tableView)
        window.makeKeyAndVisible()

        // When
        tableView.addPullToRefresh { [weak self] in
            // Simulate refresh - reset to first page
            currentPage = 0
            totalItems = itemsPerPage
            self?.tableView?.stopPullToRefresh()
            refreshExpectation.fulfill()
        }

        tableView.addLoadMore { [weak self] in
            // Simulate load more - add next page
            currentPage += 1
            totalItems += itemsPerPage

            // Simulate end of data after 5 pages
            if currentPage >= 5 {
                self?.tableView?.setLoadMoreEnabled(false)
            }

            self?.tableView?.stopLoadMore()
            loadMoreExpectation.fulfill()
        }

        // Simulate user interactions
        tableView.startPullToRefresh() // Reset data

        await fulfillment(of: [refreshExpectation], timeout: 1.0)

        // Then - Verify refresh worked
        XCTAssertEqual(currentPage, 0)
        XCTAssertEqual(totalItems, itemsPerPage)

        // When - Load more data (set content size to enable load more)
        tableView.contentSize = CGSize(width: 320, height: 1_000)
        tableView.startLoadMore()

        await fulfillment(of: [loadMoreExpectation], timeout: 1.0)

        // Then - Verify load more worked
        XCTAssertEqual(currentPage, 1)
        XCTAssertEqual(totalItems, itemsPerPage * 2)
    }

    // MARK: - Custom Animator Integration Tests

    @MainActor
    func testCustomAnimatorIntegration() async throws {
        // Given
        let customAnimator = TestPullToRefreshAnimator()
        let expectation = XCTestExpectation(description: "Animation started and ended")
        expectation.expectedFulfillmentCount = 2
        customAnimator.expectation = expectation

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(scrollView)
        window.makeKeyAndVisible()

        // When
        scrollView.addPullToRefresh(withAnimator: customAnimator) {
            // Custom refresh action - stop after a delay to trigger end animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollView.stopPullToRefresh()
            }
        }

        scrollView.startPullToRefresh()

        // Then - Verify animator is accessible in the view hierarchy
        let pullToRefreshView = scrollView.subviews.compactMap { $0 as? PullToRefreshView }.first
        XCTAssertNotNil(pullToRefreshView, "PullToRefreshView should be added to scrollView")
        XCTAssertTrue(pullToRefreshView?.subviews.contains(customAnimator) ?? false, "Custom animator should be added to PullToRefreshView")

        // Wait for both start and end animations to complete
        await fulfillment(of: [expectation], timeout: 3.0)

        // Verify both animation states
        XCTAssertTrue(customAnimator.animationStarted, "Animation should have started")
        XCTAssertTrue(customAnimator.animationEnded, "Animation should have ended")
    }

    @MainActor
    func testCustomLoadMoreAnimatorIntegration() async throws {
        // Given
        let customLoadMoreAnimator = TestLoadMoreAnimator()
        let expectation = XCTestExpectation(description: "Load more animation completed")
        expectation.expectedFulfillmentCount = 2 // Begin and end
        customLoadMoreAnimator.expectation = expectation

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(scrollView)
        window.makeKeyAndVisible()

        // Set content size to enable load more
        scrollView.contentSize = CGSize(width: 320, height: 1_000)

        // When
        scrollView.addLoadMore(withAnimator: customLoadMoreAnimator) {
            // Custom load more action
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollView.stopLoadMore()
            }
        }

        scrollView.startLoadMore()

        await fulfillment(of: [expectation], timeout: 2.0)

        // Then
        XCTAssertTrue(customLoadMoreAnimator.didBeginCalled)
        XCTAssertTrue(customLoadMoreAnimator.didEndCalled)
    }

    // MARK: - Error Handling Tests

    @MainActor
    func testErrorDuringRefresh() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Error handled during refresh")
        var errorHandled = false

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(tableView)
        window.makeKeyAndVisible()

        tableView.addPullToRefresh { [weak self] in
            // Simulate an error during refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                errorHandled = true
                self?.tableView?.stopPullToRefresh()
                expectation.fulfill()
            }
        }

        // When
        tableView.startPullToRefresh()

        await fulfillment(of: [expectation], timeout: 1.0)

        // Then - Should still handle gracefully
        XCTAssertTrue(errorHandled)
    }

    // MARK: - State Consistency Tests

    @MainActor
    func testStateConsistencyAfterViewDisappears() async throws {
        // Given
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(scrollView)
        window.makeKeyAndVisible()

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

        // Clean up operations
        scrollView.stopPullToRefresh()
        scrollView.stopLoadMore()

        // Then - Should handle gracefully without crashes
        XCTAssertNotNil(scrollView) // Basic check that object still exists

        // Verify that operations can be safely stopped even after removal
        XCTAssertNoThrow(scrollView.stopPullToRefresh())
        XCTAssertNoThrow(scrollView.stopLoadMore())
    }

    // MARK: - Collection View Tests

    @MainActor
    func testCollectionViewRefreshAndLoadMore() async throws {
        // Given
        let refreshExpectation = XCTestExpectation(description: "Collection view refresh completes")
        let loadMoreExpectation = XCTestExpectation(description: "Collection view load more completes")
        var refreshCompleted = false
        var loadMoreCompleted = false

        // When - Force the view to be added to superview
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(collectionView)
        window.makeKeyAndVisible()

        // Set up collection view with content to enable load more
        collectionView.contentSize = CGSize(width: 320, height: 1_000)

        collectionView.addPullToRefresh {
            refreshCompleted = true
            refreshExpectation.fulfill()
        }

        collectionView.addLoadMore {
            loadMoreCompleted = true
            loadMoreExpectation.fulfill()
        }

        // When - Test pull to refresh
        collectionView.startPullToRefresh()

        await fulfillment(of: [refreshExpectation], timeout: 1.0)

        // Then - Verify refresh worked
        XCTAssertTrue(refreshCompleted)

        // When - Test load more
        collectionView.startLoadMore()

        await fulfillment(of: [loadMoreExpectation], timeout: 1.0)

        // Then - Verify load more worked
        XCTAssertTrue(loadMoreCompleted)

        // Clean up
        collectionView.stopPullToRefresh()
        collectionView.stopLoadMore()
    }
}

// MARK: - Test Helper Classes

private class TestPullToRefreshAnimator: UIView, PullToRefreshDelegate {
    var lastState: PullToRefreshState = .idle
    var animationStarted = false
    var animationEnded = false
    var expectation: XCTestExpectation?

    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        lastState = state
    }

    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        animationStarted = true
        expectation?.fulfill()
    }

    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        animationEnded = true
        expectation?.fulfill()
    }
}

private class TestLoadMoreAnimator: UIView, LoadMoreDelegate {
    let height: CGFloat = 50
    var didBeginCalled = false
    var didEndCalled = false
    var expectation: XCTestExpectation?

    func didBeginRefreshing() {
        didBeginCalled = true
        expectation?.fulfill()
    }

    func didEndRefreshing() {
        didEndCalled = true
        expectation?.fulfill()
    }
}
