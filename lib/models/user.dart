class User {
  final int? id;
  final String email;
  final String password;
  String? avatarUrl;

  User({this.id, required this.email, required this.password, this.avatarUrl});

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'password': password,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        email: map['email'],
        password: map['password'],
      );

  // Add a method to update avatar URL
  void updateAvatarUrl(String? url) {
    avatarUrl = url;
  }
}
