import 'package:equatable/equatable.dart';

class UserActivity extends Equatable {
  final int id;
  final String userEmail;
  final String userFullName;
  final String action;
  final String? actionDisplay;
  final String? details;
  final String? ipAddress;
  final String timestamp;

  const UserActivity({
    required this.id,
    required this.userEmail,
    required this.userFullName,
    required this.action,
    this.actionDisplay,
    this.details,
    this.ipAddress,
    required this.timestamp,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as int? ?? 0,
      userEmail: json['user_email'] as String? ?? '',
      userFullName: json['user_full_name'] as String? ?? '',
      action: json['action'] as String? ?? '',
      actionDisplay: json['action_display'] as String?,
      details: json['details'] as String?,
      ipAddress: json['ip_address'] as String?,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  String get actionLabel {
    const labels = {
      'login': 'Connexion',
      'logout': 'Déconnexion',
      'create': 'Création',
      'update': 'Modification',
      'delete': 'Suppression',
      'view': 'Consultation',
    };
    return actionDisplay ?? labels[action] ?? action;
  }

  @override
  List<Object?> get props => [id, userEmail, userFullName, action, details, ipAddress, timestamp];
}
