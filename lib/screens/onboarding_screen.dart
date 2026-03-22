import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/onboarding_model.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          /// ✅ SINGLE GRADIENT (Matches Figma)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE4B53E),
                  Color(0xFF151515),
                ],
                stops: [0.0, 0.42], // Controls gold height
              ),
            ),
          ),

          /// CONTENT
          SafeArea(
            child: Column(
              children: [
                /// Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        try {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MainShell(),
                            ),
                          );
                        } catch (e) {
                          print('Navigation error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                /// PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final data = onboardingData[index];

                      return Column(
                        children: [
                          /// MOCKUP SECTION
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 10,
                              ),
                              child: _buildMockup(index),
                            ),
                          ),

                          /// TEXT SECTION
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  32, 10, 32, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: GoogleFonts.outfit(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      children: [
                                        TextSpan(text: data.title),
                                        TextSpan(
                                          text: data.titleHighlight,
                                          style: const TextStyle(
                                            color: Color(0xFFE4B53E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    data.description,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                /// BOTTOM NAVIGATION
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPageIndicator(),
                      _buildNextButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Widget _buildMockup(int index) {
//   return SizedBox(
//     height: 420,
//     child: Stack(
//       clipBehavior: Clip.none,
//       children: [
//         // Back card
//         Positioned(
//           right: 25,
//           top: 60,
//           child: Container(
//             width: 240,
//             height: 180,
//             color: Colors.blue, // temporary
//           ),
//         ),

//         // Front card
//         Positioned(
//           left: -15,
//           top: 0,
//           child: Container(
//             width: 300,
//             height: 200,
//             color: Colors.green, // temporary
//           ),
//         ),
//       ],
//     ),
//   );
// }

  /// ✅ PERFECT FIGMA-STYLE MOCKUP
Widget _buildMockup(int index) {
  final data = onboardingData[index];

  return SizedBox(
    height: 420,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        /// BACK CARD (More inside now)
        Positioned(
          right: 15,   // was negative — now inside screen
          top: 60,
          child: Opacity(
            opacity: 0.9,
            child: Image.asset(
              'assets/images/onboarding_back_1.png',
              width: 240,
              fit: BoxFit.contain,
            ),
          ),
        ),

        /// FRONT CARD (Closer to edge)
        Positioned(
          left: -25,   // pushes closer to screen edge
          top: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              data.imagePath,
              width: 300,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    ),
  );
}


  /// PAGE INDICATOR
  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(
        onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          height: 4,
          width: _currentIndex == index ? 24 : 12,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? const Color(0xFFE4B53E)
                : Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// NEXT BUTTON
  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
        if (_currentIndex < onboardingData.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainShell(),
            ),
          );
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFE4B53E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}
