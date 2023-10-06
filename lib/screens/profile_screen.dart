import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              const ListTile(
                title: Text('CodeWithDarkwa'),
                subtitle: Text('@codewithdarkwa'),
                contentPadding: EdgeInsets.all(0),
                trailing: CircleAvatar(
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
              const Expanded(
                child: TabBarView(
                  children: [
                    Center(
                      child: Text('Your threads here'),
                    ),
                    Center(
                      child: Text('Your replies here'),
                    ),
                    Center(
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
