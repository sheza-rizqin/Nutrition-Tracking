# NutriTrack - Maternal and Child Nutrition Monitoring App

A mobile application for maternal and child nutrition monitoring and tracking in rural and low-income communities.

## Features

### Maternal Health Module
- Trimester-based nutrition guidance
- Track LMP/EDD, hemoglobin, folic acid intake
- Dietary diversity and food security assessment
- Real-time nutritional recommendations
- Audio guidance support (text-to-speech)

### Child Health Module
- Growth monitoring (Weight, Height/Length, MUAC)
- WHO growth chart visualization
- Risk level assessment (Color-coded alerts)
- Age-appropriate feeding recommendations
- Immunization and milestone tracking
- Growth history visualization

### Key Capabilities
- Local SQLite database
- Multilingual support ready
- WHO growth standards integration
- Risk-based alerting system

## Installation

### Prerequisites
- Flutter SDK 3.0+
- Android Studio or VS Code
- Android SDK (for mobile deployment)
- Chrome (for web testing)

### Setup

1. **Clone/Navigate to project directory:**
```bash
cd nutritrack_mobile_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the app:**

For Android emulator/device:
```bash
flutter run
```

For Chrome (web):
```bash
flutter run -d chrome
```

For Windows desktop:
```bash
flutter run -d windows
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── database/
│   └── database_helper.dart     # SQLite database management
├── screens/
│   ├── home_screen.dart         # Main landing page
│   ├── maternal/
│   │   ├── maternal_list_screen.dart
│   │   ├── maternal_form_screen.dart
│   │   └── maternal_detail_screen.dart
│   └── child/
│       ├── child_list_screen.dart
│       ├── child_form_screen.dart
│       └── child_detail_screen.dart
└── utils/
    ├── nutrition_guidance.dart  # Nutrition recommendations
    └── who_standards.dart       # WHO growth standards & z-scores
```

## Usage

### Adding a Maternal Record
1. Open app → Maternal Health
2. Tap "Add Record" button
3. Fill in personal information, pregnancy details, and nutrition status
4. View trimester-specific guidance on detail screen

### Adding a Child Record
1. Open app → Child Health
2. Tap "Add Child" button
3. Enter child details, measurements, and health information
4. App automatically calculates risk level based on WHO standards
5. View growth charts and age-appropriate nutrition guidance

## Technology Stack

- **Framework:** Flutter/Dart
- **Database:** SQLite (sqflite package)
- **Date handling:** intl package
- **TTS (Text-to-Speech):** flutter_tts package
- **Local storage:** shared_preferences

## WHO Standards Integration

The app uses WHO Child Growth Standards for:
- Weight-for-Length/Height Z-scores
- MUAC-based malnutrition screening
- Risk categorization:
  - 🟢 Normal: Z-score > -1
  - 🟡 Moderate: -2 < Z-score ≤ -1
  - 🟠 High Risk (MAM): -3 < Z-score ≤ -2
  - 🔴 Severe (SAM): Z-score ≤ -3

## Future Enhancements

- [ ] Multilingual support 
- [ ] Audio guidance with local language TTS
- [ ] ML-based malnutrition prediction model
- [ ] Export data for research/ML training
- [ ] Integration with Anganwadi systems

## Development Team

**Sahyadri College of Engineering & Management**
- Mithali N M (4SF23CS107)
- Sheza Rizqin (4SF23CS203)
- Rachel Maria Noronha (4SF23CS162)
- Saanvi Rai (4SF23CS175)

**Guide:** Dr. Shreema Shetty

## License

This project is developed as a mini project for VTU curriculum (2025-26).

## Acknowledgments

- WHO Child Growth Standards
- VTU and Sahyadri College of Engineering & Management
- Dr. Shreema Shetty (Project Guide)
- Dr. Mustafa Basthikodi (HOD, CSE Dept)
