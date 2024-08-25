import 'dart:io';

import 'package:app_chat/chat/group_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/model/group_model.dart';
import 'package:app_chat/pages/gp_chat.dart';
import 'package:app_chat/pages/gp_chat_photos.dart';
import 'package:app_chat/utils/snack_bar.dart';
import 'package:flutter/material.dart';

class GroupProfile extends StatefulWidget {
  final String groupId;
  const GroupProfile({super.key, required this.groupId});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
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

  void selectImage(bool fromCamera) async {
    File? newFile = await _photoService.pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    Navigator.pop(context);
    if (newFile != null) {
      await _groupService.updateGroupProfile(widget.groupId, newFile);
    }
    Navigator.pop(context);
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroupProfile(groupId: widget.groupId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatPage(groupId: widget.groupId),
                ),
              );
            },
            icon: Icon(Icons.arrow_back_outlined)),
        title: Text(''),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
          )
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(children: [
            SizedBox(
              height: 20,
            ),
            FutureBuilder<GroupModel>(
              future: groupFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/profile/profile_male.jpg'), // Placeholder image
                    radius: 55,
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/profile/profile_male.jpg'), // Fallback image in case of error
                    radius: 55,
                  );
                } else {
                  GroupModel group = snapshot.data!;
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(group.pf_path),
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
                                            onTap: () {
                                              selectImage(true);
                                            },
                                            leading: Icon(Icons.camera_alt),
                                            title: Text('Camera'),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              selectImage(false);
                                            },
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
                  );
                }
              },
            ),
            SizedBox(
              height: 15,
            ),
            FutureBuilder<GroupModel>(
              future: groupFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading...");
                } else if (snapshot.hasError) {
                  return Text("Error");
                } else if (snapshot.hasData) {
                  GroupModel group = snapshot.data!;
                  return Text(
                    group.groupName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  );
                } else {
                  return Text("No name");
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.person_add_alt)),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF94D1CC),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text(
                        'FRIENDS',
                        style: TextStyle(letterSpacing: 2),
                      ),
                      trailing: Icon(Icons.arrow_forward_outlined),
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(Icons.photo),
                      title: Text(
                        'VIEW PHOTOS',
                        style: TextStyle(letterSpacing: 2),
                      ),
                      trailing: Icon(Icons.arrow_forward_outlined),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GroupChatPhotos(groupId: widget.groupId)));
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(Icons.search),
                      title: Text(
                        'SEARCH',
                        style: TextStyle(letterSpacing: 2),
                      ),
                      trailing: Icon(Icons.arrow_forward_outlined),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            // LoginButton(
            //   text: 'logout',
            //   onPressed: logout,
            // ),
            Padding(
              padding: EdgeInsets.only(left: 25, bottom: 15),
              child: ListTile(
                title: Text(
                  'LEAVE CHAT',
                  style: TextStyle(letterSpacing: 2),
                ),
                leading: Icon(Icons.logout),
                onTap: () {},
              ),
            ),
            SizedBox(
              height: 8,
            )
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
