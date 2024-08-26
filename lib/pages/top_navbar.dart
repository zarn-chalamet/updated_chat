import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/pages/groups_page.dart';
import 'package:app_chat/pages/home.dart';
import 'package:app_chat/pages/profile.dart';
import 'package:app_chat/pages/search_page.dart';
import 'package:flutter/material.dart';

class TopNavBar extends StatefulWidget {
  int selectedIndex;

  TopNavBar({super.key, required this.selectedIndex});

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();
  late int _selectedIndex;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 7, top: 2),
          child: const Text('CHAT APP'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SearchPage(selectedIndex: _selectedIndex),
                ),
              );
            },
            icon: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.search),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Profile(selectedIndex: _selectedIndex),
                  ),
                );
              },
              child: FutureBuilder<String>(
                future: _photoService
                    .getProfileUrl(_authService.getCurrentUserID()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/profile/profile_male.jpg'),
                      radius: 20,
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/profile/profile_male.jpg'),
                      radius: 20,
                    );
                  } else {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!),
                      radius: 20,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      fontWeight: _selectedIndex == 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Groups',
                    style: TextStyle(
                      fontWeight: _selectedIndex == 1
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Divider(color: Colors.grey, thickness: 0.8),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                _selectedIndex == 0 ? HomePage() : GroupPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
