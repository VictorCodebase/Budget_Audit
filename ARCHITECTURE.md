
# Contents:

1. project Structure
2. Architecture


# Project Structure
lib/
├── main.dart                          # App entry point
├── core/
│   ├── data/
│   │   ├── database.dart              # Drift database definition
│   │   └── database.g.dart            # Generated database code
│   ├── models/                        # Data models (Participant, Account, etc.)
│   ├── services/                      # Business logic services
│   │   ├── service_locator.dart       # Dependency injection
│   │   ├── participant_service.dart
│   │   ├── budget_service.dart
│   │   ├── transaction_service.dart
│   │   ├── template_service.dart
│   │   ├── sync_service.dart
│   │   ├── analytics_service.dart
│   │   ├── remote_service.dart
│   │   ├── google_sheets_service.dart
│   │   └── parsers/                   # PDF parsing system
│   │       ├── pdf_parser_interface.dart
│   │       ├── parser_factory.dart
│   │       ├── hsbc_parser.dart
│   │       ├── mpesa_parser.dart
│   │       ├── equity_parser.dart
│   │       ├── coop_parser.dart
│   │       ├── generic_parser.dart
│   │       └── budget_spreadsheet_mapper.dart
│   └── routing/
│       └── app_router.dart            # Navigation setup
└── features/                          # Feature-based organization
├── onboarding/
│   └── onboarding_view.dart
│   └── onboarding_viewmodel.dart
├── home/
│   └── home_view.dart
│   └── home_viewmodel.dart
├── budgeting/
│   └── budgeting_page.dart
│   └── budgeting_viewmodel.dart
└── audit/
├── views/
│   └── audit_page.dart
└── viewmodels/
└── audit_viewmodel.dart


# Architecture

## Overview
![Architecture overview.jpg](Assets/images/Architecture%20overview.jpg)

## Details

### MVVM (Model-View-ViewModel)
- **Models**: Data structures (in `core/models/`)
- **Views**: UI components (in `features/*/views/`)
- **ViewModels**: Business logic and state management (in `features/*/viewmodels/`)

### State Management
- **Provider**: For dependency injection and state management
- **ChangeNotifier**: ViewModels extend this for reactive updates

### Data Layer
- **Drift**: Type-safe SQLite database with code generation
- **Repository Pattern**: Services abstract data access

### Navigation
- **go_router**: Declarative routing with deep linking support
- Desktop-first with navigation rail
- Mobile-friendly with drawer navigation

##  Development Workflow

### Adding New Features

1. **Create feature folder structure**
```
features/
└── new_feature/
    ├── views/
    │   └── new_feature_page.dart
    ├── viewmodels/
    │   └── new_feature_viewmodel.dart
    └── widgets/
        └── custom_widget.dart
```

2. **Create ViewModel** (extends ChangeNotifier)
```dart
class NewFeatureViewModel extends ChangeNotifier {
  // State
  bool _isLoading = false;
  
  // Getters
  bool get isLoading => _isLoading;
  
  // Methods
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    // Business logic here
    
    _isLoading = false;
    notifyListeners();
  }
}
```

3. **Create View**
```dart
class NewFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewFeatureViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          // UI here
        );
      },
    );
  }
}
```

4. **Add route** in `app_router.dart`

### Database Changes

1. **Modify tables** in `lib/core/data/database.dart`
2. **Update schema version**
3. **Add migration logic** in `onUpgrade`
4. **Regenerate code**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Adding New Parser

1. Create new parser class implementing `BankStatementParser`
2. Add to `ParserFactory.getParser()`
3. Implement bank-specific parsing logic

##  TODO Items (Implementation Needed)

### Core Functionality
- [ ] Complete database CRUD operations in services
- [ ] Implement bank statement parsers (HSBC, M-Pesa, Equity, Co-op)
- [ ] Implement Google Sheets template creation and parsing
- [ ] Build sync logic (local ↔ remote)
- [ ] Implement vendor preference memorization
- [ ] Add transaction edit history tracking

### Google Sheets Integration
- [ ] Define standard template structure
- [ ] Implement formula generation for templates
- [ ] Parse existing templates
- [ ] Handle sheet creation for date ranges
- [ ] Implement conflict resolution (remote priority)

### PDF Processing
- [ ] Implement layout-aware text extraction
- [ ] Add date format detection
- [ ] Build vendor name extraction heuristics
- [ ] Handle currency format variations (KES, USD, etc.)

### VictorCodebase Remote
- [ ] Set up remote API endpoints
- [ ] Implement device fingerprinting
- [ ] Add license verification
- [ ] Implement anonymous analytics

### UI/UX Enhancements
- [ ] Add actual chart visualizations (using a chart library)
- [ ] Implement drag-and-drop for file uploads
- [ ] Add account/category color pickers
- [ ] Build transaction labeling interface
- [ ] Add participant selection for uploads

### Data Visualization
- [ ] Integrate charting library (e.g., fl_chart)
- [ ] Implement interactive charts
- [ ] Add chart snapshot functionality
- [ ] Build export to image/PDF

##  Security Notes

- **Never commit**:
    - Google service JSON files
    - Syncfusion license keys
    - API keys or secrets
    - Database files

- Add to `.gitignore`:
```
*.keystore
google-services.json
ios/Runner/GoogleService-Info.plist
.env
*.db
*.db-shm
*.db-wal
```

##  Known Limitations (Starter Code)

- Services return mock data
- Parser implementations are stubs
- Google Sheets operations are incomplete
- No actual chart rendering
- License verification always returns true
- No error handling for network failures

##  Key Dependencies

- **provider**: State management
- **go_router**: Navigation
- **drift**: Database ORM
- **syncfusion_flutter_pdf**: PDF text extraction
- **googleapis**: Google Sheets API
- **google_sign_in**: Google authentication
- **file_picker**: File selection

##  Platform Support

Primary: **Windows** (Desktop-first design)  
Secondary: **Android**, **macOS**, **iOS**  
Web: Not recommended (file system limitations)

##  Support

For issues with:
- **Syncfusion**: https://support.syncfusion.com/
- **Google APIs**: https://support.google.com/cloud
- **Flutter**: https://docs.flutter.dev/

