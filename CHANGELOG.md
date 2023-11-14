# Change Log

All notable changes to this project are documented below.

The format is based on [keep a changelog](http://keepachangelog.com/) and this project uses [semantic versioning](http://semver.org/).

## [1.0.0] - 2023-11-14
#### Changed
- Complete client rewrite that has API and realtime feature parity with Nakama 3.0.
- Support for the Swift async/await concurrency model.
- Configurable automatic retry support on 500 level server errors.
- Automated session refresh for expired tokens.

## [0.3.0] - 2017-11-08
#### Changed
- Consistently use strings for all `Data` and `UUID` types.

## [0.2.0] - 2017-10-26
#### Added
- Add support for Friends, Groups, Chat, Notifications and Leaderboards.

## [0.1.2] - 2017-10-20
#### Fixed
- Improve Client builder access.

## [0.1.1] - 2017-10-18
#### Added
- Compatible with Swift 4.0.
- Compatible with Nakama 1.1.0.
- Added Carthage and Cocoapods support.

## [0.1.0] - 2017-08-22
### Added
- Initial public release.
