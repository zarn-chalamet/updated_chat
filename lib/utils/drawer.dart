import 'package:app_chat/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void logout() {
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.pushNamed(context, '/profile');
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 30, left: 20),
              //     child: CircleAvatar(
              //       backgroundImage:
              //           AssetImage('assets/profile/profile_male.jpg'),
              //       radius: 23,
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 30, right: 20),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/setting');
                    },
                    icon: const Icon(
                      Icons.settings,
                      size: 40,
                    )),
              ),
            ],
          ),
          const SizedBox(
            height: 100,
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('C H A T'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 25, bottom: 15),
            child: ListTile(
              title: Text('L O G O U T'),
              leading: Icon(Icons.logout_outlined),
              onTap: logout,
            ),
          )
        ],
      ),
    );
  }
}
