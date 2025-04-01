# Changelog

All notable changes to this project will be documented in this file.

This project adheres to the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2025-04-01
### Fixed
- Add Help Command
- Add Version Command
- Fix bug copying files

## [0.2.0] - 2025-03-31
### Fixed
- Improved server check to block execution only when Rails is running with cache_classes = false (i.e., code reloading enabled)

## [0.1.9] - 2025-03-28
### Fixed
- Add server running block

## [0.1.8] - 2025-03-28
### Fixed
- Add new description

## [0.1.7] - 2025-03-27
### Fixed
- Add bundle install debug message

## [0.1.6] - 2025-03-26
### Fixed
- Script now keeps the branch that was executed.

## [0.1.5] - 2025-03-25
### Fixed
- Modified and Untracked files cleaning method.

### Changed
- Code readability

## [0.1.4] - 2025-03-25
### Fixed
- Copying files was conflicting with prevention of running migrations with changed files
