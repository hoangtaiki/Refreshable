# Contributing to Refreshable

First off, thank you for considering contributing to Refreshable! It's people like you that make Refreshable such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by the [Refreshable Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for Refreshable. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

**Before Submitting A Bug Report**

* Check the [issues list](https://github.com/hoangtaiki/Refreshable/issues) to see if the problem has already been reported.
* Perform a [cursory search](https://github.com/search?q=+is%3Aissue+user%3Aharrytrn) to see if the problem has already been reported.

**How Do I Submit A Bug Report?**

Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/). Create an issue using the bug report template and provide the following information:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead
* Include screenshots if relevant

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for Refreshable, including completely new features and minor improvements to existing functionality.

**Before Submitting An Enhancement Suggestion**

* Check if the enhancement has already been suggested by searching the [issues list](https://github.com/hoangtaiki/Refreshable/issues).

**How Do I Submit An Enhancement Suggestion?**

Enhancement suggestions are tracked as [GitHub issues](https://guides.github.com/features/issues/). Create an issue using the feature request template.

### Pull Requests

The process described here has several goals:

- Maintain Refreshable's quality
- Fix problems that are important to users
- Engage the community in working toward the best possible Refreshable
- Enable a sustainable system for Refreshable's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in [the template](PULL_REQUEST_TEMPLATE.md)
2. Follow the [styleguides](#styleguides)
3. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing

## Styleguides

### Swift Styleguide

All Swift code should adhere to the [Swift Style Guide](https://google.github.io/swift/) and pass SwiftLint checks.

* Use 4 spaces for indentation
* Use camelCase for variable and function names
* Use PascalCase for type names
* Prefer explicit types when they enhance clarity
* Use `// MARK:` to organize code sections
* Add documentation comments for public APIs

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

**Commit Message Format:**
```
type(scope): brief description

Detailed description (if necessary)

Closes #123
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

### Documentation Styleguide

* Use [Markdown](https://daringfireball.net/projects/markdown/).
* Reference functions and classes in backticks: \`UIScrollView\`

## Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/Refreshable.git`
3. Create a new branch: `git checkout -b my-feature-branch`
4. Open the project in Xcode
5. Make your changes
6. Add tests if applicable
7. Run tests: `swift test`
8. Run SwiftLint: `swiftlint`
9. Commit your changes
10. Push to your fork and submit a pull request

## Testing

Please include tests for any new functionality. Tests should:

* Be descriptive and test one specific behavior
* Follow the Arrange-Act-Assert pattern
* Include both positive and negative test cases
* Test edge cases and error conditions

Run tests with:
```bash
swift test
```

## Questions?

If you have questions about contributing, please first check the existing issues and documentation. If you can't find an answer, feel free to open a new issue with the "question" label.

Thank you for contributing! 🎉