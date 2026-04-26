import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Find the Lowest Prices',
      description: 'Access real-time fuel data across Queensland and save big on every tank.',
      icon: Icons.search_rounded,
      color: const Color(0xFF0D4D44),
    ),
    OnboardingData(
      title: 'Built for the Road',
      description: 'Seamlessly connects to Android Auto. Find the cheapest fuel without glancing at your phone.',
      icon: Icons.directions_car_filled_rounded,
      color: const Color(0xFF1E3D2F),
    ),
    OnboardingData(
      title: 'Cloud Sync Everywhere',
      description: 'Save your favorite stations and access them on your phone, tablet, or car dashboard.',
      icon: Icons.cloud_done_rounded,
      color: const Color(0xFF0D4D44),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: _pages[_currentPage].color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: page.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(page.icon, size: 100, color: page.color),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E3D2F),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF0D4D44) : Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        widget.onFinish();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D4D44),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onFinish,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(color: Colors.black38, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
