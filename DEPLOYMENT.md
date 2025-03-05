# Jumblebook Deployment Guide

This document provides instructions for setting up and managing the deployment of Jumblebook to both iOS (TestFlight) and Android (Google Play) platforms using GitHub Actions.

## Prerequisites

- Apple Developer Program membership
- Google Play Developer account
- GitHub repository with appropriate permissions
- Flutter SDK 3.24.0 or later

### Google Play Store Setup

Before running the Android deployment, ensure you have:
1. Created your app in the Google Play Console
2. Set up the Beta testing track:
   - Go to Google Play Console > Your App > Testing > Open testing
   - Click "Create track" if it doesn't exist
   - Configure testers and testing details
   - Save the track settings
3. Created a service account with the necessary permissions
4. Generated and downloaded the service account JSON key

## GitHub Secrets Setup

The following secrets need to be set up in your GitHub repository:

### iOS Secrets

1. `IOS_DISTRIBUTION_CERTIFICATE_BASE64`: Base64-encoded iOS distribution certificate (.p12 file)
2. `IOS_CERTIFICATE_PASSWORD`: Password for the distribution certificate
3. `IOS_PROFILE_BASE64`: Base64-encoded provisioning profile (.mobileprovision file)
4. `APPLE_API_KEY`: App Store Connect API Key ID
5. `APPLE_API_KEY_ISSUER_ID`: App Store Connect API Issuer ID
6. `APPLE_API_PRIVATE_KEY`: Contents of the App Store Connect API private key (.p8 file)
7. `APP_STORE_APP_ID`: Your App Store application ID
8. `GOOGLE_SERVICE_INFO_PLIST`: Base64-encoded GoogleService-Info.plist file for Firebase configuration

### Android Secrets

1. `ANDROID_KEYSTORE_BASE64`: Base64-encoded Android keystore (.jks file)
2. `ANDROID_KEYSTORE_PASSWORD`: Password for the keystore
3. `ANDROID_KEY_ALIAS`: Key alias in the keystore
4. `ANDROID_KEY_PASSWORD`: Password for the key
5. `PLAY_STORE_SERVICE_ACCOUNT_JSON`: Contents of the Google Play service account JSON key file

### GitHub Token

1. `PAT_TOKEN`: Personal Access Token with permissions to update repository variables

## GitHub Variables Setup

The following variables need to be set up in your GitHub repository:

1. `MARKETING_VERSION`: Current marketing version (e.g., "3.1.0")
2. `BUILD_NUMBER`: Current build number (e.g., "1")

## Local Development Setup

### iOS

1. Install the distribution certificate and provisioning profile on your local machine
2. Open the iOS project in Xcode and configure code signing

### Android

1. Create a copy of `android/key.properties.example` as `android/key.properties`
2. Update the values in `key.properties` with your keystore information
3. Place your keystore file at the location specified in `key.properties`

## CodeMagic CLI Tools

The deployment process uses CodeMagic CLI tools for both iOS and Android deployment. These tools provide the following key functionalities:

### iOS Tools
1. `keychain initialize`: Sets up a new keychain for secure certificate management
2. `xcode-project use-profiles`: Configures Xcode project settings with the provided provisioning profiles
3. `app-store-connect publish`: Handles the upload of IPA files to App Store Connect

### Android Tools
1. `android-app-bundle verify`: Verifies the Android App Bundle before upload
2. `android-app-bundle upload`: Handles the upload of AAB files to Google Play Store

The tools are automatically installed during the deployment process using pip:
```bash
pip install codemagic-cli-tools
```

## Deployment Process

### iOS Deployment

The iOS deployment can be triggered in two ways:

1. **Automatically**: When changes are pushed to the `master` branch
2. **Manually**: Through the GitHub Actions interface with version bump options

#### Manual Deployment Steps

1. Go to the "Actions" tab in your GitHub repository
2. Select "Push iOS build on TestFlight"
3. Click "Run workflow"
4. Choose the version bump type:
   - `patch`: For backwards-compatible bug fixes (e.g., 1.0.0 → 1.0.1)
   - `minor`: For new backwards-compatible functionality (e.g., 1.0.0 → 1.1.0)
   - `major`: For incompatible API changes (e.g., 1.0.0 → 2.0.0)
5. Click "Run workflow" to start the deployment

The deployment process includes:

1. Setting up Flutter SDK (version 3.24.0)
2. Installing dependencies and running lint checks
3. Setting up code signing using CodeMagic CLI tools:
   - Initializing a secure keychain
   - Installing the distribution certificate
   - Configuring provisioning profiles
4. Setting up Firebase configuration
5. Updating version numbers based on the selected bump type
6. Building and signing the IPA file
7. Uploading the build to TestFlight

The version and build numbers are managed using a `VERSION` file in the root directory:
- The version number is updated according to the selected bump type
- The build number is calculated using the formula:
```
buildNumber = (majorVersion * 1000000) + (minorVersion * 10000) + github_run_number
```

### Android Deployment

The Android deployment can be triggered in two ways:

1. **Automatically**: When changes are pushed to the `master` branch
2. **Manually**: Through the GitHub Actions interface with version bump options

#### Manual Deployment Steps

1. Go to the "Actions" tab in your GitHub repository
2. Select "Push Android build to Play Store Beta"
3. Click "Run workflow"
4. Choose the version bump type:
   - `patch`: For backwards-compatible bug fixes (e.g., 1.0.0 → 1.0.1)
   - `minor`: For new backwards-compatible functionality (e.g., 1.0.0 → 1.1.0)
   - `major`: For incompatible API changes (e.g., 1.0.0 → 2.0.0)
5. Click "Run workflow" to start the deployment

The deployment process includes:

1. Setting up Flutter SDK (version 3.24.0)
2. Installing dependencies and running lint checks
3. Setting up Android signing configuration:
   - Decoding and configuring the upload keystore
   - Creating key.properties file with credentials
   - Setting up Google Services configuration
4. Setting up Google Play Store credentials
5. Updating version numbers based on the selected bump type
6. Building the Android App Bundle (AAB)
7. Verifying and uploading the bundle to Play Store Beta track

The version and build numbers are managed using a `VERSION` file in the root directory:
- The version number is updated according to the selected bump type
- The build number is calculated using the formula:
```
buildNumber = (majorVersion * 1000000) + (minorVersion * 10000) + github_run_number
```

## Versioning

The versioning follows semantic versioning (MAJOR.MINOR.PATCH):

- `MAJOR`: Incompatible API changes
- `MINOR`: Backwards-compatible functionality
- `PATCH`: Backwards-compatible bug fixes

The build number is incremented automatically after each successful deployment.

## What's New Content

For Android deployments, update the release notes in:
`distribution/whatsnew/en-US/default.txt`

## Troubleshooting

### iOS Issues

- **Code Signing Errors**: 
  - Verify certificate and profile matches
  - Check if the keychain is properly initialized
  - Ensure all required secrets are properly set in GitHub
- **Build Errors**: 
  - Check Flutter version compatibility (should be 3.24.0)
  - Verify GoogleService-Info.plist is properly configured
  - Check export options plist configuration
- **Upload Errors**: 
  - Verify App Store Connect API credentials
  - Check if the app version doesn't already exist on TestFlight
  - Ensure the build number is unique and increasing

### Android Issues

- **Keystore Errors**: Verify keystore path and credentials
- **Build Errors**: Check Gradle and JDK compatibility
- **Upload Errors**: Verify Google Play service account permissions 