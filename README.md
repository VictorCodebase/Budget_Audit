# budget_audit

## Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Git

## Installation

### Clone the repository
```bash
git clone https://github.com/VictorCodebase/Budget_Audit
cd budget_audit
```
### install dependencies
```bash
flutter pub get
```

### Generate Drift database files
(dev)
```bash
dart run build_runner watch
```
or
```bash
dart run build_runner build
```

## SyncFusion License Key
>! You shall require a SyncFusion Lisence key
_Visit: https://www.syncfusion.com/account/claim-license-key_

add a .env file in root, add a variable`SYNCFUSION_LICENSE`
```env
SYNCFUSION_LICENSE = "***"
```

## Google Sign-In 
### for Android
Go to [Google Cloud Console](https://console.cloud.google.com/)  
Create a new project or select existing  
Enable "Google Sheets API" and "Google Sign-In API"  
Create OAuth 2.0 credentials (Android type)  
Add SHA-1 fingerprint (get with: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)
Download `google-services.json` and place in `android/app/`

### For Windows
Create OAuth 2.0 credentials (Desktop type) - Let the browser handle the rest  

### For iOS/macOS
Create OAuth 2.0 credentials (iOS type)  
Add Bundle ID  
Update `ios/Runner/Info.plist` with URL scheme  

## Run Budget Audit
```Bash
# For Windows
flutter run -d windows

# For Android
flutter run

# For web (development only)
flutter run -d chrome
```

# Contributing
1. Learn about project structure: [ARCHITECTURE.md](ARCHITECTURE.md)
2. Database Schema: [SCHEMA.md]()

