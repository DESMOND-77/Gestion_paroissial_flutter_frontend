import 'package:equatable/equatable.dart';

class Groupe extends Equatable {
  final String id;
  final String nom;
  final String? description;
  final String? responsable;
  final String? responsableNom;
  // Multi-responsables : ids + noms fournis par le backend (id -> nom).
  final List<String> responsables;
  final Map<String, String> responsablesNoms;
  final String dateCreation;

  const Groupe({
    required this.id,
    required this.nom,
    this.description,
    this.responsable,
    this.responsableNom,
    this.responsables = const [],
    this.responsablesNoms = const {},
    required this.dateCreation,
  });

  static List<String> _stringList(dynamic v) =>
      (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];

  static Map<String, String> _stringMap(dynamic v) =>
      (v as Map<dynamic, dynamic>?)
          ?.map((k, val) => MapEntry(k.toString(), val.toString())) ??
      const {};

  factory Groupe.fromJson(Map<String, dynamic> json) {
    return Groupe(
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      responsable: json['responsable'] as String?,
      responsableNom: json['responsable_nom'] as String?,
      responsables: _stringList(json['responsables']),
      responsablesNoms: _stringMap(json['responsables_noms']),
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
      'responsables': responsables,
      'date_creation': dateCreation,
    };
  }

  Groupe copyWith({
    String? id,
    String? nom,
    String? description,
    String? responsable,
    String? responsableNom,
    List<String>? responsables,
    Map<String, String>? responsablesNoms,
    String? dateCreation,
  }) {
    return Groupe(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      responsable: responsable ?? this.responsable,
      responsableNom: responsableNom ?? this.responsableNom,
      responsables: responsables ?? this.responsables,
      responsablesNoms: responsablesNoms ?? this.responsablesNoms,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        description,
        responsable,
        responsableNom,
        responsables,
        responsablesNoms,
        dateCreation,
      ];
}
