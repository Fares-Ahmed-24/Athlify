import 'package:flutter/material.dart';
import 'package:Athlify/intro.dart';
import 'package:Athlify/widget/intro_layout.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class Intro extends StatefulWidget {
  const Intro({super.key});
  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  PageController pageController = PageController();
  String btntxt = "skip";
  int curruntindex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged:
                (index) => {
                  curruntindex = index,
                  if (index == 2) {btntxt = "Finish"} else {btntxt = "Skip"},
                  setState(() {}),
                },
            children: [
              IntroScreens(
                imagePath: 'assets/image.png',
                title: 'Welcome to Athlify',
                subtitle:
                    "Book your favorite field, choose your session time, and get ready to play — all in just a few taps. Let's get you on the field!",
              ),
              IntroScreens(
                imagePath: 'assets/book.png',
                title: 'Find and Book Sports fields',
                subtitle:
                    'You can easily find sports fields of multi sports around you and book online.',
              ),
              IntroScreens(
                imagePath: 'assets/train.png',
                title: 'Get Coaching assistance',
                subtitle:
                    'You can easily connect with a coach , book sessions to improve your skills.',
              ),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.7),
            child: SmoothPageIndicator(
              controller: pageController,
              count: 3,
              effect: const WormEffect(
                activeDotColor: Color(0xff243555),
                dotColor: Colors.grey,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {

                                            Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Or()));
                    
                      
                    },
                    child: Text(
                      btntxt,
                      style: const TextStyle(
                        color: Color(0xff243555),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  curruntindex == 2
                      ? const SizedBox(width: 10)
                      : TextButton(
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            color: Color(0xff243555),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
