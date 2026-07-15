import 'package:equatable/equatable.dart';

class Evenement extends Equatable {
  final String id;
  final String titre;
  final String type;
  final String? typeDisplay;
  final String? description;
  final String dateDebut;
  final String? dateFin;
  final String? lieu;
  final bool estInscriptionRequise;
  final String? createur;
  final String? createurNom;
  final int nbParticipants;

  // Conviés (convocations)
  final bool inviteTous;
  final List<String> rolesInvites;
  final List<String> groupesInvites;
  final List<String> membresInvites;
  // Noms fournis par le backend pour l'affichage (id -> nom).
  final Map<String, String> groupesInvitesNoms;
  final Map<String, String> membresInvitesNoms;
  final bool estPasse;

  const Evenement({
    required this.id,
    required this.titre,
    required this.type,
    this.typeDisplay,
    this.description,
    required this.dateDebut,
    this.dateFin,
    this.lieu,
    required this.estInscriptionRequise,
    this.createur,
    this.createurNom,
    required this.nbParticipants,
    this.inviteTous = false,
    this.rolesInvites = const [],
    this.groupesInvites = const [],
    this.membresInvites = const [],
    this.groupesInvitesNoms = const {},
    this.membresInvitesNoms = const {},
    this.estPasse = false,
  });

  static List<String> _stringList(dynamic v) =>
      (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];

  static Map<String, String> _stringMap(dynamic v) =>
      (v as Map<dynamic, dynamic>?)
          ?.map((k, val) => MapEntry(k.toString(), val.toString())) ??
      const {};

  // Repli hors ligne si le backend n'a pas fourni `est_passe`.
  static bool _computePasse(String dateDebut, String? dateFin) {
    final ref = DateTime.tryParse(dateFin ?? dateDebut);
    if (ref == null) return false;
    return ref.isBefore(DateTime.now());
  }

  factory Evenement.fromJson(Map<String, dynamic> json) {
    final dateDebut = json['date_debut'] as String? ?? '';
    final dateFin = json['date_fin'] as String?;
    return Evenement(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      type: json['type'] as String? ?? '',
      typeDisplay: json['type_display'] as String?,
      description: json['description'] as String?,
      dateDebut: dateDebut,
      dateFin: dateFin,
      lieu: json['lieu'] as String?,
      estInscriptionRequise: json['est_inscription_requise'] as bool? ?? false,
      createur: json['createur'] as String?,
      createurNom: json['createur_nom'] as String?,
      nbParticipants: json['nb_participants'] as int? ?? 0,
      inviteTous: json['invite_tous'] as bool? ?? false,
      rolesInvites: _stringList(json['roles_invites']),
      groupesInvites: _stringList(json['groupes_invites']),
      membresInvites: _stringList(json['membres_invites']),
      groupesInvitesNoms: _stringMap(json['groupes_invites_noms']),
      membresInvitesNoms: _stringMap(json['membres_invites_noms']),
      estPasse: json['est_passe'] as bool? ?? _computePasse(dateDebut, dateFin),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'type': type,
      if (typeDisplay != null) 'type_display': typeDisplay,
      if (description != null) 'description': description,
      'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (lieu != null) 'lieu': lieu,
      'est_inscription_requise': estInscriptionRequise,
      if (createur != null) 'createur': createur,
      if (createurNom != null) 'createur_nom': createurNom,
      'nb_participants': nbParticipants,
      'invite_tous': inviteTous,
      'roles_invites': rolesInvites,
      'groupes_invites': groupesInvites,
      'membres_invites': membresInvites,
      'est_passe': estPasse,
    };
  }

  Evenement copyWith({
    String? id,
    String? titre,
    String? type,
    String? typeDisplay,
    String? description,
    String? dateDebut,
    String? dateFin,
    String? lieu,
    bool? estInscriptionRequise,
    String? createur,
    String? createurNom,
    int? nbParticipants,
    bool? inviteTous,
    List<String>? rolesInvites,
    List<String>? groupesInvites,
    List<String>? membresInvites,
    Map<String, String>? groupesInvitesNoms,
    Map<String, String>? membresInvitesNoms,
    bool? estPasse,
  }) {
    return Evenement(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      type: type ?? this.type,
      typeDisplay: typeDisplay ?? this.typeDisplay,
      description: description ?? this.description,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      lieu: lieu ?? this.lieu,
      estInscriptionRequise: estInscriptionRequise ?? this.estInscriptionRequise,
      createur: createur ?? this.createur,
      createurNom: createurNom ?? this.createurNom,
      nbParticipants: nbParticipants ?? this.nbParticipants,
      inviteTous: inviteTous ?? this.inviteTous,
      rolesInvites: rolesInvites ?? this.rolesInvites,
      groupesInvites: groupesInvites ?? this.groupesInvites,
      membresInvites: membresInvites ?? this.membresInvites,
      groupesInvitesNoms: groupesInvitesNoms ?? this.groupesInvitesNoms,
      membresInvitesNoms: membresInvitesNoms ?? this.membresInvitesNoms,
      estPasse: estPasse ?? this.estPasse,
    );
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final eventDate = DateTime.tryParse(dateDebut);
    if (eventDate == null) return false;
    return eventDate.isAfter(now);
  }

  @override
  List<Object?> get props => [
        id,
        titre,
        type,
        typeDisplay,
        description,
        dateDebut,
        dateFin,
        lieu,
        estInscriptionRequise,
        createur,
        createurNom,
        nbParticipants,
        inviteTous,
        rolesInvites,
        groupesInvites,
        membresInvites,
        groupesInvitesNoms,
        membresInvitesNoms,
        estPasse,
      ];
}
