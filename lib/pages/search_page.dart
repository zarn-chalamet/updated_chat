import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/pages/single_chat.dart';
import 'package:app_chat/pages/top_navbar.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final int selectedIndex;
  const SearchPage({super.key, required this.selectedIndex});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    // Call this method to filter when user types
    setState(() {
      filteredUsers = allUsers.where((user) {
        return user['username']
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 20, right: 5),
          child: _appBar(),
        ),
        Expanded(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30),
                  child: Text(
                    'Suggested',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _buildUserList(),
            )
          ],
        ))
      ],
    ));
  }

  Widget _appBar() {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              width: 300,
              height: 35,
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    filteredUsers = allUsers.where((user) {
                      return user['username']
                          .toLowerCase()
                          .contains(value.toLowerCase());
                    }).toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.only(bottom: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TopNavBar(selectedIndex: widget.selectedIndex)));
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Show loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Store all users fetched from the stream
        allUsers = snapshot.data!;

        // Filter users based on the current search input
        filteredUsers = allUsers
            .where((user) => user['username']
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();

        // Return the list view of filtered users
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0, left: 4),
            child: Scrollbar(
              showTrackOnHover: true,
              thickness: 8.0,
              radius: Radius.circular(10),
              child: ListView(
                children: filteredUsers
                    .map<Widget>(
                        (userData) => _buildUserListItem(userData, context))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Check if the current user is selected

    if (userData["email"] != _authService.getCurrentUserEmail()) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2, top: 2, left: 40, right: 40),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFFCAEEEB),
          ),
          child: Center(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleChatPage(
                        receiverMail: userData['email'],
                        receiverID: userData['uid']),
                  ),
                );
              },
              leading: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(userData['pf_path']),
              ),
              title: Text(userData['username'] ?? "No Name"),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  // @override
  // void dispose() {
  //   searchController.removeListener(_filterUsers);
  //   // searchController.dispose();
  //   super.dispose();
  // }
}
