# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive API documentation with DocC comments
- Enhanced error handling and edge case coverage
- Improved test coverage with unit and integration tests
- Modern Swift concurrency support examples
- GitHub Actions workflows for automated CI/CD
- Code quality tools (SwiftLint, SwiftFormat)

### Changed
- **BREAKING**: `LoadMorable` protocol renamed to `LoadMoreDelegate` for naming consistency
- Enhanced public API with better access control
- Improved documentation and code examples
- Updated package configuration with modern Swift features
- Modernized CI/CD workflows with latest GitHub Actions

### Fixed
- Resolved duplicate `LoadMoreState` enum definitions
- Fixed inconsistent naming conventions across API
- Improved memory management and KVO observation cleanup

### Security
- Updated dependencies to latest secure versions
- Added automated security scanning to CI pipeline

## [1.3.0] - 2024-02-01

### Changed
- Updated for Swift Package Manager compatibility
- Improved iOS 13+ support
- Enhanced documentation

### Fixed
- Various bug fixes and performance improvements

## [1.2.0] - 2018-11-25

### Changed
- Swift 4.2 compatibility

### Added
- Basic pull-to-refresh functionality
- Load more (infinite scrolling) support
- Customizable animator support

## [1.1.0] - 2018-07-25

### Added
- Initial implementation of pull-to-refresh
- Basic load more functionality
- CocoaPods support

## [1.0.0] - 2018-07-20

### Added
- Initial release
- Basic UIScrollView extensions for refresh functionality
- Default animator implementations

---

## Migration Guides

### Migrating from 1.2.x to 1.3.x

1. **Protocol Renaming**: Update `LoadMorable` to `LoadMoreDelegate`
   ```swift
   // Before
   class CustomAnimator: UIView, LoadMorable { }
   
   // After  
   class CustomAnimator: UIView, LoadMoreDelegate { }
   ```

2. **Access Control**: Some internal APIs are no longer public - update your code to use the public API surface

### Migrating to Swift Package Manager

If you're migrating from CocoaPods:

1. Remove `pod 'Refreshable'` from your Podfile
2. Add the Swift Package Manager dependency in Xcode
3. Update import statements (should remain the same)

---

## Support

For questions about releases or migration:
- 📧 Email: duchoang.vp@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/hoangtaiki/Refreshable/issues)

