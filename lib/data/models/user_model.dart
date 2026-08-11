import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? avatarPath;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarPath,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      avatarPath: map['avatar_path'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar_path': avatarPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({String? name, String? phone, String? avatarPath}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone];
}

class AddressModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String fullAddress;
  final String? extra;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullAddress,
    this.extra,
    required this.isDefault,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      fullAddress: map['full_address'] as String,
      extra: map['extra'] as String?,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'full_address': fullAddress,
      'extra': extra,
      'is_default': isDefault ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, userId, title, fullAddress];
}
