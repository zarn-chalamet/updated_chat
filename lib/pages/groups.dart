import 'package:app_chat/utils/drawer.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

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
    );
  }
}
