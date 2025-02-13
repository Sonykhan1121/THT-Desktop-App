import 'package:flutter/material.dart';
import 'package:mydesktopapp/pages/profile_tile.dart';
import '../Widgets/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _selectedPage = ProfilePage();

  void _updateContent(Widget newPage) {
    setState(() {
      _selectedPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SideMenu(onSelectPage: _updateContent),
            ),
            Expanded(
              flex: 5,
              child: _selectedPage,
            ),
          ],
        ),
      ),
    );
  }
}
