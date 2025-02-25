# Jumblebook Deployment Guide

This document provides instructions for setting up and managing the deployment of Jumblebook to both iOS (TestFlight) and Android (Google Play) platforms using GitHub Actions.

## Prerequisites

- Apple Developer Program membership
- Google Play Developer account
- GitHub repository with appropriate permissions

## GitHub Secrets Setup

The following secrets need to be set up in your GitHub repository:

### iOS Secrets

1. `IOS_DISTRIBUTION_CERTIFICATE_BASE64`: Base64-encoded iOS distribution certificate (.p12 file)
2. `IOS_CERTIFICATE_PASSWORD`: Password for the distribution certificate
3. `IOS_PROFILE_BASE64`: Base64-encoded provisioning profile (.mobileprovision file)
4. `APPLE_API_KEY_ID`: App Store Connect API Key ID
5. `APPLE_API_KEY_ISSUER_ID`: App Store Connect API Issuer ID
6. `APPLE_API_PRIVATE_KEY`: Contents of the App Store Connect API private key (.p8 file)
7. `APPLE_TEAM_ID`: Your Apple Developer Team ID

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

## Deployment Process

### Manual Deployment

1. Go to the "Actions" tab in your GitHub repository
2. Select either "iOS TestFlight Deployment" or "Android Play Store Deployment"
3. Click "Run workflow"
4. Select the branch and version bump type (patch/minor/major)
5. Click "Run workflow" to start the deployment

### Automatic Deployment

The workflows are configured to run automatically when changes are pushed to the main branch that affect:

- iOS: Changes to `lib/`, `ios/`, `pubspec.yaml`, or `pubspec.lock`
- Android: Changes to `lib/`, `android/`, `pubspec.yaml`, or `pubspec.lock`

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

- **Code Signing Errors**: Verify certificate and profile matches
- **Build Errors**: Check Xcode version compatibility
- **Upload Errors**: Verify App Store Connect API credentials

### Android Issues

- **Keystore Errors**: Verify keystore path and credentials
- **Build Errors**: Check Gradle and JDK compatibility
- **Upload Errors**: Verify Google Play service account permissions 