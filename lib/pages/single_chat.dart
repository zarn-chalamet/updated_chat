import 'dart:io';

import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/pages/receiver_profile.dart';
import 'package:app_chat/utils/message_box.dart';
import 'package:app_chat/utils/snack_bar.dart';
import 'package:app_chat/utils/textfield.dart';
import 'package:app_chat/utils/video_player_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleChatPage extends StatefulWidget {
  final String receiverMail;
  final String receiverID;
  SingleChatPage(
      {super.key, required this.receiverMail, required this.receiverID});

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();

  FocusNode myFocustNode = FocusNode();

  @override
  void initState() {
    super.initState();

    myFocustNode.addListener(() {
      if (myFocustNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => scrollDown(),
      );
    });
  }

  @override
  void dispose() {
    myFocustNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void sendMessage1({File? image, File? video}) async {
    if (image != null || _messageController.text.isNotEmpty || video != null) {
      String? messageText =
          _messageController.text.isNotEmpty ? _messageController.text : null;

      String? videoUrl;
      if (video != null) {
        videoUrl = await _photoService.storeVideoFileToStorage(
          file: video,
          reference: 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4',
          contentType: 'video/mp4',
        );
      }

      await _chatService.sendMessage(
        widget.receiverID,
        message: messageText,
        image: image,
        videoUrl: videoUrl,
      );

      _messageController.clear();
      scrollDown();
    }
  }

  void selectVideo() async {
    File? videoFile = await _photoService.pickVideo(onFail: (String message) {
      showSnackBar(context, message);
    });
    Navigator.pop(context);

    if (videoFile != null) {
      sendMessage1(video: videoFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: false,
        title: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReceiverProfile(
                    receiverMail: widget.receiverMail,
                    receiverID: widget.receiverID),
              ),
            );
          },
          leading: FutureBuilder<String>(
            future: _photoService.getProfileUrl(
                widget.receiverID), // Use the method you provided
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
                  backgroundImage: NetworkImage(
                      snapshot.data!), // Load the profile image from the URL
                  radius: 20,
                );
              }
            },
          ),
          title: FutureBuilder<String>(
            future: _authService.getReceiverUsername(widget.receiverID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading...");
              } else if (snapshot.hasError) {
                return Text("Error in 2");
              } else if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                );
              } else {
                return Text("No name");
              }
            },
          ),
          subtitle: Text(
            "Active Now",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.phone)),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.video_call)),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ]),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUserID();
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error in StreamBuilder: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("StreamBuilder is loading...");
          return Center(child: Text('Loading...'));
        }

        // Ensure snapshot has data
        if (!snapshot.hasData) {
          print("No data found in StreamBuilder.");
          return Center(child: Text('No messages found.'));
        }

        // Check if the data is empty
        if (snapshot.data!.docs.isEmpty) {
          print("Snapshot data is empty.");
          return Center(child: Text('No messages found.'));
        }

        // Return ListView
        print("Messages received: ${snapshot.data!.docs.length}");
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _authService.getCurrentUserID();

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      margin: EdgeInsets.all(5),
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (data['message'] != null)
            MessageBox(isCurrentUser: isCurrentUser, message: data['message']!),
          if (data['imageUrl'] != null)
            Image.network(
              data['imageUrl']!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          if (data['videoUrl'] != null)
            // You can use a video player package to display the video, e.g., `video_player`
            VideoPlayerWidget(videoUrl: data['videoUrl']),
        ],
      ),
    );
  }

  // Build message input
  Widget _buildUserInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () async {
            // Declare a boolean to track the user's choice
            bool? fromCamera = await showModalBottomSheet<bool>(
              context: context,
              builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height / 5,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(context, true); // Return true for Camera
                      },
                      leading: Icon(Icons.camera_alt),
                      title: Text('Camera'),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pop(
                            context, false); // Return false for Gallery
                      },
                      leading: Icon(Icons.image),
                      title: Text('Gallery'),
                    ),
                    ListTile(
                      onTap: () {
                        selectVideo();
                      },
                      leading: Icon(Icons.video_library),
                      title: Text('Video'),
                    ),
                  ],
                ),
              ),
            );

            // Proceed only if the user made a choice
            if (fromCamera != null) {
              File? image = await _photoService.pickImage(
                fromCamera: fromCamera,
                onFail: (error) => print(error),
              );
              if (image != null) {
                // Send the image
                sendMessage1(image: image);
              }
            }
          },
          icon: Icon(
            Icons.link,
            size: 30,
          ),
        ),
        // Textfield
        Expanded(
          child: Container(
            child: TextField(
              focusNode: myFocustNode,
              controller: _messageController,
              obscureText: false,
              cursorColor: Color.fromARGB(255, 130, 132, 132),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFCAEEEB),
                hintText: "Type a message",
                hintStyle: TextStyle(
                  letterSpacing: 2,
                  color: Color.fromARGB(255, 167, 169, 167),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 36, 141, 132),
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
        // Send button
        IconButton(
          onPressed: sendMessage1,
          icon: Icon(
            Icons.arrow_upward,
            size: 30,
          ),
        ),
      ],
    );
  }
}
