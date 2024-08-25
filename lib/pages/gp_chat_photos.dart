import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/chat/group_service.dart';
import 'package:app_chat/utils/video_player_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupChatPhotos extends StatefulWidget {
  final String groupId;
  const GroupChatPhotos({super.key, required this.groupId});

  @override
  State<GroupChatPhotos> createState() => _GroupChatPhotosState();
}

class _GroupChatPhotosState extends State<GroupChatPhotos> {
  final GroupService _groupService = GroupService();

  get builder => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
            stream: _groupService.getGroupMessages(widget.groupId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              print("++++++++++++++++++++++++++++++++++++++++++++++");
              print("current User Id : " + widget.groupId);
              print("++++++++++++++++++++++++++++++++++++++++++++++");

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text('Loading...'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No photos or videos found.'));
              }

              // Filter the documents to include only those with an image or video URL
              List<DocumentSnapshot> filteredDocs =
                  snapshot.data!.docs.where((doc) {
                return (doc['textMsg'] == null);
              }).toList();

              if (filteredDocs.isEmpty) {
                return Center(child: Text('No photos or videos found.'));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 5,
                ),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot currentDoc = filteredDocs[index];
                  if (currentDoc['textMsg'] == null &&
                      currentDoc['imageUrl'] != null) {
                    return Container(
                      child: Image.network(currentDoc['imageUrl'],
                          fit: BoxFit.cover),
                    );
                  } else if (currentDoc['textMsg'] == null &&
                      currentDoc['videoUrl'] != null) {
                    return Container(
                      child:
                          VideoPlayerWidget(videoUrl: currentDoc['videoUrl']),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            }),
      ),
    );
  }
}
