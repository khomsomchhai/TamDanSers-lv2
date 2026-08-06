# tamdansers_lv2

# Level 2: State Management, API Integration & Dynamic Application

In **Level 2**, the application evolved from a **static prototype** into a **dynamic, production-oriented application** by integrating a real backend and implementing a scalable architecture. The project uses **GetX** for state management, dependency injection, and navigation, providing a clean and maintainable codebase. **Dio** is used to communicate with RESTful APIs, replacing local sample data with real-time data from the server.

## Mobile Application

The mobile application implements a complete **authentication and authorization** system supporting **Student** and **Parent** roles. After successful login, users are redirected to their respective dashboards through **role-based navigation** and can access real-time information, including:

* User Profile
* Class Schedule
* Attendance
* Homework
* Academic Results
* Permission Requests
* School Announcements
* Notifications
* Leave Requests

All data is retrieved dynamically from the backend through secure REST APIs.

## Web Application

The web application is designed for **Administrators** and **Teachers** to manage school operations efficiently.

### Administrator

* User Management
* School Information Management
* Class Management
* System Data Management

### Teacher

* Class Management
* Student Attendance
* Homework Management
* Score Management
* Student Information Management

## Technical Highlights

* GetX State Management
* Dependency Injection
* Named Route Navigation
* Dio for REST API Integration
* Authentication & Authorization
* JWT Token Management
* Role-Based Access Control (RBAC)
* Pull-to-Refresh
* Loading, Success & Error State Handling
* Global API Error Handling
* Custom Snackbar Notifications
* Telegram OTP Verification for Forgot Password
* Responsive UI
* Reusable Components & Clean Architecture

## Technologies Used

* Flutter
* Dart
* GetX
* Dio
* RESTful API
* JWT Authentication
* Telegram Bot API (OTP Verification)
* Git & GitHub

Level 2 focuses on building a real-world application by integrating backend services, implementing secure authentication, managing application state efficiently, and following clean architecture principles to create a scalable and maintainable school management system.

