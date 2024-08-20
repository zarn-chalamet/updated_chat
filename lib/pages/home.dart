import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/model/message.dart';
import 'package:app_chat/pages/single_chat.dart';

import 'package:app_chat/utils/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final PhotoService _photoService = PhotoService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('CHAT APP'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Text(''),
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
                    return CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/profile/profile_male.jpg'), // Placeholder image
                      radius: 20,
                    );
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return CircleAvatar(
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
      // drawer: MyDrawer(),
      body: _bodyy(),
    );
  }

  Widget _bodyy() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Chats',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  )),
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/groups');
                  },
                  child: Text(
                    'Groups',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
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
        Expanded(child: _buildUserList()),
      ],
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
          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUserEmail()) {
      return FutureBuilder<Message?>(
        future: _chatService.getLastMessage(
            _authService.getCurrentUserID(), userData["uid"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildUserTileWithProfileUrl(
              userData: userData,
              context: context,
              lastMessage: 'Loading...',
              receiverID: userData["uid"],
              timestamp: Timestamp.now(),
            );
          } else if (snapshot.hasError) {
            return _buildUserTileWithProfileUrl(
              userData: userData,
              context: context,
              lastMessage: 'Error loading message!',
              receiverID: userData["uid"],
              timestamp: Timestamp.now(),
            );
          } else if (snapshot.hasData) {
            final lastMessage = snapshot.data?.message ?? "No messages yet";
            final timestamp = snapshot.data?.timestamp ?? Timestamp.now();
            return _buildUserTileWithProfileUrl(
              userData: userData,
              context: context,
              lastMessage: lastMessage,
              receiverID: userData["uid"],
              timestamp: timestamp,
            );
          } else {
            return _buildUserTileWithProfileUrl(
              userData: userData,
              context: context,
              lastMessage: 'No messages yet!',
              receiverID: userData["uid"],
              timestamp: Timestamp.now(),
            );
          }
        },
      );
    } else {
      return Container();
    }
  }
}

Widget _buildUserTileWithProfileUrl({
  required Map<String, dynamic> userData,
  required BuildContext context,
  required String lastMessage,
  required String receiverID,
  required Timestamp timestamp,
}) {
  final PhotoService _photoService = PhotoService();
  return FutureBuilder<String>(
    future: _photoService.getProfileUrl(userData['uid']),
    builder: (context, profileSnapshot) {
      String profileUrl =
          'https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c';
      if (profileSnapshot.connectionState == ConnectionState.done &&
          profileSnapshot.hasData) {
        profileUrl = profileSnapshot.data!;
      }

      return UserTile(
        text: userData["username"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleChatPage(
                receiverMail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        },
        lastMessage: lastMessage,
        profileUrl: profileUrl,
        timestamp: timestamp,
      );
    },
  );
}
