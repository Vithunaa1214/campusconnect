/*
 * CAMPUSCONNECT - Professor Welcome/Dashboard Screen
 * 
 * REQUIRED PACKAGES (add to pubspec.yaml):
 * dependencies:
 *   flutter:
 *     sdk: flutter
 *   lottie: ^3.0.0
 *   animated_text_kit: ^4.2.2
 *   visibility_detector: ^0.4.0+2
 * 
 * REQUIRED ASSETS (add to pubspec.yaml):
 * flutter:
 *   assets:
 *     - assets/lottie/Online Learning.json
 * 
 * USAGE:
 * Navigator.pushReplacement(
 *   context,
 *   MaterialPageRoute(builder: (context) => WelcomeScreen()),
 * );
 */

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:visibility_detector/visibility_detector.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _taglineController;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;

  bool _typingComplete = false;

  // Track which cards have been animated
  final Map<int, bool> _cardAnimationStates = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
  };

  @override
  void initState() {
    super.initState();

    // Tagline animation controller
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start tagline animation after a brief delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _taglineController.forward();
      }
    });
  }

  @override
  void dispose() {
    _taglineController.dispose();
    super.dispose();
  }

  void _onTypingComplete() {
    setState(() {
      _typingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildLogoSection(),
                const SizedBox(height: 16),
                _buildAppName(),
                const SizedBox(height: 12),
                _buildTagline(),
                const SizedBox(height: 24),
                _buildLottieAnimation(),
                const SizedBox(height: 24),
                _buildFeatureCards(),
                const SizedBox(height: 24),
                _buildFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.school_outlined,
        size: 50,
        color: Color(0xFF00ADB5),
      ),
    );
  }

  Widget _buildAppName() {
    return AnimatedTextKit(
      animatedTexts: [
        TyperAnimatedText(
          'CAMPUS CONNECT',
          textStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222831),
            letterSpacing: 1.2,
          ),
          speed: const Duration(milliseconds: 80),
        ),
      ],
      totalRepeatCount: 1,
      pause: const Duration(milliseconds: 100),
      displayFullTextOnTap: false,
      stopPauseOnTap: false,
      onFinished: _onTypingComplete,
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _taglineFadeAnimation,
      child: SlideTransition(
        position: _taglineSlideAnimation,
        child: const Text(
          'Your digital companion for smarter campus life.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF393E46), height: 1.4),
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return SizedBox(
      height: 200,
      child: Lottie.asset(
        'assets/lottie/Online Learning.json',
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      _FeatureData(
        title: 'Attendance Management',
        description: 'Track and manage student attendance efficiently',
        icon: Icons.fact_check_outlined,
      ),
      _FeatureData(
        title: 'Lab Occupancy',
        description: 'Monitor real-time lab availability and usage',
        icon: Icons.computer_outlined,
      ),
      _FeatureData(
        title: 'Class Occupancy',
        description: 'Track classroom usage and availability in real-time',
        icon: Icons.meeting_room_outlined,
      ),
      _FeatureData(
        title: 'Timetable System',
        description: 'View and organize class schedules seamlessly',
        icon: Icons.calendar_today_outlined,
      ),
      _FeatureData(
        title: 'Exam Seating',
        description: 'Arrange and manage exam seating plans',
        icon: Icons.event_seat_outlined,
      ),
    ];

    return Column(
      children: features
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: entry.key % 2 == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: SizedBox(
                  width: 220, // Smaller width
                  child: _buildAnimatedFeatureCard(
                    entry.value,
                    entry.key,
                    entry.key % 2 == 0,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAnimatedFeatureCard(
    _FeatureData feature,
    int index,
    bool isLeft,
  ) {
    return VisibilityDetector(
      key: Key('feature_card_$index'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && !_cardAnimationStates[index]!) {
          setState(() {
            _cardAnimationStates[index] = true;
          });
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        opacity: _cardAnimationStates[index]! ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          offset: _cardAnimationStates[index]!
              ? Offset.zero
              : Offset(isLeft ? -1.0 : 1.0, 0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            scale: _cardAnimationStates[index]! ? 1.0 : 0.8,
            child: _buildFeatureCard(feature),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureData feature) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle card tap - navigate to respective feature
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${feature.title} tapped'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00ADB5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature.icon,
                  color: const Color(0xFF00ADB5),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222831),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feature.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF393E46),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      '© 2025 CampusConnect. All Rights Reserved.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Color(0xFF393E46)),
    );
  }
}

class _FeatureData {
  final String title;
  final String description;
  final IconData icon;

  _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/*
 * ROUTING EXAMPLE:
 * 
 * // In your login success handler:
 * if (loginSuccessful) {
 *   Navigator.pushReplacement(
 *     context,
 *     MaterialPageRoute(
 *       builder: (context) => const WelcomeScreen(),
 *     ),
 *   );
 * }
 * 
 * // Or with named routes in main.dart:
 * MaterialApp(
 *   routes: {
 *     '/welcome': (context) => const WelcomeScreen(),
 *   },
 * );
 * 
 * // Then navigate:
 * Navigator.pushReplacementNamed(context, '/welcome');
 */
