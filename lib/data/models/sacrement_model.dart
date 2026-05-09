import 'package:equatable/equatable.dart';

class Sacrement extends Equatable {
  final int id;
  final String type;
  final int membre;
  final String date;
  final int? officiant;
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
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      membre: json['membre'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      officiant: json['officiant'] as int?,
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
