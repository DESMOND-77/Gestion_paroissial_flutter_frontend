import 'package:equatable/equatable.dart';
import 'sacrement_model.dart';

class Membre extends Equatable {
  final int id;
  final int? user;
  final String nom;
  final String prenom;
  final String nomComplet;
  final String? dateNaissance;
  final String sexe;
  final String? telephone;
  final String? email;
  final String? quartier;
  final String dateInscription;
  final bool estBaptise;
  final bool estConfirme;
  final int? groupe;
  final String? groupeNom;

  const Membre({
    required this.id,
    this.user,
    required this.nom,
    required this.prenom,
    required this.nomComplet,
    this.dateNaissance,
    required this.sexe,
    this.telephone,
    this.email,
    this.quartier,
    required this.dateInscription,
    required this.estBaptise,
    required this.estConfirme,
    this.groupe,
    this.groupeNom,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'] as int? ?? 0,
      user: json['user'] as int?,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      nomComplet: json['nom_complet'] as String? ?? '',
      dateNaissance: json['date_naissance'] as String?,
      sexe: json['sexe'] as String? ?? 'M',
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      quartier: json['quartier'] as String?,
      dateInscription: json['date_inscription'] as String? ?? '',
      estBaptise: json['est_baptise'] as bool? ?? false,
      estConfirme: json['est_confirme'] as bool? ?? false,
      groupe: json['groupe'] as int?,
      groupeNom: json['groupe_nom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (user != null) 'user': user,
      'nom': nom,
      'prenom': prenom,
      'nom_complet': nomComplet,
      if (dateNaissance != null) 'date_naissance': dateNaissance,
      'sexe': sexe,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      if (quartier != null) 'quartier': quartier,
      'date_inscription': dateInscription,
      'est_baptise': estBaptise,
      'est_confirme': estConfirme,
      if (groupe != null) 'groupe': groupe,
      if (groupeNom != null) 'groupe_nom': groupeNom,
    };
  }

  Membre copyWith({
    int? id,
    int? user,
    String? nom,
    String? prenom,
    String? nomComplet,
    String? dateNaissance,
    String? sexe,
    String? telephone,
    String? email,
    String? quartier,
    String? dateInscription,
    bool? estBaptise,
    bool? estConfirme,
    int? groupe,
    String? groupeNom,
  }) {
    return Membre(
      id: id ?? this.id,
      user: user ?? this.user,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      nomComplet: nomComplet ?? this.nomComplet,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      sexe: sexe ?? this.sexe,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      quartier: quartier ?? this.quartier,
      dateInscription: dateInscription ?? this.dateInscription,
      estBaptise: estBaptise ?? this.estBaptise,
      estConfirme: estConfirme ?? this.estConfirme,
      groupe: groupe ?? this.groupe,
      groupeNom: groupeNom ?? this.groupeNom,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        nom,
        prenom,
        nomComplet,
        dateNaissance,
        sexe,
        telephone,
        email,
        quartier,
        dateInscription,
        estBaptise,
        estConfirme,
        groupe,
        groupeNom,
      ];
}

class MembreDetail extends Membre {
  final List<Sacrement> sacrements;

  const MembreDetail({
    required super.id,
    super.user,
    required super.nom,
    required super.prenom,
    required super.nomComplet,
    super.dateNaissance,
    required super.sexe,
    super.telephone,
    super.email,
    super.quartier,
    required super.dateInscription,
    required super.estBaptise,
    required super.estConfirme,
    super.groupe,
    super.groupeNom,
    required this.sacrements,
  });

  factory MembreDetail.fromJson(Map<String, dynamic> json) {
    final base = Membre.fromJson(json);
    return MembreDetail(
      id: base.id,
      user: base.user,
      nom: base.nom,
      prenom: base.prenom,
      nomComplet: base.nomComplet,
      dateNaissance: base.dateNaissance,
      sexe: base.sexe,
      telephone: base.telephone,
      email: base.email,
      quartier: base.quartier,
      dateInscription: base.dateInscription,
      estBaptise: base.estBaptise,
      estConfirme: base.estConfirme,
      groupe: base.groupe,
      groupeNom: base.groupeNom,
      sacrements: (json['sacrements'] as List<dynamic>?)
              ?.map((s) => Sacrement.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [...super.props, sacrements];
}
