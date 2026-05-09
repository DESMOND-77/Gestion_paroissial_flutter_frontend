import 'package:equatable/equatable.dart';

class Groupe extends Equatable {
  final int id;
  final String nom;
  final String? description;
  final int? responsable;
  final String? responsableNom;
  final String dateCreation;

  const Groupe({
    required this.id,
    required this.nom,
    this.description,
    this.responsable,
    this.responsableNom,
    required this.dateCreation,
  });

  factory Groupe.fromJson(Map<String, dynamic> json) {
    return Groupe(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      responsable: json['responsable'] as int?,
      responsableNom: json['responsable_nom'] as String?,
      dateCreation: json['date_creation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      if (description != null) 'description': description,
      if (responsable != null) 'responsable': responsable,
    };
  }

  Groupe copyWith({
    int? id,
    String? nom,
    String? description,
    int? responsable,
    String? responsableNom,
    String? dateCreation,
  }) {
    return Groupe(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      responsable: responsable ?? this.responsable,
      responsableNom: responsableNom ?? this.responsableNom,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  List<Object?> get props => [id, nom, description, responsable, responsableNom, dateCreation];
}
