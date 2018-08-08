# Refreshable
[![Version](https://img.shields.io/cocoapods/v/Refreshable.svg?style=flat)](http://cocoapods.org/pods/Refreshable)
[![License](https://img.shields.io/cocoapods/l/Refreshable.svg?style=flat)](http://cocoapods.org/pods/Refreshable)
[![Platform](https://img.shields.io/cocoapods/p/Refreshable.svg?style=flat)](http://cocoapods.org/pods/Refreshable)
![Language](https://img.shields.io/badge/Language-%20swift%20%20-blue.svg)
[![Build Status](https://travis-ci.org/hoangtaiki/Refreshable.svg)](https://travis-ci.org/hoangtaiki/Refreshable)

Refreshable is a component that give pull to refresh and load more (infinite scrolling) feature for UIScrollView. By extension to UIScrollView, you can easily add features for any subclass of UIScrollView. Refreshable is developed to you can easily customize its UI style.

## Requirements

- Xcode 9 or later
- iOS 9.0 or later
- ARC
- Swift 4.0 or later

## Features

- Support `UIScrollView` and its subclasses `UICollectionView` `UITableView` `UITextView`
- Pull down to refresh and pull up to load more
- Support customize your own style(s)

## Getting Started

### CocoaPods

Install with [CocoaPods](http://cocoapods.org) by adding the following to your `Podfile`:

```
platform :ios, '9.0'
use_frameworks!
pod 'Refreshable'
```

### Swift Package Manager

Install with [Swift Package Manager](https://github.com/apple/swift-package-manager) by adding the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hoangtaiki/Refreshable", from: "1.0.0"),
],
```

### Submodules

Or manually checkout the submodule with `git submodule add git@github.com:hoangtaiki/Refreshable.git`, drag Refreshable.xcodeproj to your project, and add Refreshable as a build dependency.

## Usage
**Add Pull to refresh**

The easiest way to use the pull to refresh feature is use default style from us.
```swift
tableView.addPullToRefresh(action: { [weak self] in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self?.tableView.stopPullToRefresh()
    }
})

```
Add if you want to custom UI you just need conform the `PullToRefreshDelegate` protocol
You can refer `TextLoadingAnimator` we implemented

**Add Load more**

```swift
tableView.addLoadMore(action: { [weak self] in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
       	self?.tableView.stopLoadMore()
    }
})
```
We support disable `load more` when no more data
```swift
tableView.setLoadMoreEnable(false)
```

### Use with RxSwift
I am a fan of reactive programming. I use RxSwift for my projects. If you want use `Refreshable` with RxSwift. Create new file with name `Refreshable+Rx.swift` then copy below code into that file.

```swift
import RxSwift
import RxCocoa
import Refreshable

extension Reactive where Base: UIScrollView {
    
    public var refreshing: Binder<Bool> {
        return Binder(base) { scrollView, isShow in
            if isShow {
            	scrollView.startPullToRefresh()
            } else {
                scrollView.stopPullToRefresh()
            }
        }
    }
    
    public var loadingMore: Binder<Bool> {
        return Binder(base) { scrollView, isShow in
            if isShow {
            	scrollView.startLoadMore()
            } else {
                scrollView.stopLoadMore()
            }
        }
    }

}
```

## Contributing

We’re glad you’re interested in Refreshable, and we’d love to see where you take it. If you have suggestions or bug reports, feel free to send pull request or create new issue.

Thanks, and please *do* take it for a joyride!
