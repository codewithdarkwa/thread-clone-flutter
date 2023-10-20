import 'package:flutter/material.dart';
import 'package:sliding_up_panel/src/panel.dart';
import 'package:thread_clone_flutter/model/user.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(
      {super.key, required this.panelController, required this.user});

  final PanelController panelController;
  final UserModel? user;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Name'),
                      subtitle: const Text('username'),
                      trailing: InkWell(
                        onTap: () {},
                        child: const CircleAvatar(
                          backgroundImage: AssetImage('assets/profile.png'),
                          radius: 20,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Bio'),
                      subtitle: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Bio needs to be here...',
                          hintStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Link'),
                      subtitle: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'youtube.com/@codewithdarkwa',
                          hintStyle: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Private profile'),
                          Switch(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value;
                              });
                            },
                            activeColor: Colors.black,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
