import 'package:app_chat/auth/auth_service.dart';
import 'package:app_chat/chat/photo_service.dart';
import 'package:flutter/material.dart';

class ReceiverProfile extends StatefulWidget {
  final String receiverMail;
  final String receiverID;
  const ReceiverProfile(
      {super.key, required this.receiverMail, required this.receiverID});

  @override
  State<ReceiverProfile> createState() => _ReceiverProfileState();
}

class _ReceiverProfileState extends State<ReceiverProfile> {
  final AuthService _authService = AuthService();
  final PhotoService _photoService = PhotoService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
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
            FutureBuilder<Map<String, dynamic>>(
              future: _authService.getUserProfileAndStatus(widget
                  .receiverID), // Combine the future to get both profile URL and activity status
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
                  String profileUrl = snapshot.data!['profileUrl'];
                  bool isActive = snapshot.data!['isActive'];

                  return Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            profileUrl), // Load the profile image from the URL
                        radius: 55,
                      ),
                      if (isActive) // Show green circle only if the user is active
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 5,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 15,
            ),
            FutureBuilder<String>(
              future: _authService.getReceiverUsername(widget.receiverID),
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
            Text(widget.receiverMail, style: TextStyle(fontSize: 14)),
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
                      onTap: () {},
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
                title: Text('B L O C K'),
                leading: Icon(Icons.block),
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
}
