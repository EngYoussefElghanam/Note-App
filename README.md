# Notes Taker App 📒

A modern **note-taking application** built with Flutter.  
Secure your notes, organize your studies, and boost productivity with advanced features like **biometric lock, AI summarization, and text-to-speech.**  

---

## ✨ Features

- 🔐 **Secure Notes**  
  Protect sensitive information with **biometric authentication** (fingerprint/FaceID) or custom password lock.  

- 🗂 **Organized Categories**  
  - **Study Notes** → with fields for **title, topic, subject, tags, and content**  
  - **General Notes** → for quick and simple note-taking  

- 🎙 **Text-to-Speech (TTS)**  
  Listen to your study notes while multitasking or revising.  

- 🤖 **AI Summarization**  
  Instantly summarize long notes into concise study points.  

- ☁️ **Cloud Sync + Offline Mode**  
  - Sync across devices with **Firebase**  
  - Full offline support – your notes are always available  

- 👤 **User Accounts**  
  Sign up/login to keep notes private and device-independent.  

- 🎨 **Modern UI**  
  Clean, intuitive design with smooth animations and dark/light themes.  

---

## 📸 Screenshots  

*(Add your app screenshots here in a `/screenshots` folder)*  

![Home Screen](screenshots/home.png)  
![Study Notes](screenshots/study_notes.png)  
![Secure Note](screenshots/secure_note.png)  

---

## ⚙️ Tech Stack

- **Flutter** (Dart)  
- **Firebase Authentication & Firestore**  
- **Bloc State Management**  
- **Animate_do + Custom UI Components**

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.x)  
- Firebase project setup ([guide](https://firebase.google.com/docs/flutter/setup))  
- Android Studio / VSCode  

### Installation
# Clone the repository
git clone https://github.com/yourusername/notes-taker.git

# Install dependencies
flutter pub get

# Run the app
flutter run
📦 Project Structure
pgsql
Copy code
lib/
  core/        → utilities, theme, router
  features/
    notes/     → study & general notes
    auth/      → login, signup, user logic
    secure/    → biometric & password lock
  models/      → Note model
  main.dart
## 🛡️ Future Enhancements
🔄 Export/Import notes (PDF, Markdown)

🖼 Image upload & attachments

📊 Analytics dashboard for study tracking

💎 Premium plan (cloud space, AI features)

## 📜 License
This project is available for personal and commercial use.
For resale (CodeCanyon, etc.), please check licensing terms.
