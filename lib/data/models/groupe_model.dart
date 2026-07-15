import 'package:equatable/equatable.dart';

class Groupe extends Equatable {
  final String id;
  final String nom;
  final String? description;
  final String? responsable;
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
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      responsable: json['responsable'] as String?,
      responsableNom: json['responsable_nom'] as String?,
      dateCreation: json['date_creation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      if (description != null) 'description': description,
      if (responsable != null) 'responsable': responsable,
      if (responsableNom != null) 'responsable_nom': responsableNom,
      'date_creation': dateCreation,
    };
  }

  Groupe copyWith({
    String? id,
    String? nom,
    String? description,
    String? responsable,
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
