# Background Geolocation Swift Demo

A SwiftUI demo application for the [Background Geolocation SDK](https://github.com/transistorsoft/background-geolocation-ios) for iOS.

## Features

- Real-time GPS tracking
- Motion detection (stationary/moving states)
- Activity recognition
- Geofencing
- Background location updates
- Location history with SQLite persistence
- Configurable tracking parameters
- Debug logging

## Requirements

- iOS 14.0+
- Xcode 14+
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/transistorsoft/background-geolocation-swift-demo.git
cd background-geolocation-swift-demo
```

2. Open the project in Xcode:
```bash
pod install
open BGGeoSwift.xcworkspace
```

3. Install the Background Geolocation SDK (if not already included)

4. Build and run the project on your device

## Usage

1. **Enable Tracking**: Toggle the tracking switch to start location updates
2. **Motion State**: Use the play/pause button to simulate moving/stationary states
3. **Get Current Position**: Fetch a single location update
4. **Menu Actions**: Access additional features like resetting odometer, viewing state, and managing logs

## Configuration

The app is configured in `ContentView.swift` in the `configureBGGeoIfNeeded()` method:

- `desiredAccuracy`: Location accuracy setting
- `distanceFilter`: Minimum distance for location updates
- `stopOnTerminate`: Continue tracking after app termination
- `startOnBoot`: Auto-start tracking on device boot

## Author

Transistor Software

## License

MIT
