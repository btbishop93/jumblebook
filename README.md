# Jumblebook

A Flutter note-taking app with encryption capabilities.

## Features

- User authentication (Email/Password, Google Sign-In, Apple Sign-In)
- Note creation and management
- Note encryption with password protection
- Biometric authentication support
- Cloud sync with Firebase

## Architecture

This project follows Clean Architecture principles to create a scalable, maintainable, and testable codebase. The app is organized into feature-based modules, each containing three main layers:

### Domain Layer
The core business logic and rules of the application:
- Pure Dart code with no external dependencies
- Defines entities and use cases
- Contains repository interfaces
- Handles business rule validation

### Data Layer
Implements the interfaces defined in the domain layer:
- Handles external data sources (Firebase, local storage)
- Manages data caching and offline support
- Implements repository interfaces
- Handles data mapping between layers

### Presentation Layer
The UI implementation and state management:
- Implements UI using Flutter widgets
- Uses BLoC pattern for state management
- Handles user interaction
- Manages UI state and navigation

## Technical Highlights

### State Management
- BLoC (Business Logic Component) pattern
- Reactive programming with Streams
- Clear separation of UI and business logic
- Predictable state changes

### Error Handling
- Custom error types for each layer
- Proper error propagation
- User-friendly error messages
- Comprehensive error logging

### Testing
- Unit tests for business logic
- Integration tests for repositories
- Widget tests for UI components
- BLoC tests for state management

### Security
- Secure note encryption
- Biometric authentication
- Secure key storage
- Firebase security rules

### Code Quality
- Strict static analysis
- Comprehensive documentation
- Consistent code style
- Regular dependency updates

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Xcode (for iOS development)
- CocoaPods (for iOS dependencies)
- Firebase project setup

## Getting Started

### 1. Environment Setup

1. Install Flutter:
   ```bash
   brew install flutter
   ```

2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```

3. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/jumblebook.git
   cd jumblebook
   ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

### 2. iOS Setup

1. Navigate to iOS directory and install pods:
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. Open Xcode workspace:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. In Xcode:
   - Select the "Runner" project in the navigator
   - Select the "Runner" target
   - Go to "Build Settings" tab
   - Set iOS Deployment Target to iOS 12.0
   - In "Signing & Capabilities" tab, select your development team

### 3. VS Code Setup

1. Install VS Code extensions:
   - Flutter
   - Dart

2. The project includes launch configurations for:
   - Debug mode
   - Profile mode
   - Release mode

## Running the App

### Using VS Code

1. Open the Command Palette (Cmd + Shift + P)
2. Select "Flutter: Select Device"
3. Choose your target device/simulator
4. Press F5 or select Run > Start Debugging

### Using Terminal

1. List available devices:
   ```bash
   flutter devices
   ```

2. Run the app:
   ```bash
   flutter run -d "device_name"
   ```

## Troubleshooting

### Common iOS Issues

1. Pod installation fails:
   ```bash
   cd ios
   pod repo update
   pod install --repo-update
   ```

2. If you get "no valid code signing certificates" error:
   - Open Xcode
   - Go to Preferences > Accounts
   - Add your Apple ID
   - Select your team
   - Let Xcode manage signing

3. For "RunnerTests" target issues:
   ```bash
   rm -rf ios/Pods ios/Podfile.lock
   flutter clean
   cd ios
   pod install
   cd ..
   ```

4. For build configuration issues:
   ```bash
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

### Firebase Setup Issues

1. Make sure you have:
   - Added `GoogleService-Info.plist` to iOS/Runner
   - Configured Firebase in `lib/main.dart`
   - Added necessary Firebase dependencies in `pubspec.yaml`

## Building for Release

### iOS

1. Create archive:
   ```bash
   flutter build ios
   ```

2. Open Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. In Xcode:
   - Select Product > Archive
   - Follow the distribution steps

## Development

### VS Code Debugging

The project includes three launch configurations:
- `Jumblebook (debug mode)`: For development with hot reload
- `Jumblebook (profile mode)`: For performance profiling
- `Jumblebook (release mode)`: For testing release builds

### Code Style

This project follows the official Dart style guide. Run:
```bash
flutter analyze
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
