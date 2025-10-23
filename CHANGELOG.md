# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0-dev.6] - 2025-10-23

### Breaking Changes
- Configuration format converted from kebab-case to snake_case to align with Dart's `analysis_options.yaml` conventions

### Added
- Comprehensive suppression system for ignoring specific rules or lines during analysis

### Changed
- Test reorganization plan and improved test coverage

### Tests
- Added comprehensive unit tests for suppression system
- Enhanced test coverage for models and enums

## [0.1.0-dev.5] - 2025-10-09

### Added
- Pana analysis integration in CI/CD pipeline for enhanced code quality checks

### Changed
- Updated package dependencies to latest versions for improved stability and security
- Enhanced lint rules configuration for better code quality enforcement
- Improved code formatting and style consistency across the codebase

### Fixed
- Removed publish limitations to enable proper package distribution

### Refactored
- Added explanatory comments for better code documentation
- Improved type declarations and code organization
- Enhanced code structure for better maintainability

## [0.1.0-dev.4] - 2025-10-08

### Added
- Implicit current folder analysis - users can now run analysis without specifying a target directory ([issue #6](https://github.com/yardexx/dart_shield/issues/6))
- Rule registry system for better rule management and organization
- Improved analysis report handling with better error reporting and progress tracking ([issue #9](https://github.com/yardexx/dart_shield/issues/9))

### Changed
- Enhanced configuration parsing for better flexibility
- Improved report handling and project report structure
- Refactored class declarations for better code organization
- Updated visitor naming for consistency

### Fixed
- Secure random detection in crypto rules
- Hardcoded secrets detection now includes key detection
- Various rule detection improvements

### Tests
- Added comprehensive tests for secure random rule
- Enhanced test coverage for configuration parsing

## [0.1.0-dev.3] - 2024-08-31

### Added
- New rule: `avoid-hardcoded-secrets`

### Changed
- Enhanced documentation.
- Improved code examples.

### Fixed
- Error handling in the CLI.

## [0.1.0-dev.2] - 2024-08-12

### Added
- Adhering "Keep a Changelog" style

### Changed
- Enhanced error handling in the CLI.

## [0.1.0-dev.1] - 2024-08-01

### Added
- Initial version.
