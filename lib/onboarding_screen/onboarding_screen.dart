
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


import '../Screen/LoginScreen.dart';
import 'IntroScreen1.dart';
import 'introScreen2.dart';
import 'introScreen3.dart';


class Onboarding_screen extends StatefulWidget {
  const Onboarding_screen({super.key});

  @override
  State<Onboarding_screen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboarding_screen> {
  final _controller = PageController();
  bool onLastPage = false;
  bool onFirstPage = false;
  int screenPageNum = 0;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 16),
          child: Text("$screenPageNum/3",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              )),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));

                },
                child: const Text(
                  "Skip",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  onLastPage = (index == 2);
                  onFirstPage = (index == 0);
                  screenPageNum = index + 1;
                });
              },
              children: const [
                IntrosScreen1(),
                Introscreen2(),
                Introscreen3(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                onFirstPage
                    ? GestureDetector(
                  onTap: () {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                  },
                  child: const Text(
                    "",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                  },
                  child: const Text(
                    "Prev",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey.shade400,
                      dotHeight: 10,
                      dotWidth: 14),
                ),
                onLastPage
                    ? GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));

                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn);
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}