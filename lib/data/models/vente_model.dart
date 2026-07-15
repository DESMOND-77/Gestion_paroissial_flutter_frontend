import 'package:equatable/equatable.dart';

class Vente extends Equatable {
  final String id;
  final String article;
  final String articleNom;
  final int quantite;
  final double prixTotal;
  final String date;
  final String? membre;
  final String? membreNom;
  final String? enregistrePar;
  final String? enregistreParNom;

  const Vente({
    required this.id,
    required this.article,
    required this.articleNom,
    required this.quantite,
    required this.prixTotal,
    required this.date,
    this.membre,
    this.membreNom,
    this.enregistrePar,
    this.enregistreParNom,
  });

  factory Vente.fromJson(Map<String, dynamic> json) {
    return Vente(
      id: json['id'] as String? ?? '',
      article: json['article'] as String? ?? '',
      articleNom: json['article_nom'] as String? ?? '',
      quantite: json['quantite'] as int? ?? 0,
      prixTotal: (json['prix_total'] is String 
          ? double.tryParse(json['prix_total'] as String)
          : json['prix_total'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      membre: json['membre'] as String?,
      membreNom: json['membre_nom'] as String?,
      enregistrePar: json['enregistre_par'] as String?,
      enregistreParNom: json['enregistre_par_nom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': article,
      'quantite': quantite,
      'date': date,
      if (membre != null) 'membre': membre,
    };
  }

  Vente copyWith({
    String? id,
    String? article,
    String? articleNom,
    int? quantite,
    double? prixTotal,
    String? date,
    String? membre,
    String? membreNom,
    String? enregistrePar,
    String? enregistreParNom,
  }) {
    return Vente(
      id: id ?? this.id,
      article: article ?? this.article,
      articleNom: articleNom ?? this.articleNom,
      quantite: quantite ?? this.quantite,
      prixTotal: prixTotal ?? this.prixTotal,
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
        article,
        articleNom,
        quantite,
        prixTotal,
        date,
        membre,
        membreNom,
        enregistrePar,
        enregistreParNom,
      ];
}
