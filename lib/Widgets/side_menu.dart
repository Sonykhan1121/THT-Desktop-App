import 'package:flutter/material.dart';
import 'package:mydesktopapp/pages/achievement_tiles.dart';
import 'package:mydesktopapp/pages/admincontactinfopage.dart';
import 'package:mydesktopapp/pages/services_tile.dart';
import '../pages/profile_tile.dart';
import '../pages/projects_tile.dart';
import '../pages/whoami_tile.dart';
import 'main_listtile.dart';
  // Ensure you have a ProfilePage widget defined somewhere

class SideMenu extends StatelessWidget {
  final Function(Widget) onSelectPage;

  const SideMenu({super.key, required this.onSelectPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset('assets/tht_logo.png'),
            ),
            MainListTile(
              image: "assets/profile.png",
              text: "Profile",
              press: () => onSelectPage(ProfilePage()),
            ),
            MainListTile(
              image: "assets/services.png",
              text: "My Services",
              press: () => onSelectPage(MyServicesPage()),
            ),
            MainListTile(
              image: "assets/whoami.png",
              text: "Who am I",
              press: () => onSelectPage(Whoami()),
            ),
            MainListTile(
              image: "assets/projects.png",
              text: "Recent Projects",
              press: () => onSelectPage(ProjectSubmissionPage()),
            ),
            MainListTile(
              image: "assets/testimonial.png",
              text: 'Achievements',
              press: () => onSelectPage(AchievementsPage()),
            ),
            MainListTile(
              image: "assets/contact.png",
              text: 'Contact Us',
              press: () => onSelectPage(AdminContactInfoPage()),
            ),
          ],
        ),
      ),
    );
  }
}
