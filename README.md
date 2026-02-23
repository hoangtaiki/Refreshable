# Refreshable

[![Version](https://img.shields.io/cocoapods/v/Refreshable.svg?style=flat)](http://cocoapods.org/pods/Refreshable)
[![License](https://img.shields.io/cocoapods/l/Refreshable.svg?style=flat)](http://cocoapods.org/pods/Refreshable)
[![Platform](https://img.shields.io/cocoapods/p/Refreshable.svg?style=flat)](http://cocoapods.org/pods/Refreshable)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-orange.svg)](https://github.com/apple/swift-package-manager)
![Language](https://img.shields.io/badge/Language-%20swift%20%20-blue.svg)
[![Build Status](https://github.com/hoangtaiki/Refreshable/workflows/CI/badge.svg)](https://github.com/hoangtaiki/Refreshable/actions)

A modern, lightweight Swift library that provides pull-to-refresh and load-more functionality for UIScrollView and all its subclasses. Built with performance and customization in mind.

## ✨ Features

- 🔄 **Pull-to-refresh** - Smooth pull down gesture to refresh content
- 📱 **Load more** - Infinite scrolling with automatic load more detection
- 🎨 **Highly customizable** - Easy to implement custom animations and styles
- 🚀 **Performance optimized** - Minimal memory footprint and smooth animations
- 📦 **Easy integration** - Simple API with sensible defaults
- 🔧 **Universal support** - Works with UIScrollView, UITableView, UICollectionView, and UITextView

## 📋 Requirements

- Xcode 14.0 or later
- iOS 15.0 or later
- Swift 5.9 or later

## 📦 Installation

### Swift Package Manager (Recommended)

Add Refreshable to your project using Xcode:

1. File → Add Package Dependencies
2. Enter package URL: `https://github.com/hoangtaiki/Refreshable.git`
3. Select version rule and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hoangtaiki/Refreshable.git", from: "2.0.0"),
]
```

### CocoaPods

Add to your `Podfile`:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'YourApp' do
    pod 'Refreshable', '~> 2.0.0'
end
```

## 🚀 Quick Start

### Basic Pull-to-Refresh

```swift
import Refreshable

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add pull-to-refresh with default animation
        tableView.addPullToRefresh { [weak self] in
            self?.refreshData()
        }
    }
    
    private func refreshData() {
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Update your data source
            self.tableView.reloadData()
            
            // Stop the refresh animation
            self.tableView.stopPullToRefresh()
        }
    }
}
```

### Basic Load More

```swift
// Add load more functionality
tableView.addLoadMore { [weak self] in
    self?.loadMoreData()
}

private func loadMoreData() {
    // Load additional data
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        // Append new data to your data source
        
        // Stop the load more animation
        self.tableView.stopLoadMore()
        
        // Disable load more when no more data available
        if noMoreData {
            self.tableView.setLoadMoreEnabled(false)
        }
    }
}
```

## 🎨 Customization

### Custom Pull-to-Refresh Animator

Create a custom animator by conforming to `PullToRefreshDelegate`:

```swift
class CustomRefreshAnimator: UIView, PullToRefreshDelegate {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        imageView.image = UIImage(named: "refresh_icon")
        // Setup constraints...
    }
    
    func pullToRefresh(_ view: PullToRefreshView, stateDidChange state: PullToRefreshState) {
        switch state {
        case .idle:
            // Reset state
            break
        case .pullToRefresh:
            // User is pulling
            imageView.transform = .identity
        case .releaseToRefresh:
            // Ready to refresh
            UIView.animate(withDuration: 0.2) {
                self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
            }
        case .loading:
            // Currently refreshing
            break
        }
    }
    
    func pullToRefreshAnimationDidStart(_ view: PullToRefreshView) {
        // Start your custom animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.0
        rotation.repeatCount = Float.infinity
        imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func pullToRefreshAnimationDidEnd(_ view: PullToRefreshView) {
        // End your custom animation
        imageView.layer.removeAllAnimations()
        imageView.transform = .identity
    }
}

// Use the custom animator
let customAnimator = CustomRefreshAnimator()
tableView.addPullToRefresh(withAnimator: customAnimator, height: 60) {
    // Refresh action
}
```

## 📚 Advanced Usage

### Programmatic Control

```swift
// Start refresh programmatically
tableView.startPullToRefresh()

// Check load more status
if tableView.isLoadMoreEnabled() {
    // Load more is currently enabled
}

// Disable load more temporarily
tableView.setLoadMoreEnabled(false)
```

### Integration with Modern Swift

#### Async/Await Support

```swift
tableView.addPullToRefresh { [weak self] in
    Task {
        await self?.refreshDataAsync()
        await MainActor.run {
            self?.tableView.stopPullToRefresh()
        }
    }
}

private func refreshDataAsync() async {
    // Your async data loading logic
}
```

#### Combine Integration

```swift
import Combine

private var cancellables = Set<AnyCancellable>()

tableView.addPullToRefresh { [weak self] in
    self?.dataService.refreshData()
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { _ in
                self?.tableView.stopPullToRefresh()
            },
            receiveValue: { data in
                // Update UI with new data
            }
        )
        .store(in: &self.cancellables)
}
```

## 🔧 Migration Guide

### From 1.2.x to 1.3.x

- `LoadMorable` protocol has been renamed to `LoadMoreDelegate`
- Improved access control - some internal APIs are no longer public
- Enhanced documentation with DocC support

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Run tests: `⌘+U`
4. Run the demo: Open `RefreshableDemo/RefreshableDemo.xcodeproj`

## 📄 License

Refreshable is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

## 🙋‍♂️ Support

- 📧 **Email**: duchoang.vp@gmail.com  
- 🐛 **Issues**: [GitHub Issues](https://github.com/hoangtaiki/Refreshable/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/hoangtaiki/Refreshable/discussions)

---

Made with ❤️ by [Hoangtaiki](https://github.com/hoangtaiki)

## Contributing

We’re glad you’re interested in Refreshable, and we’d love to see where you take it. If you have suggestions or bug reports, feel free to send pull request or create new issue.

Thanks, and please *do* take it for a joyride!
