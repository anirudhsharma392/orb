import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:siri_orb/orb.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orb Simulator',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF007AFF),
          secondary: Color(0xFFBF5AF2),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF007AFF),
          inactiveTrackColor: Colors.white12,
          thumbColor: Colors.white,
          overlayColor: const Color(0xFF007AFF).withValues(alpha: 0.2),
          trackHeight: 4.0,
        ),
      ),
      home: const OrbShowcasePage(),
    );
  }
}

class OrbShowcasePage extends StatefulWidget {
  const OrbShowcasePage({super.key});

  @override
  State<OrbShowcasePage> createState() => _OrbShowcasePageState();
}

class _OrbShowcasePageState extends State<OrbShowcasePage>
    with SingleTickerProviderStateMixin {
  late OrbController _orbController;
  late AnimationController _audioSimulatorController;
  late Animation<double> _audioSimulatorAnimation;

  double _radius = 120.0;
  bool _isPlaying = false;
  final Random _random = Random();
  
  List<Color> _currentPalette = OrbPalette.siriOriginal;
  String _currentThemeName = 'Siri';

  @override
  void initState() {
    super.initState();
    _orbController = OrbController(initialAmplitude: 0.0);

    _audioSimulatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _audioSimulatorController.dispose();
    super.dispose();
  }

  void _generateNextAudioFrame() {
    if (!_isPlaying) return;

    final target = _random.nextDouble() * 0.8;

    _audioSimulatorAnimation = Tween<double>(
      begin: _orbController.amplitude,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _audioSimulatorController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        _orbController.amplitude = _audioSimulatorAnimation.value;
      });

    _audioSimulatorController.forward(from: 0.0).then((_) {
      if (_isPlaying) {
        _generateNextAudioFrame();
      }
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _generateNextAudioFrame();
      } else {
        _audioSimulatorController.stop();
        _audioSimulatorAnimation = Tween<double>(
          begin: _orbController.amplitude,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _audioSimulatorController,
            curve: Curves.easeOut,
          ),
        )..addListener(() {
            _orbController.amplitude = _audioSimulatorAnimation.value;
          });
        _audioSimulatorController.forward(from: 0.0);
      }
    });
  }

  void _handleOrbTap(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Orb tapped! Interaction acknowledged.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.white24,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'AI Assistant Simulation',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [
                    Color(0xFF1C223A),
                    Color(0xFF0F111A),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _currentThemeName == 'Siri' 
                        ? SiriORB(
                            key: const ValueKey('siri'),
                            controller: _orbController,
                            radius: _radius,
                            onTap: () => _handleOrbTap(context),
                          )
                        : Orb(
                            key: ValueKey(_currentThemeName),
                            controller: _orbController,
                            radius: _radius,
                            waveColors: _currentPalette,
                            onTap: () => _handleOrbTap(context),
                          ),
                    ),
                  ),
                ),
                
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _isPlaying ? 'Listening...' : 'Standing By',
                                      key: ValueKey<bool>(_isPlaying),
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.5,
                                            color: _isPlaying ? const Color(0xFF007AFF) : Colors.white,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isPlaying 
                                      ? 'Awaiting voice input simulation'
                                      : 'Tap microphone to simulate audio',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _togglePlayback,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isPlaying
                                        ? const Color(0xFFFF3B30).withValues(alpha: 0.2)
                                        : const Color(0xFF007AFF).withValues(alpha: 0.2),
                                    border: Border.all(
                                      color: _isPlaying
                                          ? const Color(0xFFFF3B30)
                                          : const Color(0xFF007AFF),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isPlaying
                                            ? const Color(0xFFFF3B30).withValues(alpha: 0.4)
                                            : const Color(0xFF007AFF).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.stop_rounded : Icons.mic_rounded,
                                    color: _isPlaying ? const Color(0xFFFF3B30) : const Color(0xFF007AFF),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Palette Switcher
                          const Text(
                            'Orb Theme',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildThemeButton('Siri', []),
                              _buildThemeButton('Basic', OrbPalette.siriOriginal),
                              _buildThemeButton('Inferno', OrbPalette.inferno),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Manual Amplitude',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          AnimatedBuilder(
                            animation: _orbController,
                            builder: (context, _) {
                              return Slider(
                                value: _orbController.amplitude,
                                min: 0.0,
                                max: 1.0,
                                onChanged: _isPlaying
                                    ? null
                                    : (val) {
                                        _orbController.amplitude = val;
                                      },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Orb Radius: ${_radius.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Slider(
                            value: _radius,
                            min: 40.0,
                            max: 200.0,
                            onChanged: (val) {
                              setState(() {
                                _radius = val;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(String name, List<Color> palette) {
    final isSelected = _currentThemeName == name;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentThemeName = name;
            _currentPalette = palette;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
