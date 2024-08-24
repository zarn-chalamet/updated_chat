import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/chat/group_service.dart';
import 'package:app_chat/model/gp_message.dart';
import 'package:app_chat/pages/gp_chat.dart';
import 'package:app_chat/utils/textfield.dart';
import 'package:app_chat/utils/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> selectedUsers = [];

  String userImage =
      "https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c";

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

  void _toggleUserSelection(String userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.add(userId);
      }
    });
    Navigator.pop(context);
    _showFullScreenPopup(context);
    print("+++++++++++++++++++++++++++++++++++++");
    print(selectedUsers);
    print("+++++++++++++++++++++++++++++++++++++");
  }

  void _createGroup() async {
    String groupName = groupNameController.text;
    if (groupName.isNotEmpty && selectedUsers != []) {
      await _groupService.createGroupInFireStore(groupName, selectedUsers);
      Navigator.pop(context);
    } else {
      print("Enter group name!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Expanded(child: _buildGroupLists()),
        ],
      ),
      floatingActionButton: _FloatingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGroupLists() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _groupService.getGroupStreams(
          _authService.getCurrentUserID()), // Provide the user's ID
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data ?? [];

        if (groups.isEmpty) {
          return Center(child: Text('No groups found'));
        }

        return Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Scrollbar(
            showTrackOnHover: true,
            thickness: 8.0,
            radius: Radius.circular(10),
            child: ListView(
              children: snapshot.data!
                  .map<Widget>(
                      (groupData) => _buildGroupListItem(groupData, context))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupListItem(
      Map<String, dynamic> groupData, BuildContext context) {
    print("FutureBuilder called for groupId: ${groupData['groupId']}");
    return FutureBuilder<GroupMessageModel?>(
      future: _groupService.getGpLastMessage(groupData['groupId']),
      builder: (context, snapshot) {
        print("============================================");
        print(snapshot.data?.textMsg);
        print("============================================");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return UserTile(
              text: groupData['groupName'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupChatPage(groupId: groupData['groupId']),
                  ),
                );
              },
              lastMessage: 'Loading...',
              profileUrl: groupData['pf_path'],
              timestamp: Timestamp.now());
        } else if (snapshot.hasError) {
          print("FutureBuilder error: ${snapshot.error}");
          return UserTile(
              text: groupData['groupName'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupChatPage(groupId: groupData['groupId']),
                  ),
                );
              },
              lastMessage: 'Error loading message!',
              profileUrl: groupData['pf_path'],
              timestamp: Timestamp.now());
        } else if (snapshot.hasData) {
          final lastMessage = snapshot.data?.textMsg ?? "No messages yet";
          final timestamp = snapshot.data?.timestamp ?? Timestamp.now();
          return UserTile(
              text: groupData['groupName'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupChatPage(groupId: groupData['groupId']),
                  ),
                );
              },
              lastMessage: lastMessage,
              profileUrl: groupData['pf_path'],
              timestamp: timestamp);
        } else {
          return UserTile(
              text: groupData['groupName'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupChatPage(groupId: groupData['groupId']),
                  ),
                );
              },
              lastMessage: 'No message yet!',
              profileUrl: groupData['pf_path'],
              timestamp: Timestamp.now());
        }
      },
    );
  }

  Widget _FloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showFullScreenPopup(context);
      },
      child: Icon(Icons.add),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      backgroundColor: Color(0xFF0DB0A4),
      foregroundColor: Colors.black,
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

  void _showFullScreenPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              backgroundColor: Colors.black.withOpacity(0.5),
              body: Center(
                child: Container(
                  width: 350,
                  height: 550,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(children: [
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: NetworkImage(userImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {},
                                        leading: Icon(Icons.camera_alt),
                                        title: Text('Camera'),
                                      ),
                                      ListTile(
                                        onTap: () {},
                                        leading: Icon(Icons.image),
                                        title: Text('Gallery'),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.greenAccent,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextBox(
                      controller: groupNameController,
                      obscureText: false,
                      hintText: 'Group Name',
                    ),
                    Text('Select Group Members'),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 40, left: 40, bottom: 10, top: 20),
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
                          hintText: 'SEARCH',
                          hintStyle: TextStyle(letterSpacing: 2),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildUserList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, bottom: 10, top: 10),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF0DB0A4),
                              ),
                            ),
                            onPressed: () {
                              _createGroup();
                            },
                            child: Text('CREATE'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40, bottom: 10, top: 10),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF0DB0A4),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              searchController.clear();
                            },
                            child: Text('CANCEL'),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Check if the current user is selected
    bool isSelected = selectedUsers.contains(userData['uid']);

    if (userData["email"] != _authService.getCurrentUserEmail()) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2, top: 2, left: 40, right: 40),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Colors.lightBlueAccent : Color(0xFFCAEEEB),
          ),
          child: Center(
            child: ListTile(
              leading: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(userData['pf_path']),
              ),
              title: Text(userData['username'] ?? "No Name"),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  _toggleUserSelection(userData['uid']);
                },
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_filterUsers);
    searchController.dispose();
    super.dispose();
  }
}
