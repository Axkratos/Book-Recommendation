# 🌐 Flutter Web Project

A Flutter web application project. This guide will help you set it up, create a `.env` file, and run it on a custom port `64922`.

---

## 🧰 Prerequisites

* ✅ Flutter SDK (>=3.x.x)
* ✅ Dart SDK
* ✅ Chrome browser (for web debugging)
* ✅ Git (to clone the repo)

---

## 📅 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/your-project-name.git
cd your-project-name
```

### 2. Install Dependencies

```bash
flutter pub get
```

---

## 🔐 Setting up Environment Variables

### 3. Create a `.env` file in the root directory

```bash
touch .env
```

Then add your variables like this:

```env
baseUrl=https://your-api-url.com
chatUrl=your_auth_token
```

### 4. Configure your Flutter app to use `.env`

#### a. Add `flutter_dotenv` to `pubspec.yaml`

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Run:

```bash
flutter pub get
```

#### b. Load `.env` in your `main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
```

#### c. Access variables like:

```dart
final apiUrl = dotenv.env['API_URL'];
```

---

## 🚀 Running on Custom Port 64922

### 5. Run the app on Chrome at port `64922`

```bash
flutter run -d chrome --web-port=64922
```

To list all devices:

```bash
flutter devices
```

To run with specific device:

```bash
flutter run -d <device_id> --web-port=64922
```

---

## 🥪 Troubleshooting

* Ensure `.env` is at root and not named `.env.txt`.
* Restart the server after modifying `.env`.
* If port `64922` is busy, use another free port.

---

## 🤝 Contributing

Feel free to fork, submit issues, or create pull requests.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
