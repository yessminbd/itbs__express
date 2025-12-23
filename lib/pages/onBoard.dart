import 'package:flutter/material.dart';
import 'package:itbs__express/pages/signUp.dart';
import 'package:itbs__express/widgets/content_model.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Évite que le contenu touche le notch/status bar
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return SingleChildScrollView(
                    // Permet le scroll si overflow
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40.0),
                          Image.asset(
                            contents[i].image,
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 40.0),
                          Text(
                            contents[i].title,
                            style: AppWidget.HeadlineTextFeildStyle(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            contents[i].description,
                            style: AppWidget.LightTextFeildStyle(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (currentIndex == contents.length - 1) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(20)),
                height: 60,
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                child: Center(
                  child: Text(
                    currentIndex == contents.length - 1
                        ? "Commencer"
                        : "Suivant",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: Colors.black38),
    );
  }
}
