# Security Policy

## Supported Versions

We provide security updates for the following versions of Refreshable:

| Version | Supported          |
| ------- | ------------------ |
| 1.3.x   | :white_check_mark: |
| 1.2.x   | :white_check_mark: |
| < 1.2   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in Refreshable, we appreciate your help in disclosing it responsibly.

### Where to Report

Please report security vulnerabilities by emailing **duchoang.vp@gmail.com** with:

- A clear description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Any suggested fixes (if available)

### What to Expect

- **Initial Response**: We aim to acknowledge receipt within 48 hours
- **Assessment**: We'll assess the vulnerability within 5 business days
- **Updates**: We'll provide regular updates on our progress
- **Resolution**: We'll work to fix the issue as quickly as possible

### Responsible Disclosure

To protect our users, we ask that you:

- **Do not** publicly disclose the vulnerability until we've had time to address it
- **Do not** exploit the vulnerability beyond what's necessary for proof-of-concept
- **Do not** access or modify other users' data

### Recognition

We're grateful for security researchers who help keep Refreshable safe. With your permission, we'll:

- Credit you in our security advisory
- Add your name to our acknowledgments (if you prefer)

### Out of Scope

The following are typically **not** considered security vulnerabilities:

- Issues in deprecated versions (< 1.2)
- Theoretical vulnerabilities without proof-of-concept
- Issues that require physical access to the device
- Social engineering attacks
- Issues in third-party dependencies (please report to the respective maintainers)

## Security Best Practices

When using Refreshable in your applications:

### Data Handling

- Always validate data received from network requests
- Implement proper error handling for failed requests
- Use HTTPS for all network communications
- Sanitize user input before displaying

### UI Security

- Be cautious with custom animators that might expose sensitive information
- Consider using `isPrivate` flags for sensitive content during refresh operations
- Implement appropriate loading states to prevent UI confusion

### Memory Management

- Use weak references to avoid retain cycles
- Properly clean up observers and delegates
- Monitor memory usage during intensive refresh operations

## Contact

For security-related questions or concerns:

- **Email**: duchoang.vp@gmail.com
- **Subject**: [Security] Your question here

For general questions, please use our regular support channels.

---

Thank you for helping keep Refreshable and its users safe! 🔒