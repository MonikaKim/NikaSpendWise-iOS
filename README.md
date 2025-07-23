# NikaSpendWise 💸

An iOS expense tracker app built to help users manage their personal finances. This app features a clean, modern UI built entirely programmatically with Swift and UIKit, and it is powered by a real-time Firebase backend.

## ✨ Features

- **Secure Authentication:** Full email & password sign-up and login flow using Firebase Authentication.
- **Real-Time Database:** Expenses are saved and synced instantly with Cloud Firestore.
- **Dynamic Totals:** A real-time dashboard that calculates and displays the overall total expense.
- **Grouped Lists:** Expenses are automatically grouped by day with custom headers and footers showing daily totals.
- **Swipe to Delete:** Easily delete expenses with an intuitive swipe gesture.
- **Modern UI:** A custom, glass-like UI with a gradient background, built 100% programmatically.

## 📸 Screenshots

| Login Screen | Main List | Add Expense | Sign-Up Screen |
| :----------: | :----------: | :-----------: |:-----------: |
| <img src="https://github.com/MonikaKim/NikaSpendWise-iOS/blob/main/LogInScreen.jpg?raw=true" width="250"> | <img src="https://github.com/MonikaKim/NikaSpendWise-iOS/blob/main/ListPage.jpg?raw=true" width="250"> | <img src="https://github.com/MonikaKim/NikaSpendWise-iOS/blob/main/AddExpenses.jpg?raw=true" width="250"> | <img src="https://github.com/MonikaKim/NikaSpendWise-iOS/blob/main/SignIn.jpg?raw=true" width="250"> |

## 🛠️ Tech Stack

- **Language:** Swift
- **UI Framework:** UIKit (Programmatic UI, Auto Layout)
- **Backend:** Google Firebase
  - Cloud Firestore
  - Firebase Authentication

## 🚀 Setup

To run this project locally:

1.  Clone the repository.
2.  Create a new project in your [Firebase Console](https://console.firebase.google.com/).
3.  Add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file.
4.  Place the `GoogleService-Info.plist` file into the `NikaSpendWise/` folder in Xcode.
5.  Open the project in Xcode and run.
