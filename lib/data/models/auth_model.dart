import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isActive;
  final String profilePictureUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    required this.profilePictureUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      isStaff: json['is_staff'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      profilePictureUrl: json['profile_picture_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_active': isActive,
      'profile_picture_url': profilePictureUrl,
    };
  }

  AuthUser copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? isStaff,
    bool? isActive,
    String? profilePictureUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isStaff: isStaff ?? this.isStaff,
      isActive: isActive ?? this.isActive,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, isStaff, isActive, profilePictureUrl];
}

class LoginResponse extends Equatable {
  final String access;
  final String refresh;
  final AuthUser user;

  const LoginResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['tokens']['access'] as String? ?? '',
      refresh: json['tokens']['refresh'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [access, refresh, user];
}

class TokenRefreshResponse extends Equatable {
  final String access;

  const TokenRefreshResponse({required this.access});

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      access: json['tokens']['access'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [access];
}
