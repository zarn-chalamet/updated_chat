import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/pages/groups_page.dart';
import 'package:app_chat/pages/home.dart';
import 'package:flutter/material.dart';

class TopNavBar extends StatefulWidget {
  const TopNavBar({super.key});

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();
  int _selectedIndex = 0; // Tracks the selected tab

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHAT APP'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const SizedBox(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
              child: FutureBuilder<String>(
                future: _photoService.getProfileUrl(_authService
                    .getCurrentUserID()), // Use the method you provided
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/profile/profile_male.jpg'), // Placeholder image
                      radius: 20,
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/profile/profile_male.jpg'), // Fallback image in case of error
                      radius: 20,
                    );
                  } else {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(snapshot
                          .data!), // Load the profile image from the URL
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
                    )),
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
                    )),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
            child: Divider(
              color: Colors.grey,
              thickness: 0.8,
            ),
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
                HomePage(),
                const GroupPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsPage() {
    return Center(child: Text('Chats Page'));
  }

  Widget _buildGroupsPage() {
    return Center(child: Text('Groups Page'));
  }
}
