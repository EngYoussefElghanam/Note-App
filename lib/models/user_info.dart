class UserData {
  final String name;
  final String email;
  final String id;
  final String createdAt;
  final bool isPremium;
  final String? imgUrl;

  var cachedImage;

  UserData({
    required this.name,
    required this.email,
    required this.id,
    required this.createdAt,
    this.isPremium = false,
    this.imgUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'id': id,
      'createdAt': createdAt,
      'isPremium': isPremium,
      'imgUrl': imgUrl,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] as String,
      email: map['email'] as String,
      id: map['id'] as String,
      createdAt: map['createdAt'] as String,
      isPremium: map['isPremium'] as bool,
      imgUrl: map['imgUrl'] != null ? map['imgUrl'] as String : null,
    );
  }

  UserData copyWith({
    String? name,
    String? email,
    String? id,
    String? createdAt,
    bool? isPremium,
    String? imgUrl,
  }) {
    return UserData(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }
}
