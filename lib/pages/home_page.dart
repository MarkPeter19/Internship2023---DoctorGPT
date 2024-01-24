import 'package:doctorgpt/pages/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/pages/personal_data_page.dart';
import '../custom/custom_appbar.dart';
import '../custom/custom_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Adjust the duration if needed
    );

    _fadeInAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideUpAnimation = Tween<Offset>(begin: const Offset(0, 4), end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward().whenComplete(() {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _showContent = true;
        });
      });
    });
  }

  bool _showContent = false;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: widget.title),
      body: Container(
        color: Color.fromARGB(210, 16, 0, 35),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SlideTransition(
                position: _slideUpAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Hi,\nDoctorGPT is here \nfor your help',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 100), // Adjust spacing as needed
                      if (_showContent)
                        Column(
                          children: [
                            FadeTransition(
                              opacity: _fadeInAnimation,
                              child: CustomButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PersonalDataPage(
                                        title: 'Personal Data',
                                      ),
                                    ),
                                  );
                                },
                                buttonIcon: const Icon(
                                  Icons.person,
                                  size: 30,
                                ),
                                buttonText: 'Personal Data',
                              ),
                            ),
                            SizedBox(height: 25), // Adjust spacing as needed
                            FadeTransition(
                              opacity: _fadeInAnimation,
                              child: CustomButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ScannerPage(
                                        title: 'Scan Document',
                                      ),
                                    ),
                                  );
                                },
                                buttonIcon: const Icon(
                                  Icons.document_scanner,
                                  size: 30,
                                ),
                                buttonText: 'Scan Document',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
