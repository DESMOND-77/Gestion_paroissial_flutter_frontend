import 'package:equatable/equatable.dart';

class Sacrement extends Equatable {
  final String id;
  final String type;
  final String membre;
  final String date;
  final String? officiant;
  final String? officiantNom;
  final String? observations;

  const Sacrement({
    required this.id,
    required this.type,
    required this.membre,
    required this.date,
    this.officiant,
    this.officiantNom,
    this.observations,
  });

  String get typeLabel {
    const labels = {
      'bapteme': 'Baptême',
      'mariage': 'Mariage',
      'confirmation': 'Confirmation',
      'communion': 'Communion',
      'funerailles': 'Funérailles',
    };
    return labels[type] ?? type;
  }

  factory Sacrement.fromJson(Map<String, dynamic> json) {
    return Sacrement(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      membre: json['membre'] as String? ?? '',
      date: json['date'] as String? ?? '',
      officiant: json['officiant'] as String?,
      officiantNom: json['officiant_nom'] as String?,
      observations: json['observations'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'membre': membre,
      'date': date,
      if (officiant != null) 'officiant': officiant,
      if (observations != null) 'observations': observations,
    };
  }

  @override
  List<Object?> get props => [id, type, membre, date, officiant, observations];
}
