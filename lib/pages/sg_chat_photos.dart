import 'package:app_chat/chat/chat_service.dart';
import 'package:app_chat/utils/video_player_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleChatPhotos extends StatefulWidget {
  final String currentUserId;
  final String receiverUserId;
  const SingleChatPhotos(
      {super.key, required this.currentUserId, required this.receiverUserId});

  @override
  State<SingleChatPhotos> createState() => _SingleChatPhotosState();
}

class _SingleChatPhotosState extends State<SingleChatPhotos> {
  final ChatService _chatService = ChatService();

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
            stream: _chatService.getMessages(
                widget.receiverUserId, widget.currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              print("++++++++++++++++++++++++++++++++++++++++++++++");
              print("current User Id : " + widget.currentUserId);
              print("receiver User Id : " + widget.receiverUserId);
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
                return (doc['message'] == null);
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
                  if (currentDoc['message'] == null &&
                      currentDoc['imageUrl'] != null) {
                    return Container(
                      child: Image.network(currentDoc['imageUrl'],
                          fit: BoxFit.cover),
                    );
                  } else if (currentDoc['message'] == null &&
                      currentDoc['videoUrl'] != null) {
                    return Container(
                      child:
                          VideoPlayerWidget(videoUrl: currentDoc['videoUrl']),
                    );
                  } else {
                    return Container(
                      color: Colors.grey[
                          300], // Optional background color for the placeholder
                      child: Center(
                        child: Icon(Icons.error_outline,
                            color: Colors.red), // Placeholder icon
                      ),
                    );
                  }
                },
              );
            }),
      ),
    );
  }
}
