import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/finances/finances_bloc.dart';
import '../../blocs/membres/membres_bloc.dart';

class TransactionFormScreen extends StatelessWidget {
  final int? transactionId;

  const TransactionFormScreen({super.key, this.transactionId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<FinancesBloc>();
            if (transactionId != null) bloc.add(const LoadTransactions());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) => sl<MembresBloc>()..add(const LoadMembres()),
        ),
      ],
      child: _TransactionFormView(transactionId: transactionId),
    );
  }
}

class _TransactionFormView extends StatefulWidget {
  final int? transactionId;
  const _TransactionFormView({this.transactionId});

  @override
  State<_TransactionFormView> createState() => _TransactionFormViewState();
}

class _TransactionFormViewState extends State<_TransactionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'recette';
  String _categorie = 'don';
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int? _selectedMembre;
  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'type': _type,
        'categorie': _categorie,
        'montant': double.parse(_montantController.text.replaceAll(',', '.')),
        if (_descriptionController.text.isNotEmpty) 'description': _descriptionController.text.trim(),
        'date': _date,
        if (_selectedMembre != null) 'membre': _selectedMembre,
      };
      if (widget.transactionId != null) {
        context.read<FinancesBloc>().add(UpdateTransaction(id: widget.transactionId!, data: data));
      } else {
        context.read<FinancesBloc>().add(CreateTransaction(data: data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transactionId != null;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier la transaction' : 'Nouvelle transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/finances'),
        ),
      ),
      body: BlocConsumer<FinancesBloc, FinancesState>(
        listener: (context, state) {
          if (state is TransactionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction créée avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/finances');
          }
          if (state is TransactionUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction modifiée avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/finances');
          }
          if (state is FinancesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations de la transaction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Type *', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'recette',
                                label: Text('Recette'),
                                icon: Icon(Icons.arrow_downward),
                              ),
                              ButtonSegment(
                                value: 'depense',
                                label: Text('Dépense'),
                                icon: Icon(Icons.arrow_upward),
                              ),
                            ],
                            selected: {_type},
                            onSelectionChanged: (v) => setState(() => _type = v.first),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _categorie,
                            decoration: const InputDecoration(
                              labelText: 'Catégorie *',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: AppConstants.transactionCategories.entries
                                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) => setState(() => _categorie = v ?? 'don'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _montantController,
                            decoration: const InputDecoration(
                              labelText: 'Montant (FCFA) *',
                              prefixIcon: Icon(Icons.money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v?.isEmpty == true) return 'Requis';
                              if (double.tryParse(v!.replaceAll(',', '.')) == null) {
                                return 'Montant invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date *',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              child: Text(_date),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<MembresBloc, MembresState>(
                            builder: (context, membresState) {
                              final membres = membresState is MembresLoaded ? membresState.membres : [];
                              return DropdownButtonFormField<int?>(
                                initialValue: _selectedMembre,
                                decoration: const InputDecoration(
                                  labelText: 'Membre (optionnel)',
                                  prefixIcon: Icon(Icons.person_outlined),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Aucun membre')),
                                  ...membres.map(
                                    (m) => DropdownMenuItem(value: m.id, child: Text(m.nomComplet)),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _selectedMembre = v),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go('/finances'),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: 12),
                              BlocBuilder<FinancesBloc, FinancesState>(
                                builder: (context, state) {
                                  final isLoading = state is FinancesLoading;
                                  return ElevatedButton(
                                    onPressed: isLoading ? null : _onSubmit,
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(isEdit ? 'Enregistrer' : 'Enregistrer'),
                                  );
                                },
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
        },
      ),
    );
  }
}
