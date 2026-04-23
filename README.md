<div align="center">

<img src="https://raw.githubusercontent.com/AnirudhSharma392/orb/main/assets/animation.gif" width="220" alt="Orb Animation"/>

# ✨ Orb

**A stunning, GPU-accelerated Flutter animation package with two beautiful styles —**  
**a fluid watercolor orb and an authentic Siri-style glowing sphere.**

[![pub version](https://img.shields.io/pub/v/orb.svg?label=pub&color=6C63FF)](https://pub.dev/packages/orb)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS-lightgrey)](#)
[![flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-54C5F8.svg)](https://flutter.dev)

</div>

---

## 🎨 Showcase

<div align="center">

| Orb (Watercolor) | SiriORB (Authentic) |
|:-:|:-:|
| <img src="https://raw.githubusercontent.com/AnirudhSharma392/orb/main/assets/orb.png" width="160" alt="Fluid Orb"/> | <img src="https://raw.githubusercontent.com/AnirudhSharma392/orb/main/assets/siri.png" width="160" alt="Siri Orb"/> |
| Smooth fluid watercolor gradients | Authentic iOS Siri-style glowing sphere |

</div>

---

## 🚀 Features

- 🌊 **Two Distinct Styles** — `Orb` (watercolor fluid) & `SiriORB` (authentic iOS Siri sphere)
- 🎙️ **Amplitude Reactive** — Responds dynamically to audio levels (0.0 → 1.0)
- ⚡ **60 FPS Performance** — Fully GPU-accelerated via `CustomPainter`, zero widget rebuilds
- 🎨 **Color Themes** — Built-in `OrbPalette` presets: `siriOriginal`, `inferno`, `aurora`
- 🔄 **Seamless Looping** — Mathematically perfect infinite animation loops with zero jitter
- 🧠 **Clean API** — Centralized `OrbController` for predictable, reactive state management
- 📦 **Zero Dependencies** — Pure Dart & Flutter, no third-party libs required

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  orb: ^0.0.1
```

Then run:

```sh
flutter pub get
```

---

## 🔧 Quick Start

### 1. Import

```dart
import 'package:orb/orb.dart';
```

### 2. Create a Controller

```dart
late OrbController _controller;

@override
void initState() {
  super.initState();
  _controller = OrbController(initialAmplitude: 0.0);
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## 🌊 Orb — Fluid Watercolor Style

The classic fluid orb with smooth, flowing color gradients. Fully customizable with `OrbPalette` themes.

```dart
Orb(
  controller: _controller,
  radius: 120,
  colors: OrbPalette.siriOriginal,
  onTap: () => print('Orb tapped!'),
)
```

### Available Palettes

| Palette | Colors |
|---|---|
| `OrbPalette.siriOriginal` | Blue, Cyan, Purple — classic Siri |
| `OrbPalette.inferno` | Red, Orange, Yellow — fire effect |
| `OrbPalette.aurora` | Green, Teal, Violet — northern lights |

You can also pass your own custom color list:

```dart
Orb(
  controller: _controller,
  radius: 120,
  colors: [Colors.pink, Colors.deepPurple, Colors.indigo],
)
```

---

## 🔮 SiriORB — Authentic iOS Style

A completely separate, iOS 14+ authentic Siri orb implementation using `BlendMode.plus` additive color layering. Places glowing colored ribbons (Magenta, Blue, Cyan, Purple) inside a hard-masked glass sphere, creating the signature burning-white core.

```dart
SiriORB(
  controller: _controller,
  radius: 120,
  onTap: () => print('SiriORB tapped!'),
)
```

> ⚠️ `SiriORB` **must** be placed on a **dark background** to render correctly. The visual effect relies entirely on additive `BlendMode.plus` blending, which requires a black canvas to function.

---

## 🎙️ Audio Reactivity

Feed real-time mic amplitude to the controller to make the orb come alive:

```dart
// From any audio SDK, stream values between 0.0 and 1.0
microphonePlugin.loudnessStream.listen((volume) {
  _controller.amplitude = volume.clamp(0.0, 1.0);
});
```

Both `Orb` and `SiriORB` are fully driven by the same `OrbController` — swap them at runtime without changing your state logic.

---

## 🏗️ API Reference

### `OrbController`

| Property | Type | Description |
|---|---|---|
| `amplitude` | `double` | Audio/reactivity level. `0.0` = idle, `1.0` = max |
| `initialAmplitude` | `double` | Starting amplitude on init |
| `dispose()` | `void` | Clean up resources |

### `Orb`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `OrbController` | required | Drives animation state |
| `radius` | `double` | `80.0` | Radius of the orb in logical pixels |
| `colors` | `List<Color>` | `OrbPalette.siriOriginal` | Color theme |
| `onTap` | `VoidCallback?` | `null` | Tap callback |

### `SiriORB`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `OrbController` | required | Drives animation state |
| `radius` | `double` | `80.0` | Radius of the sphere |
| `onTap` | `VoidCallback?` | `null` | Tap callback |

---

## 💡 Full Example

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:orb/orb.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OrbController _controller;
  bool _useSiri = false;

  @override
  void initState() {
    super.initState();
    _controller = OrbController(initialAmplitude: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Toggle between styles
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _useSiri
                  ? SiriORB(
                      key: const ValueKey('siri'),
                      controller: _controller,
                      radius: 140,
                    )
                  : Orb(
                      key: const ValueKey('orb'),
                      controller: _controller,
                      radius: 140,
                      colors: OrbPalette.siriOriginal,
                    ),
            ),
            const SizedBox(height: 32),
            // Switch styles
            Switch(
              value: _useSiri,
              onChanged: (v) => setState(() => _useSiri = v),
            ),
            // Simulate audio
            Slider(
              value: _controller.amplitude,
              onChanged: (v) => _controller.amplitude = v,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📄 License

```
MIT License — Copyright (c) 2024
```

---

<div align="center">

Made with ❤️ for the Flutter community

</div>
