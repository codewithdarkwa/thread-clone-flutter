import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/src/panel.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';
import 'package:thread_clone_flutter/model/user.dart';
import 'package:thread_clone_flutter/widgets/thread_message.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({
    super.key,
    required this.message,
    required this.panelController,
    required this.threadId,
  });

  final ThreadMessage message;
  final PanelController panelController;
  final String threadId;
  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final CollectionReference threadCollection =
      FirebaseFirestore.instance.collection('threads');
  Stream<UserModel> fetchUserData(String id) {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(id).snapshots();
      return userDoc
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Thread',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ThreadMessageWidget(
                message: widget.message,
                onLike: () {},
                onDisLike: () {},
                onComment: () {},
                panelController: widget.panelController,
              ),
              StreamBuilder(
                stream: threadCollection.doc(widget.threadId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final comments = data['comments'];

                  if (comments == null) {
                    return const Text('');
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        DateTime timeStamp = DateTime.now();

                        if (comment.containsKey('time') &&
                            comment['time'] != null) {
                          timeStamp = (comment['time'] as Timestamp).toDate();
                        }
                        return StreamBuilder(
                            stream: fetchUserData(comment['id']),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              final user = snapshot.data!;

                              final message = ThreadMessage(
                                id: comment['id'],
                                senderName: user.name,
                                senderProfileImageUrl:
                                    user.profileImageUrl ?? "",
                                message: comment['text'],
                                timestamp: timeStamp,
                                likes: [],
                                comments: [],
                              );

                              return ThreadMessageWidget(
                                message: message,
                                onLike: () {},
                                onDisLike: () {},
                                onComment: () {},
                                panelController: widget.panelController,
                              );
                            });
                      });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
