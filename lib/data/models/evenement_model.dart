import 'package:equatable/equatable.dart';

class Evenement extends Equatable {
  final int id;
  final String titre;
  final String type;
  final String? typeDisplay;
  final String? description;
  final String dateDebut;
  final String? dateFin;
  final String? lieu;
  final bool estInscriptionRequise;
  final int? createur;
  final String? createurNom;
  final int nbParticipants;

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
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      id: json['id'] as int? ?? 0,
      titre: json['titre'] as String? ?? '',
      type: json['type'] as String? ?? '',
      typeDisplay: json['type_display'] as String?,
      description: json['description'] as String?,
      dateDebut: json['date_debut'] as String? ?? '',
      dateFin: json['date_fin'] as String?,
      lieu: json['lieu'] as String?,
      estInscriptionRequise: json['est_inscription_requise'] as bool? ?? false,
      createur: json['createur'] as int?,
      createurNom: json['createur_nom'] as String?,
      nbParticipants: json['nb_participants'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'type': type,
      if (description != null) 'description': description,
      'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (lieu != null) 'lieu': lieu,
      'est_inscription_requise': estInscriptionRequise,
    };
  }

  Evenement copyWith({
    int? id,
    String? titre,
    String? type,
    String? typeDisplay,
    String? description,
    String? dateDebut,
    String? dateFin,
    String? lieu,
    bool? estInscriptionRequise,
    int? createur,
    String? createurNom,
    int? nbParticipants,
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
      ];
}
