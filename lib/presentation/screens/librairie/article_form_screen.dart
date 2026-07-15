import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/article_model.dart';
import '../../blocs/librairie/librairie_bloc.dart';

class ArticleFormScreen extends StatefulWidget {
  final String? articleId;

  const ArticleFormScreen({super.key, this.articleId});

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _stockController = TextEditingController();
  final _seuilController = TextEditingController();

  String _categorie = 'livre';
  bool _isLoading = false;
  Article? _article;

  static const _categories = [
    {'value': 'livre', 'label': 'Livre'},
    {'value': 'bougie', 'label': 'Bougie'},
    {'value': 'chapelet', 'label': 'Chapelet'},
    {'value': 'vetement', 'label': 'Vêtement'},
    {'value': 'autre', 'label': 'Autre'},
  ];

  bool get _isEditing => widget.articleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadArticle();
    }
  }

  void _loadArticle() {
    context.read<LibrairieBloc>().add(const LoadArticles());
  }

  void _populateForm(Article article) {
    _article = article;
    _nomController.text = article.nom;
    _descriptionController.text = article.description ?? '';
    _prixController.text = article.prixUnitaire.toStringAsFixed(0);
    _stockController.text = article.stockDisponible.toString();
    _seuilController.text = article.seuilAlerte.toString();
    setState(() => _categorie = article.categorie);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    _seuilController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'nom': _nomController.text.trim(),
      'description': _descriptionController.text.trim(),
      'categorie': _categorie,
      'prix_unitaire': _prixController.text.trim(),
      'stock_disponible': int.parse(_stockController.text.trim()),
      'seuil_alerte': int.parse(_seuilController.text.trim()),
    };

    if (_isEditing) {
      context.read<LibrairieBloc>().add(UpdateArticle(id: widget.articleId!, data: data));
    } else {
      context.read<LibrairieBloc>().add(CreateArticle(data: data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibrairieBloc, LibrairieState>(
      listener: (context, state) {
        if (state is LibrairieLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is ArticlesLoaded && _isEditing && _article == null) {
          final found = state.articles.where((a) => a.id == widget.articleId);
          if (found.isNotEmpty) _populateForm(found.first);
        }

        if (state is ArticleCreated || state is ArticleUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing
                  ? 'Article modifié avec succès'
                  : 'Article créé avec succès'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.go('/librairie');
        } else if (state is LibrairieError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Modifier l\'article' : 'Nouvel article'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/librairie'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Informations générales'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'article *',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _categorie,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c['value'],
                                child: Text(c['label']!),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _categorie = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Prix et stock'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prixController,
                            decoration: const InputDecoration(
                              labelText: 'Prix unitaire (FCFA) *',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Champ requis';
                              }
                              if (double.tryParse(v) == null) {
                                return 'Prix invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock disponible *',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Champ requis';
                              }
                              if (int.tryParse(v) == null) {
                                return 'Nombre invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _seuilController,
                            decoration: const InputDecoration(
                              labelText: 'Seuil d\'alerte *',
                              prefixIcon: Icon(Icons.warning_amber_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Champ requis';
                              }
                              if (int.tryParse(v) == null) {
                                return 'Nombre invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isLoading ? null : () => context.go('/librairie'),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(_isEditing ? 'Enregistrer' : 'Créer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
