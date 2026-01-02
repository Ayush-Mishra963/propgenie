# 🚀 PropGenie

**PropGenie** is an AI-powered freelancer proposal generator that helps freelancers create high-quality, customized job proposals in seconds. Built with **Flutter** for cross-platform mobile/web support and powered by AI on the backend, PropGenie simplifies the proposal-writing process while maintaining professionalism and personalization.

---

## ✨ Key Features

* 🤖 **AI-Powered Proposal Generation** – Generate tailored freelancer proposals instantly
* 🔐 **Authentication** – Secure login using Firebase Authentication (Email / Password)
* 🧾 **Saved Proposals Library** – View, copy, or download previously generated proposals
* 🎁 **Free Trials** – Limited free proposal attempts for new users
* 💳 **Premium Upgrade** – Unlock more proposals using Razorpay payments
* 📱 **Cross-Platform** – Works on Android, Web, Windows
* 🎨 **Modern UI** – Clean, minimal design with consistent theming

---

## 🛠 Tech Stack

### Frontend

* **Flutter (Dart)** – Cross-platform UI framework

### Backend / Services

* **OpenAI API** – AI-based proposal generation
* **Firebase** – Authentication & database
* **Razorpay** – Payments & premium access

---

## 📂 Project Structure

```
propgenie/
│
├── lib/                    # Flutter application code
│   ├── main.dart
│   ├── openai_service.dart
│   ├── payment_service.dart
│   ├── proposal_screen.dart
│   ├── saved_proposals_screen.dart
│   └── ...
│
├── assets/                 # Fonts, logos, images
├── android/                # Android platform files
├── ios/                    # iOS platform files
├── web/                    # Web build files
├── windows/ macos/ linux/  # Desktop platform support
├── pubspec.yaml            # Dependencies & assets config
└── README.md
```

---

## 🔑 Environment & API Keys

> ⚠️ **Important:** API keys are **NOT hardcoded** in this repository.

To run the project locally:

1. Create your OpenAI API key from the OpenAI dashboard
2. Store it securely using one of the following methods:

   * Dart `--dart-define`
   * Environment variables
   * Secure backend proxy (recommended for production)

Example (development only):

```dart
const String openAiApiKey = "YOUR_OPENAI_API_KEY";
```

---

## ▶️ Getting Started

### Prerequisites

* Flutter SDK
* Firebase project setup
* OpenAI API key
* Razorpay account (for payments)

### Run Locally

```bash
flutter pub get
flutter run
```

---

## 📸 Screenshots

> Screenshots and demo GIFs will be added soon.

---

## 🎯 Use Cases

* Freelancers applying on platforms like Upwork, Fiverr, Freelancer
* Freshers who struggle with proposal writing
* Professionals who want faster, high-quality proposals

---

## 🚧 Future Enhancements

* Proposal tone & length customization
* Multiple proposal templates
* Analytics dashboard for usage
* Team & agency accounts

---

## 👤 Author

**Ayush Mishra**
B.Tech CSE Student | Flutter Developer | AI Enthusiast

* GitHub: [https://github.com/Ayush-Mishra963](https://github.com/Ayush-Mishra963)

---

## ⭐ Support

If you like this project, please ⭐ star the repository — it helps a lot!

---

## 📜 License

This project is currently for educational and portfolio purposes. Licensing details can be added later.
