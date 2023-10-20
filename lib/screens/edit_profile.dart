import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final bioController = TextEditingController();
  final linkController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isChecked = false;

  String profileImageUrl = "";

  Future<void> updateUserProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .set({
        'bio': bioController.text,
        'link': linkController.text,
        'profileImageUrl': profileImageUrl
      }, SetOptions(merge: true));

      widget.panelController.close();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${currentUser!.uid}.jpg');
      try {
        final upload = storageRef.putFile(file);
        final snaphot = await upload.whenComplete(() {});
        final downloadUrl = await snaphot.ref.getDownloadURL();

        setState(() {
          profileImageUrl = downloadUrl;
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  void initState() {
    profileImageUrl = widget.user?.profileImageUrl ??
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz8cLf8-P2P8GZ0-KiQ-OXpZQ4bebpa3K3Dw&usqp=CAU";

    bioController.text = widget.user?.bio ?? "";
    linkController.text = widget.user?.link ?? "";
    super.initState();
  }

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
                  onPressed: updateUserProfile,
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
                      subtitle: Text(
                          '${widget.user?.name} (@${widget.user?.username})'),
                      trailing: InkWell(
                        onTap: uploadImage,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(profileImageUrl),
                          radius: 20,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Bio'),
                      subtitle: TextFormField(
                        controller: bioController,
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
                        controller: linkController,
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
