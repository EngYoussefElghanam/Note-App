import 'package:flutter/material.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<Map<String, String>> pages = [
    {
      "title": "Organize Your Notes",
      "subtitle":
          "Create, edit, and manage your notes with ease — all in one place.",
      "image": "assets/onboarding1.svg",
    },
    {
      "title": "Sync with Firebase",
      "subtitle": "Access your notes securely on any device, anytime.",
      "image": "assets/onboarding2.svg",
    },
    {
      "title": "Go Premium",
      "subtitle":
          "Unlimited notes, tags, and powerful features with one upgrade.",
      "image": "assets/onboarding3.svg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == pages.length - 1);
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            "assets/images/Logo.png", // replace with flutter_svg
                            height: 220,
                          ),
                        ),
                      ),
                      Text(
                        page["title"]!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        page["subtitle"]!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                    ],
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              effect: const WormEffect(dotHeight: 8, dotWidth: 8),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (isLastPage) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(isLastPage ? "Get Started" : "Next"),
            ),
          ],
        ),
      ),
    );
  }
}
