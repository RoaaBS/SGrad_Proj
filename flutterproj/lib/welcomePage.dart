import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class welcomePage extends StatelessWidget {
  static const String routeName = "/welcomePage";
  const welcomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final threeQuartersHeight =
        screenHeight * 0.8; // زيادة ارتفاع الصور بنسبة قليلة

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: threeQuartersHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: MediaQuery.of(context).size.width /
                            threeQuartersHeight,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                      ),
                      items: [
                        Image.asset(
                          'assets/images/hadia4.jpeg',
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Image.asset(
                          'assets/images/hadia1.jpeg',
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // تقليص المسافة بين الصورة والأزرار
            Text(
              'مرحبا بكم في تطبيق هديتي',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/SignUp');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
