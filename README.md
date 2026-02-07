# <h1 align="center">🚀 Notepad - Notes Application</h1>

<p align="center">
  <!-- GitHub followers -->
  <a href="https://github.com/hugoegry"><img src="https://img.shields.io/github/followers/hugoegry?style=social" alt="GitHub followers"></a>
  &nbsp;
  <!--mail-->
  <a href="mailto:hugo.egry@epitech.eu"><img src="https://img.shields.io/badge/Email-hugo.egry@epitech.eu-blue?style=social&logo=gmail"></a>
  &nbsp;
  <!-- Repo stars -->
  <a href="https://github.com/hugoegry?tab=stars"><img src="https://img.shields.io/github/stars/hugoegry?style=social" alt="GitHub stars"></a>
</p>
<br>

<h2 align="center">A <strong>modern note-taking application</strong> with <strong>Flutter, Dart & SQLite</strong>, folder organization and password protection.</h2>

<h3 align="center">⭐ Star this repo and follow me on GitHub to stay updated with exciting projects and future releases!</h3>
<br>

<div align="center">

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white"/>
</p>

[Demo](#-presentation) • [Installation](#-installation) • [Documentation](#-architecture) • [Contributing](#-contributors)

</div>
<br>

---

## ✨ About The Project

<div align="center">

| 🎓 **Personal Project** | 📚 **Flutter Development** | 📅 **2025-2026** |

</div>

### 🎯 Project Context

This project is a personal note management application developed with Flutter. The goal was to create an **intuitive note-taking application** using Flutter for the frontend and SQLite for local storage.

We chose to build a **organized notes application** because:

- 📝 **Practical & Intuitive** - Simple interface to manage notes and folders
- 🏗️ **Technically Enriching** - Implementation of local database, password hashing, and Flutter architecture
- 🔒 **Secure** - Protection of sensitive notes with passwords
- 📱 **Multiplatform** - Works on Android, iOS, Web, Desktop

---

## 📺 Presentation

### SOON
<!--<div align="center">

![Demo GIF](https://via.placeholder.com/800x450/02569B/FFFFFF?text=Demo+Video+Coming+Soon)

*Replace this placeholder with your actual demo video or GIF*

```markdown
[![Demo Video](https://img.youtube.com/vi/YOUR_VIDEO_ID/maxresdefault.jpg)](https://www.youtube.com/watch?v=YOUR_VIDEO_ID)

![Demo](./assets/demo.gif)
```

</div> -->

## 🛠️ Tech Stack

<div align="center">

| Category | Technologies |
|----------|-------------|
| **Frontend** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white) |
| **Database** | ![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white) ![sqflite](https://img.shields.io/badge/sqflite-003B57?style=flat-square&logo=sqlite&logoColor=white) |
| **Security** | ![Crypto](https://img.shields.io/badge/Crypto-SHA256-blue?style=flat-square) |
| **Tools** | ![Path Provider](https://img.shields.io/badge/Path_Provider-0175C2?style=flat-square) ![sqflite_common_ffi](https://img.shields.io/badge/sqflite_common_ffi-003B57?style=flat-square) |

</div>

---

## 📦 Installation

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (v3.0.0 or higher) - [Download](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- A code editor (recommended: VS Code with Flutter extension)
- An emulator or physical device for testing

### 1. Clone the Repository

```bash
git clone <repository-url>
cd hello_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Application

#### Development Mode (Recommended)

```bash
flutter run
```

#### Production Mode

```bash
# Build for Android
flutter build apk

# Build for iOS (requires Mac)
flutter build ios

# Build for Web
flutter build web

# Build for Desktop
flutter build windows  # or linux or macos
```

### 4. Access the Application

- **Mobile App**: Install the APK on Android or IPA on iOS
- **Web**: Open `build/web/index.html` in a browser
- **Desktop**: Run the generated executable

---

## 🏗️ Architecture

The application follows a classic Flutter architecture with separation of concerns.

### Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/
│   ├── note.dart            # Data model for notes
│   └── folder.dart          # Data model for folders
├── screens/
│   ├── home_screen.dart     # Main screen
│   ├── folder_screen.dart   # Folder management
│   ├── note_editor_screen.dart # Note editor
│   └── about_screen.dart    # About screen
├── services/
│   ├── database_service.dart # Database service
│   └── theme/
│       └── app_theme.dart   # Theme configuration
├── widgets/
│   └── ...                  # Reusable components
└── utils/
    └── ...                  # Utilities
```

### Database Service

The `DatabaseService` handles all SQLite operations:

- **Initialization**: Creation of notes and folders tables
- **CRUD Operations**: Create, Read, Update, Delete for notes and folders
- **Security**: SHA-256 password hashing
- **Multiplatform**: Windows/Linux/Mac support with sqflite_ffi

### Data Models

#### Note
```dart
class Note {
  int? id;
  String title;
  String content;
  int? folderId;
  String? password;
  DateTime createdAt;
  DateTime updatedAt;
}
```

#### Folder
```dart
class NoteFolder {
  int? id;
  String name;
  String? password;
  DateTime createdAt;
  DateTime updatedAt;
}
```

---

## 🎨 User Interface

The interface is designed with Material Design and supports dark/light themes.

### Main Screens

| Screen | Description |
|--------|-------------|
| `HomeScreen` | List of folders and root notes |
| `FolderScreen` | Content of a specific folder |
| `NoteEditorScreen` | Note editing/creation |
| `AboutScreen` | Application information |

### UI Features

- **Smooth navigation** between screens
- **Adaptive theme** dark/light
- **Confirmation dialogs** for deletions
- **Loading indicators** during DB operations

---

## 🧪 Testing

The application uses the Flutter testing framework.

### Run Tests

```bash
flutter test
```

### Available Tests

- Unit tests for services
- Integration tests for database
- Widget tests for interface

---

## 📝 Features

### Note Management
- ✅ Create, edit, delete notes
- ✅ Organize notes in folders
- ✅ Search and sort by update date

### Folder Management
- ✅ Create custom folders
- ✅ Password protect folders
- ✅ Move notes between folders

### Security
- ✅ Secure password hashing (SHA-256)
- ✅ Individual note and folder protection
- ✅ Local data storage

### User Interface
- ✅ Modern and intuitive design
- ✅ Dark/light theme support
- ✅ Smooth navigation between screens

---

## 🤝 Contributors

<div align="center">

| Avatar | Name | Role | GitHub |
|--------|------|------|--------|
| <img src="readmepicture/hugoegry.png" width="60" style="border-radius:50%"> | **Hugo Egry** | Developer | [@hugoegry](https://github.com/hugoegry) |

</div>

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b newFeature`)
3. Commit your changes (`git commit -m 'Add some new feature'`)
4. Push to the branch (`git push origin newFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) for the multiplatform framework
- [SQLite](https://www.sqlite.org/) for the database
- [sqflite](https://pub.dev/packages/sqflite) for the Flutter plugin
- [crypto](https://pub.dev/packages/crypto) for hashing

---

<div align="center">

**Developed with ❤️ by Hugo Egry**

⭐ Star this repo if you find it helpful!

</div>
