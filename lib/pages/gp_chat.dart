import 'dart:io';

import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/group_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/model/group_model.dart';
import 'package:app_chat/pages/group_profile.dart';
import 'package:app_chat/pages/top_navbar.dart';
import 'package:app_chat/utils/intl.dart';
import 'package:app_chat/utils/message_box.dart';
import 'package:app_chat/utils/snack_bar.dart';
import 'package:app_chat/utils/video_player_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  const GroupChatPage({super.key, required this.groupId});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final FocusNode myFocustNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final GroupService _groupService = GroupService();
  final PhotoService _photoService = PhotoService();
  late Future<GroupModel> groupFuture;

  @override
  void initState() {
    super.initState();
    print("===================================");
    print(widget.groupId);
    print("===================================");
    groupFuture = _groupService.getGroupInfo(widget.groupId);
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController
            .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        )
            .then((_) {
          // Check if it's not at the bottom after scrolling
          if (_scrollController.position.pixels !=
              _scrollController.position.maxScrollExtent) {
            // Try scrolling again
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      });
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

      String? imageUrl;
      if (image != null) {
        var uuid = Uuid();
        String uniqueFileName = uuid.v4();
        try {
          imageUrl = await _photoService.storeImageToStorage(
              file: image,
              reference: 'chat_images/${widget.groupId}/$uniqueFileName');
        } catch (e) {
          print(e.toString());
        }
      }

      await _groupService.sendGpMessage(widget.groupId, messageText,
          imageUrl: imageUrl, videoUrl: videoUrl);

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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TopNavBar(selectedIndex: 1)));
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: false,
        title: FutureBuilder<GroupModel>(
          future: groupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            } else if (snapshot.hasError) {
              return Text("Error loading group info");
            } else if (snapshot.hasData) {
              GroupModel group = snapshot.data!;
              return ListTile(
                onTap: () {
                  // Navigate to group settings or profile if needed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GroupProfile(groupId: widget.groupId),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(group.pf_path),
                  radius: 20,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    group.groupName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                subtitle: Text(''),
              );
            } else {
              return Text("Group not found");
            }
          },
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
            child: Center(
              child: _buildMessageList(),
            ),
          ),
          _buildUserInput(),
        ]),
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

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _groupService.getGroupMessages(widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Loading...'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages found.'));
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        // Scroll to bottom after the first frame is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollDown();
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot currentDoc = docs[index];
            DocumentSnapshot? nextDoc =
                index < docs.length - 1 ? docs[index + 1] : null;
            DocumentSnapshot? previousDoc = index > 0 ? docs[index - 1] : null;

            return _buildMessageItem(
              currentDoc,
              previousDoc != null
                  ? previousDoc['timestamp'] as Timestamp
                  : null,
              nextDoc != null ? nextDoc['senderId'] as String : null,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, Timestamp? previousTimestamp,
      String? nextSenderId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp currentTimestamp = data['timestamp'] as Timestamp;

    // Using trim to avoid any whitespace issues
    String senderId = data['senderId']?.trim() ?? '';
    String currentUserId = _authService.getCurrentUserID().trim();

    bool isCurrentUser = senderId == currentUserId;
    bool showProfileImage = senderId != nextSenderId;

    bool showDateLabel =
        shouldShowDateLabel(currentTimestamp, previousTimestamp);

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDateLabel)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                formatMessageTimestamp(currentTimestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.only(left: showProfileImage ? 0 : 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: isCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isCurrentUser &&
                    showProfileImage) // Show profile image only if it's the last message in the sequence
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 8.0), // Space between image and message
                    child: FutureBuilder<String>(
                      future: _photoService.getProfileUrl(senderId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (data['textMsg'] != null &&
                          data['textMsg']!.isNotEmpty)
                        MessageBox(
                          isCurrentUser: isCurrentUser,
                          message: data['textMsg']!,
                        ),
                      if (data['imageUrl'] != null &&
                          data['imageUrl']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Image.network(
                            data['imageUrl']!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (data['videoUrl'] != null &&
                          data['videoUrl']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: VideoPlayerWidget(videoUrl: data['videoUrl']),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool shouldShowDateLabel(
      Timestamp currentTimestamp, Timestamp? previousTimestamp) {
    if (previousTimestamp == null) {
      return true; // Always show label for the first message
    }

    DateTime currentDate = currentTimestamp.toDate();
    DateTime previousDate = previousTimestamp.toDate();

    return currentDate.year != previousDate.year ||
        currentDate.month != previousDate.month ||
        currentDate.day != previousDate.day;
  }
}
