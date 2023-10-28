import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';
import 'package:thread_clone_flutter/screens/comment_screen.dart';
import 'package:thread_clone_flutter/screens/post_comment_screen.dart';
import 'package:thread_clone_flutter/widgets/thread_message.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final CollectionReference threadCollection =
      FirebaseFirestore.instance.collection('threads');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<String> getSenderImageUrl(String id) async {
    final userDoc = await userCollection.doc(id).get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['profileImageUrl'] ??
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU";
    } else {
      return '';
    }
  }

  PanelController panelController = PanelController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SlidingUpPanel(
          controller: panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) {
            return const PostCommentScreen();
          },
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      "assets/thread_logo.png",
                      width: 30,
                    ),
                  ),
                  StreamBuilder(
                      stream: threadCollection.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          Center(
                            child: Text(' error : ${snapshot.error}'),
                          );
                        }
                        final messages = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final messageData =
                                messages[index].data() as Map<String, dynamic>;

                            DateTime timestamp = DateTime.now();
                            if (messageData.containsKey('timestamp') &&
                                messageData['timestamp'] != null) {
                              timestamp =
                                  (messageData['timestamp'] as Timestamp)
                                      .toDate();
                            }

                            return FutureBuilder(
                                future: getSenderImageUrl(messageData['id']),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Text('');
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  final message = ThreadMessage(
                                    id: messageData['id'],
                                    senderName: messageData['sender'],
                                    senderProfileImageUrl: snapshot.data ?? "",
                                    message: messageData['message'],
                                    timestamp: timestamp,
                                    likes: messageData['likes'] ?? [],
                                    comments: messageData['comments'] ?? [],
                                  );
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommentScreen(
                                              message: message,
                                              panelController: panelController),
                                        ),
                                      );
                                    },
                                    child: ThreadMessageWidget(
                                      message: message,
                                      onDisLike: () => dislikeThreadMessage(
                                          messages[index].id),
                                      onLike: () =>
                                          likeThreadMessage(messages[index].id),
                                      onComment: () {},
                                      panelController: panelController,
                                    ),
                                  );
                                });
                          },
                        );
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> likeThreadMessage(String id) async {
    try {
      threadCollection.doc(id).update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> dislikeThreadMessage(String id) async {
    try {
      threadCollection.doc(id).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
