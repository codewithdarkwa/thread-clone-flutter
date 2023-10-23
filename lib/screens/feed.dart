import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                            timestamp = (messageData['timestamp'] as Timestamp)
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
                                    likes: messageData['likes'] ?? []);
                                return ThreadMessageWidget(
                                  message: message,
                                  onDisLike: () =>
                                      dislikeThreadMessage(messages[index].id),
                                  onLike: () =>
                                      likeThreadMessage(messages[index].id),
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

class ThreadMessageWidget extends StatelessWidget {
  ThreadMessageWidget({
    super.key,
    required this.message,
    required this.onLike,
    required this.onDisLike,
  });

  final ThreadMessage message;
  final void Function() onLike;
  final void Function() onDisLike;

  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(message.senderProfileImageUrl),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        message.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(_getTimeDifference(message.timestamp)),
                      IconButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.more_horiz),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.message),
                      Row(
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (message.likes.contains(userId)) {
                                    onDisLike();
                                  } else {
                                    onLike();
                                  }
                                },
                                icon: message.likes.contains(userId)
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.favorite_outline,
                                      ),
                              ),
                              Text(
                                message.likes.isEmpty
                                    ? ''
                                    : message.likes.length.toString(),
                              )
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.mode_comment_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/retweet.png',
                              width: 25,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/send.png',
                              width: 25,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        const Divider()
      ],
    );
  }

  String _getTimeDifference(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr';
    } else {
      return '${difference.inDays} day';
    }
  }
}
