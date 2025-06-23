# Fraud Detector – Smart Monitoring Kit

A modern, full-featured Flutter application for monitoring, detecting, and managing financial fraud.  
This app provides a dashboard, analytics, user management, and system configuration for fraud detection in financial transactions.

---

## ✨ Features

### Authentication
- **Sign In / Register**: Secure login and registration with sample data validation.

### Dashboard
- **Overview**: Visual summary of transactions, suspicious activity, and users.
- **Statistics**: Key metrics (total transactions, suspicious, total amount, users).
- **Trends**: Interactive charts for transaction trends by count and amount.
- **Recent Transactions**: Quick view of latest activity.

### Transactions
- **All Transactions**: Browse, filter, and search all transactions.
- **Suspicious Transactions**: Dedicated screen for flagged transactions, with filters and investigation tools.

### Users
- **User Management**: List, view, and manage system users.

### Systems
- **System Management**: View and manage connected systems.

### API
- **API Overview**: Information about system API endpoints.

### Profile
- **User Profile**: View and edit your profile.

### Settings
- **App Settings**: Theme switching (light/dark), notification preferences, and more.

### Theming
- **Light & Dark Mode**: Beautiful, modern UI with full theme support.

---

## 🗂️ Project Structure

```
lib/
├── main.dart                # App entry point, routing, and theme setup
├── screens/                 # All main app screens/pages
│   ├── dashboard_screen.dart
│   ├── transactions_screen.dart
│   ├── suspicious_transactions_screen.dart
│   ├── users_screen.dart
│   ├── profile_screen.dart
│   ├── systems_screen.dart
│   ├── api_screen.dart
│   ├── settings_screen.dart
│   └── splash_screen.dart
├── widgets/                 # Reusable UI components
│   ├── sidebar_navigation.dart
│   ├── main_layout.dart
│   └── common_widgets.dart
├── services/                # Business logic and helpers
│   └── sample_data_service.dart
├── database/                # Database helpers
│   └── database_helper.dart
├── models/                  # Data models
│   ├── transaction.dart
│   ├── system.dart
│   └── user.dart
├── providers/               # State management (Provider)
│   └── theme_provider.dart
└── theme/                   # App theming
    └── app_theme.dart
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio, VS Code, or any preferred IDE

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/BenMilanzi98/Fraud-Detector
   cd Fraud-Detector
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```
   - To run on a specific device, use `flutter devices` and then `flutter run -d <device_id>`

---

## 🧩 Modules Overview

### Screens

- **SplashScreen**: App loading and branding.
- **DashboardScreen**: Main analytics and overview.
- **TransactionsScreen**: All transactions, filters, and search.
- **SuspiciousTransactionsScreen**: Focused view for flagged transactions.
- **UsersScreen**: User management.
- **ProfileScreen**: User profile and settings.
- **SystemsScreen**: Manage connected systems.
- **ApiScreen**: API information and documentation.
- **SettingsScreen**: App preferences and theme.

### Widgets

- **SidebarNavigation**: Responsive sidebar for navigation.
- **MainLayout**: App shell with sidebar and content area.
- **CommonWidgets**: Buttons, cards, text fields, loading indicators, etc.

### Services

- **SampleDataService**: Generates and validates sample data for demo and testing.

### Database

- **DatabaseHelper**: Handles local SQLite database operations.

### Models

- **Transaction**: Transaction data structure.
- **System**: System data structure.
- **User**: User data structure.

### Providers

- **ThemeProvider**: Manages app theme (light/dark).

### Theme

- **AppTheme**: Centralized theme definitions.

---

## 🧪 Testing

To run widget and unit tests:
```sh
flutter test
```

---

## 📦 Sample Data

- On first run, the app auto-generates sample users, systems, and transactions for demo purposes.

---

## 💡 Customization

- **Theming**: Easily switch between light and dark mode in the app.
- **Sample Data**: Modify `services/sample_data_service.dart` to change demo data.

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

[MIT](LICENSE) (or your chosen license)

---

---

**Enjoy using Fraud Detector – Smart Monitoring Kit!**
# Fraud-Detector
