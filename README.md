# Communally iOS App

Communally is an iOS app that connects people locally — those offering help (jobs or volunteering) with those seeking opportunities. It uses Google authentication, personalized onboarding flows for job seekers (13+) and job hirers (18+), and a simple dashboard showing real, nearby opportunities using location data.

## Features

- **Google Sign-In Authentication**: Fast, secure login with Google
- **Dual User Types**: Job Seekers (13+) and Job Hirers (18+)
- **Personalized Onboarding**: Age-appropriate flows with parental approval for teens
- **Location-Based Opportunities**: Find nearby jobs and volunteer work
- **Interactive Map**: Visual representation of opportunities
- **Messaging System**: Communicate with matched users
- **Beautiful UI**: Light lime green and white theme with gradient backgrounds

## Setup Instructions

### Prerequisites

1. **Xcode 15.0+** with iOS 17.0+ deployment target
2. **Google Sign-In Setup**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Google Sign-In API
   - Create OAuth 2.0 credentials for iOS
   - Download the `GoogleService-Info.plist` file
   - Add the file to your Xcode project

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Communally
   ```

2. **Add GoogleService-Info.plist**:
   - Place the `GoogleService-Info.plist` file in the `Communally` folder
   - Make sure it's added to the Xcode project target

3. **Configure URL Schemes**:
   - In Xcode, go to your project settings
   - Select your target → Info → URL Types
   - Add a new URL Type with the REVERSED_CLIENT_ID from your GoogleService-Info.plist

4. **Add Required Capabilities**:
   - In Xcode, go to your project settings
   - Select your target → Signing & Capabilities
   - Add "Location" capability

5. **Build and Run**:
   - Open `Communally.xcodeproj` in Xcode
   - Select your target device or simulator
   - Press Cmd+R to build and run

## Project Structure

```
Communally/
├── Models/
│   └── User.swift                 # User and data models
├── Services/
│   ├── AuthenticationManager.swift # Google Sign-In handling
│   └── LocationManager.swift      # Location services
├── Views/
│   ├── AuthenticationView.swift   # Sign-in screen
│   ├── OnboardingView.swift        # User onboarding flow
│   ├── DashboardView.swift        # Main app dashboard
│   └── MessagingView.swift        # Chat functionality
├── Theme/
│   └── Theme.swift                # App styling and colors
├── CommunallyApp.swift           # Main app entry point
└── ContentView.swift             # Root view controller
```

## User Flows

### Job Seekers (13+)
1. **Google Sign-In** → Authentication
2. **Profile Creation** → Name, age, profile picture
3. **Parental Approval** → Required for users under 18
4. **Skills Selection** → Choose relevant skills
5. **Description** → Age-appropriate options
6. **Dashboard** → Browse opportunities

### Job Hirers (18+)
1. **Google Sign-In** → Authentication
2. **Profile Creation** → Name, age, profile picture
3. **Skills Selection** → Choose relevant skills
4. **Description** → Professional options
5. **Location Setup** → Optional location sharing
6. **Dashboard** → Post and manage opportunities

## Key Components

### AuthenticationManager
- Handles Google Sign-In integration
- Manages user session state
- Provides user profile data

### LocationManager
- Requests location permissions
- Provides current location data
- Searches for nearby opportunities

### Theme System
- Consistent light lime green and white design
- Gradient backgrounds
- Rounded corners and shadows
- Typography hierarchy

## Dependencies

- **GoogleSignIn**: For authentication
- **SwiftUI**: For UI framework
- **MapKit**: For map functionality
- **CoreLocation**: For location services

## Future Enhancements

- Backend API integration
- Push notifications
- Real-time messaging
- Payment processing
- Advanced filtering
- User reviews and ratings
- Social features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
