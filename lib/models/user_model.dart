class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String ktm;
  final String profilePicture;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.ktm,
    required this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'ktm': ktm,
      'profilePicture': profilePicture,
    };
  }

  factory UserModel.fromFirebase(String uid, Map<dynamic, dynamic> json) {
    return UserModel(
      uid: uid,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      ktm: (json['ktm'] ?? '').toString(),
      profilePicture: (json['profilePicture'] ?? '').toString(),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? ktm,
    String? profilePicture,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      ktm: ktm ?? this.ktm,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
