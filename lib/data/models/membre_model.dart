import 'package:equatable/equatable.dart';
import 'sacrement_model.dart';

class Membre extends Equatable {
  final String id;
  final String? user;
  final String nom;
  final String prenom;
  final String nomComplet;
  final String? dateNaissance;
  final String sexe;
  final String? telephone;
  final String? email;
  final String? profilePictureUrl;
  final String? quartier;
  final String dateInscription;
  final bool estBaptise;
  final bool estConfirme;
  final String? groupe;
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
    this.profilePictureUrl,
    this.quartier,
    required this.dateInscription,
    required this.estBaptise,
    required this.estConfirme,
    this.groupe,
    this.groupeNom,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'] as String? ?? '',
      user: json['user'] as String?,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      nomComplet: json['nom_complet'] as String? ?? '',
      dateNaissance: json['date_naissance'] as String?,
      sexe: json['sexe'] as String? ?? 'M',
      // Le backend expose le téléphone sous `phone_number` (source
      // `user.phone_number`) ; `telephone` gardé en repli/compat.
      telephone: (json['phone_number'] ?? json['telephone']) as String?,
      email: json['email'] as String?,
      // Photo de profil du compte `user` associé (source backend
      // `user.profile_picture`).
      profilePictureUrl: json['profile_picture_url'] as String?,
      quartier: json['quartier'] as String?,
      dateInscription: json['date_inscription'] as String? ?? '',
      estBaptise: json['est_baptise'] as bool? ?? false,
      estConfirme: json['est_confirme'] as bool? ?? false,
      groupe: json['groupe'] as String?,
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
      if (telephone != null) 'phone_number': telephone,
      if (email != null) 'email': email,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (quartier != null) 'quartier': quartier,
      'date_inscription': dateInscription,
      'est_baptise': estBaptise,
      'est_confirme': estConfirme,
      if (groupe != null) 'groupe': groupe,
      if (groupeNom != null) 'groupe_nom': groupeNom,
    };
  }

  Membre copyWith({
    String? id,
    String? user,
    String? nom,
    String? prenom,
    String? nomComplet,
    String? dateNaissance,
    String? sexe,
    String? telephone,
    String? email,
    String? profilePictureUrl,
    String? quartier,
    String? dateInscription,
    bool? estBaptise,
    bool? estConfirme,
    String? groupe,
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
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
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
        profilePictureUrl,
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
    super.profilePictureUrl,
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
      profilePictureUrl: base.profilePictureUrl,
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
