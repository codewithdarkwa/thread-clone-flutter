import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:thread_clone_flutter/model/thread_message.dart';
import 'package:thread_clone_flutter/model/user.dart';
import 'package:thread_clone_flutter/screens/edit_profile.dart';
import 'package:thread_clone_flutter/screens/feed.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late Stream<UserModel> userStream;

  PanelController panelController = PanelController();

  bool isPanelOpen = false;
  Stream<UserModel> fetchUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
  }

  Stream<List<ThreadMessage>> fetchUserThreads(UserModel user) {
    return FirebaseFirestore.instance
        .collection('threads')
        .where('sender', isEqualTo: user.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final messageData = doc.data();
        final timestamp = (messageData['timestamp'] as Timestamp).toDate();
        return ThreadMessage(
          id: doc.id,
          senderName: messageData['sender'],
          senderProfileImageUrl: user.profileImageUrl ??
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU',
          message: messageData['message'],
          timestamp: timestamp,
        );
      }).toList();
    });
  }

  @override
  void initState() {
    userStream = fetchUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SlidingUpPanel(
          controller: panelController,
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panelBuilder: (ScrollController sc) {
            return StreamBuilder<UserModel>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final UserModel? user = snapshot.data;
                  if (user != null) {
                    return EditProfile(
                        panelController: panelController, user: user);
                  } else {
                    return const Center(
                      child: Text("No user"),
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          },
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: StreamBuilder<UserModel>(
                stream: userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    final UserModel? user = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(user?.name ?? ""),
                          subtitle: Text('@${user?.username ?? ""}'),
                          contentPadding: const EdgeInsets.all(0),
                          trailing: user?.profileImageUrl != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user?.profileImageUrl ?? ""),
                                  radius: 25,
                                )
                              : const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU',
                                  ),
                                  radius: 25,
                                ),
                        ),
                        Text(user?.bio ?? 'Bio needs to be here...'),
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
                                onTap: () {
                                  if (isPanelOpen) {
                                    panelController.close();
                                  } else {
                                    panelController.open();
                                  }
                                },
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
                                stream: fetchUserThreads(user!),
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
                                          senderProfileImageUrl: user
                                                  .profileImageUrl ??
                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU',
                                          message: messageData.message,
                                          timestamp: messageData.timestamp,
                                        );
                                        return ThreadMessageWidget(
                                            message: message);
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
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          )),
        ),
      ),
    );
  }
}
