import 'dart:io';

import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:app_chat/utils/snack_bar.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();

  File? finalFileImage;
  String userImage = '';

  void selectImage(bool fromCamera) async {
    finalFileImage = await _photoService.pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    Navigator.pop(context);
    await _photoService.saveImageToFireStore(
        finalFileImage!, _authService.getCurrentUserID());

    String newProfileUrl = await _loadUserProfile();
    setState(() {
      userImage = newProfileUrl.isNotEmpty ? newProfileUrl : userImage;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profile()),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    String profileUrl = await _loadUserProfile();
    setState(() {
      userImage = profileUrl.isNotEmpty
          ? profileUrl
          : "https://firebasestorage.googleapis.com/v0/b/app-chat-97ecb.appspot.com/o/Profiles%2Fprofile_image.jpg?alt=media&token=6ffca4f1-2e1c-4d5c-950b-0e1bd7b2076c";
    });
  }

  Future<String> _loadUserProfile() async {
    try {
      String userId = _authService.getCurrentUserID();
      String profileUrl = await _photoService.getProfileUrl(userId);

      return profileUrl;
    } catch (e) {
      // Handle errors here, e.g., show an error message
      print('Error loading profile: $e');
      return '';
    }
  }

  Future<void> logout() async {
    try {
      print("++++++++++++++++++++++++++++++++++++++++++++++++++++");
      print(_authService.getCurrentUserID());
      print("++++++++++++++++++++++++++++++++++++++++++++++++++++");

      await _authService.signOut();
      Navigator.pushReplacementNamed(context, "/authgate");
      // Assuming signOut method is implemented in AuthService
    } catch (e) {
      // Handle errors here, e.g., show an error message
      print('Error during logout: $e');
      showSnackBar(context, 'Failed to logout. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
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
                                height: MediaQuery.of(context).size.height / 5,
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
            ),
            SizedBox(
              height: 15,
            ),
            FutureBuilder<String>(
              future: _authService.getCurrentUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading...");
                } else if (snapshot.hasError) {
                  return Text("Error");
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  );
                } else {
                  return Text("No name");
                }
              },
            ),
            SizedBox(
              height: 5,
            ),
            Text(_authService.getCurrentUserEmail(),
                style: TextStyle(fontSize: 14)),
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
                      leading: Icon(Icons.question_mark_outlined),
                      title: Text(
                        'ACTIVE STAUS',
                        style: TextStyle(letterSpacing: 2),
                      ),
                      trailing: Icon(Icons.arrow_forward_outlined),
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(Icons.dark_mode),
                      title: Text(
                        'DARK MODE',
                        style: TextStyle(letterSpacing: 2),
                      ),
                      trailing: Icon(Icons.arrow_forward_outlined),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/setting');
                      },
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
                title: Text('L O G O U T'),
                leading: Icon(Icons.logout_outlined),
                onTap: () async {
                  await logout();
                },
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
}
