import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final String type;
  final String categorie;
  final double montant;
  final String? description;
  final String date;
  final int? membre;
  final String? membreNom;
  final int? enregistrePar;
  final String? enregistreParNom;

  const Transaction({
    required this.id,
    required this.type,
    required this.categorie,
    required this.montant,
    this.description,
    required this.date,
    this.membre,
    this.membreNom,
    this.enregistrePar,
    this.enregistreParNom,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      categorie: json['categorie'] as String? ?? '',
      montant: (json['montant'] is String
                  ? double.tryParse(json['montant'] as String)
                  : json['montant'] as num?)
              ?.toDouble() ??
          0.0,
      description: json['description'] as String?,
      date: json['date'] as String? ?? '',
      membre: json['membre'] as int?,
      membreNom: json['membre_nom'] as String?,
      enregistrePar: json['enregistre_par'] as int?,
      enregistreParNom: json['enregistre_par_nom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'categorie': categorie,
      'montant': montant,
      if (description != null) 'description': description,
      'date': date,
      if (membre != null) 'membre': membre,
    };
  }

  String get typeLabel {
    const labels = {'recette': 'Recette', 'depense': 'Dépense'};
    return labels[type] ?? type;
  }

  String get categorieLabel {
    const labels = {
      'quete': 'Quête',
      'don': 'Don',
      'location': 'Location',
      'librairie': 'Librairie',
      'autre': 'Autre',
    };
    return labels[categorie] ?? categorie;
  }

  bool get isRecette => type == 'recette';

  Transaction copyWith({
    int? id,
    String? type,
    String? categorie,
    double? montant,
    String? description,
    String? date,
    int? membre,
    String? membreNom,
    int? enregistrePar,
    String? enregistreParNom,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      categorie: categorie ?? this.categorie,
      montant: montant ?? this.montant,
      description: description ?? this.description,
      date: date ?? this.date,
      membre: membre ?? this.membre,
      membreNom: membreNom ?? this.membreNom,
      enregistrePar: enregistrePar ?? this.enregistrePar,
      enregistreParNom: enregistreParNom ?? this.enregistreParNom,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        categorie,
        montant,
        description,
        date,
        membre,
        membreNom,
        enregistrePar,
        enregistreParNom,
      ];
}

class RapportFinancier extends Equatable {
  final double totalRecettes;
  final double totalDepenses;
  final double balance;
  final Map<String, double> parCategorie;
  final List<Map<String, dynamic>> parMois;

  const RapportFinancier({
    required this.totalRecettes,
    required this.totalDepenses,
    required this.balance,
    required this.parCategorie,
    required this.parMois,
  });

  factory RapportFinancier.fromJson(Map<String, dynamic> json) {
    final parCategorie = <String, double>{};
    if (json['par_categorie'] is Map) {
      (json['par_categorie'] as Map).forEach((key, value) {
        parCategorie[key.toString()] = (value as num?)?.toDouble() ?? 0.0;
      });
    }

    return RapportFinancier(
      totalRecettes: (json['total_recettes'] as num?)?.toDouble() ?? 0.0,
      totalDepenses: (json['total_depenses'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      parCategorie: parCategorie,
      parMois: (json['par_mois'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [totalRecettes, totalDepenses, balance, parCategorie, parMois];
}
