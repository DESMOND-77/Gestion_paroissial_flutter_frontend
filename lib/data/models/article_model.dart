import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String nom;
  final String? description;
  final String categorie;
  final double prixUnitaire;
  final int stockDisponible;
  final int seuilAlerte;
  final bool enAlerte;
  final String? dateAjout;

  const Article({
    required this.id,
    required this.nom,
    this.description,
    required this.categorie,
    required this.prixUnitaire,
    required this.stockDisponible,
    required this.seuilAlerte,
    required this.enAlerte,
    this.dateAjout,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String?,
      categorie: json['categorie'] as String? ?? '',
      prixUnitaire: (json['prix_unitaire'] is String 
          ? double.tryParse(json['prix_unitaire'] as String)
          : json['prix_unitaire'] as num?)?.toDouble() ?? 0.0,
      stockDisponible: json['stock_disponible'] as int? ?? 0,
      seuilAlerte: json['seuil_alerte'] as int? ?? 0,
      enAlerte: json['en_alerte'] as bool? ?? false,
      dateAjout: json['date_ajout'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      if (description != null) 'description': description,
      'categorie': categorie,
      'prix_unitaire': prixUnitaire,
      'stock_disponible': stockDisponible,
      'seuil_alerte': seuilAlerte,
      'en_alerte': enAlerte,
      if (dateAjout != null) 'date_ajout': dateAjout,
    };
  }

  String get categorieLabel {
    const labels = {
      'livre': 'Livre',
      'bougie': 'Bougie',
      'chapelet': 'Chapelet',
      'vetement': 'Vêtement',
      'autre': 'Autre',
    };
    return labels[categorie] ?? categorie;
  }

  Article copyWith({
    String? id,
    String? nom,
    String? description,
    String? categorie,
    double? prixUnitaire,
    int? stockDisponible,
    int? seuilAlerte,
    bool? enAlerte,
    String? dateAjout,
  }) {
    return Article(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      categorie: categorie ?? this.categorie,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      stockDisponible: stockDisponible ?? this.stockDisponible,
      seuilAlerte: seuilAlerte ?? this.seuilAlerte,
      enAlerte: enAlerte ?? this.enAlerte,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nom,
        description,
        categorie,
        prixUnitaire,
        stockDisponible,
        seuilAlerte,
        enAlerte,
        dateAjout,
      ];
}
