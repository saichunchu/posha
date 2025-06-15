# 🐾 Pet Adoption App - Flutter

A beautiful, responsive Flutter app that allows users to explore, favorite, and adopt pets with persistent local storage and smooth animations.
<!-- Optional: Add a screenshot or banner image -->

---

## ✨ Features

- 📃 **Home Page** with:
  - List of adoptable pets fetched from API
  - Pull-to-refresh
  - Search by pet name
  - Hero animations for smooth navigation

- 📄 **Details Page** showing:
  - Pet's name, age, price, image
  - Interactive zoom image viewer
  - Confetti animation on successful adoption
  - "Already Adopted" indicator & disabled adopt button

- ⭐ **Favorites Page**:
  - List of all favorited pets
  - Persistent across app launches

- 🕓 **History Page**:
  - List of all adopted pets in chronological order

- 📱 **Responsive UI** for both mobile and web

- 📦 **Local Storage** using Hive for:
  - Favorite & adoption persistence
  - Offline cache support (bonus)

- 🧪 **Tests**:
  - Unit test
  - Widget test

---

## 📷 Screenshots

| Home Page | Details Page | Confetti | Favorites |
|-----------|--------------|----------|-----------|
| ![home](![WhatsApp Image 2025-06-15 at 09 40 25_0a082b9d](https://github.com/user-attachments/assets/7f0668f8-3337-4ffd-8312-16163bb51858)
) | ![details](![WhatsApp Image 2025-06-15 at 09 40 23_64875090](https://github.com/user-attachments/assets/1fb71cd2-1943-4aec-9501-bf3dce05ba0e)
) | ![History](![WhatsApp Image 2025-06-15 at 09 40 25_7e6403e4](https://github.com/user-attachments/assets/54a39fef-b2d5-425c-8892-b40b6cd24a99)
) | ![favorites](![WhatsApp Image 2025-06-15 at 09 40 24_26c09db7](https://github.com/user-attachments/assets/f60c91d0-15c3-454e-ae54-91cf6e6d8406)
) |

---

## 🚀 Getting Started

### 📌 Prerequisites
- Flutter SDK (3.10+ recommended)
- Dart
- Hive
- API endpoint or use mock data (MockAPI)

### 📥 Clone the Repository

```bash
git clone https://github.com/your-username/pet-adoption-app.git
cd pet-adoption-app
```
```bash
flutter pub get
flutter packages pub run build_runner build
flutter run
```
```bash
To run on web
flutter run -d chrome
```

Tech Stack
- Flutter
- Dart
- BLoC for state management
- Hive for local persistence
- PhotoView for interactive image
- Confetti for celebration animation

🌐 Live Demo (Web App)
👉 https://posha.netlify.app/

📱 APK Download
👉 https://drive.google.com/file/d/1-k_N2F2EmSaxlKI9FEmkvUdrh_yRaoel/view?usp=sharing
