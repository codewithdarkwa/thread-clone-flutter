import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  final String id;
  final String name;
  final String username;
  final String? profileImageUrl;
  final String? bio;
  final String? link;
  final List following;
  final List followers;
  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.followers,
    required this.following,
    this.profileImageUrl,
    this.bio,
    this.link,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'link': link,
      'following': following,
      'followers': followers
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'] as String,
        name: map['name'] as String,
        username: map['username'] as String,
        profileImageUrl: map['profileImageUrl'] != null
            ? map['profileImageUrl'] as String
            : null,
        bio: map['bio'] != null ? map['bio'] as String : null,
        link: map['link'] != null ? map['link'] as String : null,
        followers: List.from((map['followers'] as List)),
        following: List.from((map['following'] as List)));
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
