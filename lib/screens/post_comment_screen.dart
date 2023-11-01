import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/src/panel.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';
import 'package:thread_clone_flutter/model/user.dart';

class PostCommentScreen extends StatefulWidget {
  const PostCommentScreen(
      {super.key, required this.threadDoc, required this.panelController});

  final String threadDoc;
  final PanelController panelController;
  @override
  State<PostCommentScreen> createState() => _PostCommentScreenState();
}

class _PostCommentScreenState extends State<PostCommentScreen> {
  final commentController = TextEditingController();
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference threadCollection =
      FirebaseFirestore.instance.collection('threads');

  final currentUser = FirebaseAuth.instance.currentUser;

  Future<UserModel> fetchUserData() async {
    try {
      final userDoc = await userCollection.doc(currentUser!.uid).get();
      final user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<ThreadMessage> getSenderDetails() async {
    try {
      final senderDoc = await threadCollection.doc(widget.threadDoc).get();
      if (!senderDoc.exists) {
        return ThreadMessage.empty();
      }

      final senderData = senderDoc.data() as Map<String, dynamic>;
      final senderName = senderData['sender'] as String;
      final message = senderData['message'] as String;
      final id = senderData['id'] as String;

      final userDoc = await userCollection.doc(id).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final imageUrl = userData['profileImageUrl'] as String;
      return ThreadMessage(
        id: id,
        senderName: senderName,
        senderProfileImageUrl: imageUrl,
        message: message,
        timestamp: DateTime.now(),
        likes: [],
        comments: [],
      );
    } catch (e) {
      debugPrint('Error fetching sender details: ${e.toString()}');
      return ThreadMessage.empty();
    }
  }

  Future<void> postComment() async {
    try {
      await threadCollection.doc(widget.threadDoc).update({
        'comments': FieldValue.arrayUnion([
          {
            'id': currentUser!.uid,
            'text': commentController.text,
            'time': Timestamp.now().toDate()
          }
        ])
      });
      commentController.clear();
      widget.panelController.close();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  widget.panelController.close();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'Reply',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              TextButton(
                onPressed: postComment,
                child: const Text(
                  'Post',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1),
        Column(
          children: [
            FutureBuilder(
              future: getSenderDetails(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final sender = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(sender!.senderProfileImageUrl),
                      ),
                      title: Text(
                        sender.senderName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        sender.message,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          color: Colors.grey[400],
                          width: 5,
                          thickness: 1.5,
                          indent: 0,
                          endIndent: 0,
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future: fetchUserData(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final user = snapshot.data;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(user?.profileImageUrl ?? ""),
                            ),
                            title: Text(
                              user?.username ?? "",
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: TextFormField(
                              controller: commentController,
                              decoration: InputDecoration(
                                  hintText: 'Reply to ${sender.senderName}',
                                  hintStyle: const TextStyle(fontSize: 13),
                                  border: InputBorder.none),
                            ),
                          );
                        }),
                  ],
                );
              },
            )
          ],
        )
      ],
    );
  }
}
