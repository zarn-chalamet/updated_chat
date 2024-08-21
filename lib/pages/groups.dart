import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/utils/drawer.dart';
import 'package:app_chat/utils/textfield.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController groupNameController = TextEditingController();

  String userImage =
      "https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('CHAT APP'),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/profile/profile_male.jpg'),
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Text(
                      'Chats',
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                    )),
                GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Groups',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ))
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5),
            child: Divider(
              color: Colors.grey,
              thickness: 0.8,
            ),
          ),
          Expanded(
              child: Center(
            child: Text('Groups'),
          )),
        ],
      ),
      floatingActionButton: _FloatingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _FloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showFullScreenPopup(context);
      },
      child: Icon(Icons.add),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100), // Rounded corners
      ),
      backgroundColor: Color(0xFF0DB0A4),
      foregroundColor: Colors.black,
    );
  }

  void _showFullScreenPopup(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // Make the background transparent
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: Container(
                width: 350,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  SizedBox(
                    height: 20,
                  ),
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
                                builder: ((context) => SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              5,
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
                                    )));
                          },
                          child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.greenAccent,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                              )),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextBox(
                      controller: groupNameController,
                      obscureText: false,
                      hintText: ' Group Name'),
                  Text('Select Group Memebers'),
                  Expanded(
                    child: _buildUserList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF0DB0A4))),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the popup
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                    ],
                  )
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatService.getUserStream(),
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return Text('Error in 1');
          }

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), // Loading animation
            );
          }

          //return List View
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4),
              child: Scrollbar(
                showTrackOnHover: true,
                thickness: 8.0,
                radius: Radius.circular(10),
                child: ListView(
                  children: snapshot.data!
                      .map<Widget>(
                          (userData) => _buildUserListItem(userData, context))
                      .toList(),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
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
              leading: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c"),
              ),
              title: Text(userData['username'] ?? "No Name"),
              subtitle: null,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
