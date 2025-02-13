import 'package:flutter/material.dart';

import '../Widgets/main_listtile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Column(
                  children: [
                    DrawerHeader(
                      child: Image.asset('assets/tht_logo.png'),
                    ),
                    main_listTile(image: "assets/profile.png",text: "Profile", press: () {  },),
                    main_listTile(image: "assets/services.png",text: "My Services", press: () {  },),
                    main_listTile(image: "assets/whoami.png", text: "Who am I", press: () {  },),
                    main_listTile(image: "assets/projects.png", text: "Recent Projects", press: () {  },),
                    main_listTile(image: "assets/testimonial.png", text: 'Testimonials', press: () {  },),
                    main_listTile(image: "assets/contact.png", text: 'Contact Us', press: () {  },),


                  ],
                )),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


