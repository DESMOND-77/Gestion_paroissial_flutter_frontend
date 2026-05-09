import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/article_model.dart';
import '../../../data/models/membre_model.dart';
import '../../blocs/librairie/librairie_bloc.dart';
import '../../blocs/membres/membres_bloc.dart';

class VenteFormScreen extends StatefulWidget {
  const VenteFormScreen({super.key});

  @override
  State<VenteFormScreen> createState() => _VenteFormScreenState();
}

class _VenteFormScreenState extends State<VenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController(text: '1');
  bool _isLoading = false;

  Article? _selectedArticle;
  Membre? _selectedMembre;

  List<Article> _articles = [];
  List<Membre> _membres = [];

  double get _prixTotal =>
      (_selectedArticle?.prixUnitaire ?? 0) *
      (int.tryParse(_quantiteController.text) ?? 0);

  @override
  void initState() {
    super.initState();
    context.read<LibrairieBloc>().add(const LoadArticles());
    context.read<MembresBloc>().add(const LoadMembres());
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedArticle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez un article'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final data = {
      'article': _selectedArticle!.id,
      'quantite': int.parse(_quantiteController.text.trim()),
      if (_selectedMembre != null) 'membre': _selectedMembre!.id,
    };

    context.read<LibrairieBloc>().add(CreateVente(data: data));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LibrairieBloc, LibrairieState>(
          listener: (context, state) {
            if (state is LibrairieLoading) {
              setState(() => _isLoading = true);
            } else {
              setState(() => _isLoading = false);
            }

            if (state is ArticlesLoaded) {
              setState(() => _articles = state.articles);
            }

            if (state is VenteCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vente enregistrée avec succès'),
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
        ),
        BlocListener<MembresBloc, MembresState>(
          listener: (context, state) {
            if (state is MembresLoaded) {
              setState(() => _membres = state.membres);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enregistrer une vente'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/librairie'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informations de la vente',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<Article>(
                      initialValue: _selectedArticle,
                      decoration: const InputDecoration(
                        labelText: 'Article *',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                      ),
                      hint: const Text('Sélectionnez un article'),
                      items: _articles
                          .map((a) => DropdownMenuItem(
                                value: a,
                                child: Text(
                                    '${a.nom} (stock: ${a.stockDisponible})'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedArticle = v),
                      validator: (v) =>
                          v == null ? 'Sélectionnez un article' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantiteController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité *',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Champ requis';
                        final q = int.tryParse(v);
                        if (q == null || q <= 0) return 'Quantité invalide';
                        if (_selectedArticle != null &&
                            q > _selectedArticle!.stockDisponible) {
                          return 'Stock insuffisant (${_selectedArticle!.stockDisponible} disponibles)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Membre>(
                      initialValue: _selectedMembre,
                      decoration: const InputDecoration(
                        labelText: 'Membre (optionnel)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      hint: const Text('Sélectionnez un membre'),
                      items: [
                        const DropdownMenuItem<Membre>(
                            value: null, child: Text('Aucun')),
                        ..._membres.map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.nomComplet),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedMembre = v),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedArticle != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withAlpha(77),
                          ),
                        ),
                        child: Column(
                          children: [
                            _summaryRow('Article', _selectedArticle!.nom),
                            const SizedBox(height: 8),
                            _summaryRow('Prix unitaire',
                                '${_selectedArticle!.prixUnitaire.toStringAsFixed(0)} FCFA'),
                            const SizedBox(height: 8),
                            _summaryRow('Quantité',
                                int.tryParse(_quantiteController.text)?.toString() ?? '0'),
                            const Divider(height: 16),
                            _summaryRow(
                              'TOTAL',
                              '${_prixTotal.toStringAsFixed(0)} FCFA',
                              bold: true,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
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
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.shopping_cart),
                            label: const Text('Valider la vente'),
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

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
      fontSize: bold ? 16 : 14,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
