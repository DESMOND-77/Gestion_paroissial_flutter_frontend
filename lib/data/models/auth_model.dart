import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final bool isActive;
  final String profilePictureUrl;
  final String phoneNumber;

  /// Rôle métier (accounts.User.role) : fidele, responsable, secretaire,
  /// tresorier, pretre, admin. Base du contrôle d'affichage UI (voir
  /// core/auth/permissions.dart).
  final String role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.isActive,
    required this.profilePictureUrl,
    this.phoneNumber = '',
    this.role = 'fidele',
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: (json['first_name'] ?? json['prenom']) as String? ?? '',
      lastName: (json['last_name'] ?? json['nom']) as String? ?? '',
      isStaff: json['is_staff'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      profilePictureUrl: json['profile_picture_url'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      role: json['role'] as String? ?? 'fidele',
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
      'phone_number': phoneNumber,
      'role': role,
    };
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? isStaff,
    bool? isActive,
    String? profilePictureUrl,
    String? phoneNumber,
    String? role,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isStaff: isStaff ?? this.isStaff,
      isActive: isActive ?? this.isActive,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        isStaff,
        isActive,
        profilePictureUrl,
        phoneNumber,
        role,
      ];
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
