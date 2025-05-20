class User {
  final int? id;
  final String email;
  final String password;

  User({this.id, required this.email, required this.password});

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
}
