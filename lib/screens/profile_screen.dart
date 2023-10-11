import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';
import 'package:thread_clone_flutter/screens/feed.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String userName = "";
  String fullName = "";

  Future<void> fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (mounted) {
        setState(() {
          userName = userDoc['username'];
          fullName = userDoc['name'];
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ThreadMessage>> fetchUserThreads() {
    return FirebaseFirestore.instance
        .collection('threads')
        .where('sender', isEqualTo: fullName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final messageData = doc.data();
        final timestamp = (messageData['timestamp'] as Timestamp).toDate();
        return ThreadMessage(
          id: doc.id,
          senderName: messageData['sender'],
          senderProfileImageUrl: 'assets/profile_1.jpeg',
          message: messageData['message'],
          timestamp: timestamp,
        );
      }).toList();
    });
  }

  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(fullName),
                subtitle: Text('@$userName'),
                contentPadding: const EdgeInsets.all(0),
                trailing: const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.png'),
                  radius: 25,
                ),
              ),
              const Text('Bio needs to be here...'),
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text(
                  '100 followers',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Edit profile'),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Share profile'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: 'Threads'),
                  Tab(text: 'Replies'),
                  Tab(text: 'Reposts'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder(
                      stream: fetchUserThreads(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final userThread = snapshot.data;
                          return ListView.builder(
                            itemCount: userThread!.length,
                            itemBuilder: (context, index) {
                              final messageData = userThread[index];
                              final message = ThreadMessage(
                                id: messageData.id,
                                senderName: messageData.senderName,
                                senderProfileImageUrl:
                                    messageData.senderProfileImageUrl,
                                message: messageData.message,
                                timestamp: messageData.timestamp,
                              );
                              return ThreadMessageWidget(message: message);
                            },
                          );
                        } else if (snapshot.hasError) {
                          Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    const Center(
                      child: Text('Your replies here'),
                    ),
                    const Center(
                      child: Text('Your reposts here'),
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
