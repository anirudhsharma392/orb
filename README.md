# Orb

A Flutter package providing a beautiful, circular, multicolored animated interface element inspired by the Siri orb. It smoothly animates continuous flowing color waves and supports a response "amplitude" value for representing voice inputs or other interactive states.

## Features

- **Beautiful Smooth Animations:** Continuous fluid gradients mimicking fluid physics, fully GPU accelerated via CustomPaint.
- **Amplitude Response:** Visually responds to audio levels or other values by distorting and scaling.
- **Efficient State Management:** Uses `SiriOrbController` to animate amplitude changes without rebuilding your layout.
- **Click Feedback:** Built-in elastic tap animations when interacting.
- **Customizable:** Easily provide different radiuses and attach callbacks.

## Getting started

In your `pubspec.yaml`, add the dependency:
```yaml
dependencies:
  orb: ^0.0.1
```

Import it:
```dart
import 'package:orb/orb.dart';
```

## Usage

Create a `SiriOrbController` to manage the orb's amplitude natively:

```dart
late SiriOrbController _orbController;

@override
void initState() {
  super.initState();
  _orbController = SiriOrbController(initialAmplitude: 0.0);
}

@override
void dispose() {
  _orbController.dispose();
  super.dispose();
}
```

Add the `SiriOrbAnimation` widget to your UI, passing the controller to it:

```dart
Scaffold(
  body: Center(
    child: SiriOrbAnimation(
      controller: _orbController,
      radius: 100, // Size of your orb
      onTap: () {
        print("Orb Tapped!");
      },
    ),
  ),
)
```

## How to use amplitude

For a microphone/audio active state, provide a value from 0.0 to 1.0 to the controller's `amplitude`. The orb will jiggle, squash, and stretch dynamically based on this intensity. 

```dart
// Safely assigning stream audio data to the controller
myAudioPlugin.loudnessStream.listen((volume) {
  _orbController.amplitude = volume; 
});
```
