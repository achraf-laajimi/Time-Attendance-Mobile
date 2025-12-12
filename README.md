# In&Out - Enterprise Attendance Management System

![Flutter Version](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A comprehensive Flutter-based enterprise attendance management system designed to streamline employee time tracking, leave management, and HR administration.

## 🌟 Key Features

- **Employee Management**: Complete system for managing employee profiles, departments, and user roles
- **Attendance Tracking**: Track check-ins/check-outs with automatic status detection (on time/late)
- **Vacation Management**: Request, approve, and track time off with built-in approval workflows
- **Remote Attendance**: Face recognition for remote check-in/check-out capabilities
- **Holiday Management**: Schedule and manage company-wide and public holidays
- **Dashboard & Analytics**: Visualize attendance data and key metrics for management
- **Multi-Language Support**: Fully localized in English and French
- **Theme Customization**: Light/dark mode with customizable primary and secondary colors
- **Two-Factor Authentication**: Enhanced security with email-based 2FA

## 🚀 Getting Started

### Prerequisites
- Flutter 3.4.3 or higher
- Dart SDK 3.0 or higher

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/in_out.git
    ```
2. Navigate to the project directory:
   ```bash
   cd in_out
    ```
Install dependencies:
```bash
  flutter pub get
```

Run the application:
```bash 
  flutter run
```


## 🏗️ Architecture
The project follows a modular architecture with Provider pattern for state management:

- **Models**: Data structures representing business entities
- **Providers**: State management using Provider package
- **Services**: API communication and business logic
- **Screens**: UI presentation layer
- **Widgets**: Reusable UI components
- **Theme**: Adaptive theming system with light/dark mode support
- **Localization**: Multi-language support infrastructure

##  🧰 Technologies Used

- **Flutter**: UI framework
- **Provider**: State management
- **HTTP**: API communication
- **SharedPreferences/SecureStorage**: Local data persistence
- **Flutter Localizations**: Internationalization
- **Camera**: For face recognition features
- **fl_chart**: Data visualization
- **Adaptive Theme**: Dynamic theming

##  🔮 Future Roadmap

Geolocation-based attendance verification
Advanced reporting and analytics
Integration with payroll systems

