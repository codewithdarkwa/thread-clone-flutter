import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thread_clone_flutter/model/user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final userId = FirebaseAuth.instance.currentUser!.uid;

  String searchQuery = "";
  final searchController = TextEditingController();
  List<UserModel> searchUsers(List<UserModel> users, String query) {
    return users.where((user) {
      return user.username.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<void> followUser(UserModel user) async {
    await userCollection.doc(userId).update({
      'following': FieldValue.arrayUnion([user.id])
    });
    await userCollection.doc(user.id).update({
      'followers': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> unFollowUser(UserModel user) async {
    await userCollection.doc(userId).update({
      'following': FieldValue.arrayRemove([user.id])
    });
    await userCollection.doc(user.id).update({
      'followers': FieldValue.arrayRemove([userId])
    });
  }

  @override
  void initState() {
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: userCollection
                      .where('id', isNotEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final users = snapshot.data!.docs;

                    final allUsers = users.map((doc) {
                      final user = doc.data() as Map<String, dynamic>;
                      return UserModel(
                        id: user['id'],
                        username: user['username'],
                        profileImageUrl: user['profileImageUrl'],
                        name: user['name'],
                        followers: [],
                        following: [],
                      );
                    }).toList();
                    final filteredUsers = searchUsers(allUsers, searchQuery);
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (contex, index) {
                        final user = filteredUsers[index];

                        return SuggestedFollowerWidget(
                          user: user,
                          follow: () => followUser(user),
                          unFollow: () => unFollowUser(user),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuggestedFollowerWidget extends StatefulWidget {
  const SuggestedFollowerWidget({
    super.key,
    required this.user,
    required this.follow,
    required this.unFollow,
  });

  final UserModel user;
  final VoidCallback follow;
  final VoidCallback unFollow;

  @override
  State<SuggestedFollowerWidget> createState() =>
      _SuggestedFollowerWidgetState();
}

class _SuggestedFollowerWidgetState extends State<SuggestedFollowerWidget> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.user.profileImageUrl ??
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU"),
            backgroundColor: Colors.white,
          ),
          title: Text(widget.user.username),
          subtitle: Text(widget.user.username.toLowerCase()),
          trailing: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final currentUser = UserModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>);
                final isFollowing =
                    currentUser.following.contains(widget.user.id);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: isFollowing ? widget.unFollow : widget.follow,
                      child: Container(
                        alignment: Alignment.center,
                        width: 110,
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isFollowing
                            ? const Text(
                                'Following',
                                style: TextStyle(color: Colors.grey),
                              )
                            : const Text('Follow'),
                      ),
                    )
                  ],
                );
              }),
        ),
        const Divider(),
      ],
    );
  }
}
