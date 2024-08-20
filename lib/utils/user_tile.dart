import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final String lastMessage;
  final String profileUrl;
  final Timestamp timestamp;
  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    required this.lastMessage,
    required this.profileUrl,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 215, 244, 239),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 25,
              ),
              padding: EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profileUrl),
                  radius: 28,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    text,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    lastMessage,
                    maxLines: 1, // Restrict to one line
                    overflow: TextOverflow
                        .ellipsis, // Show ellipsis if text overflows)
                  ),
                ),
                // trailing: Column(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   children: [
                //     Text(formattedTime),
                //   ],
                // ),
              ),
            ),
            Positioned(
              top: 25,
              right: 45,
              child: Text(
                formattedTime,
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ));
  }
}
