import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../blocs/membres/membres_bloc.dart';
import '../../blocs/groupes/groupes_bloc.dart';
import '../../widgets/loading_widget.dart';

class MembreFormScreen extends StatelessWidget {
  final String? membreId;

  const MembreFormScreen({super.key, this.membreId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<MembresBloc>();
            if (membreId != null) {
              bloc.add(LoadMembreDetail(id: membreId!));
            }
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) => sl<GroupesBloc>()..add(const LoadGroupes()),
        ),
      ],
      child: _MembreFormView(membreId: membreId),
    );
  }
}

class _MembreFormView extends StatefulWidget {
  final String? membreId;

  const _MembreFormView({this.membreId});

  @override
  State<_MembreFormView> createState() => _MembreFormViewState();
}

class _MembreFormViewState extends State<_MembreFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _quartierController = TextEditingController();
  String _sexe = 'M';
  String? _dateNaissance;
  String? _selectedGroupe;
  bool _estBaptise = false;
  bool _estConfirme = false;
  bool _dataLoaded = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _quartierController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'sexe': _sexe,
        if (_telephoneController.text.isNotEmpty) 'telephone': _telephoneController.text.trim(),
        if (_emailController.text.isNotEmpty) 'email': _emailController.text.trim(),
        if (_quartierController.text.isNotEmpty) 'quartier': _quartierController.text.trim(),
        if (_dateNaissance != null) 'date_naissance': _dateNaissance,
        if (_selectedGroupe != null) 'groupe': _selectedGroupe,
        'est_baptise': _estBaptise,
        'est_confirme': _estConfirme,
      };

      if (widget.membreId != null) {
        context.read<MembresBloc>().add(UpdateMembre(id: widget.membreId!, data: data));
      } else {
        context.read<MembresBloc>().add(CreateMembre(data: data));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance != null
          ? DateTime.parse(_dateNaissance!)
          : DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateNaissance = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.membreId != null;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le membre' : 'Nouveau membre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/membres'),
        ),
      ),
      body: BlocConsumer<MembresBloc, MembresState>(
        listener: (context, state) {
          if (state is MembreDetailLoaded && !_dataLoaded) {
            final m = state.membre;
            _nomController.text = m.nom;
            _prenomController.text = m.prenom;
            _telephoneController.text = m.telephone ?? '';
            _emailController.text = m.email ?? '';
            _quartierController.text = m.quartier ?? '';
            setState(() {
              _sexe = m.sexe;
              _dateNaissance = m.dateNaissance;
              _selectedGroupe = m.groupe;
              _estBaptise = m.estBaptise;
              _estConfirme = m.estConfirme;
              _dataLoaded = true;
            });
          }
          if (state is MembreCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Membre créé avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/membres');
          }
          if (state is MembreUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Membre modifié avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/membres');
          }
          if (state is MembresError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (isEdit && state is MembresLoading && !_dataLoaded) {
            return const LoadingWidget(message: 'Chargement...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
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
                          Text(
                            isEdit ? 'Modifier les informations' : 'Informations du membre',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 500;
                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(child: _buildNomField()),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildPrenomField()),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  _buildNomField(),
                                  const SizedBox(height: 16),
                                  _buildPrenomField(),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSexeSelector(),
                          const SizedBox(height: 16),
                          _buildDateNaissanceField(context),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telephoneController,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            readOnly : true,
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _quartierController,
                            decoration: const InputDecoration(
                              labelText: 'Quartier',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildGroupeSelector(),
                          const SizedBox(height: 20),
                          const Text(
                            'Sacrements',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text('Baptisé'),
                                  value: _estBaptise,
                                  onChanged: (v) => setState(() => _estBaptise = v ?? false),
                                  activeColor: AppTheme.primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text('Confirmé'),
                                  value: _estConfirme,
                                  onChanged: (v) => setState(() => _estConfirme = v ?? false),
                                  activeColor: AppTheme.primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go('/membres'),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: 12),
                              BlocBuilder<MembresBloc, MembresState>(
                                builder: (context, state) {
                                  final isLoading = state is MembresLoading;
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
                                        : Text(isEdit ? 'Enregistrer' : 'Créer'),
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

  Widget _buildNomField() {
    return TextFormField(
      controller: _nomController,
      decoration: const InputDecoration(
        labelText: 'Nom *',
        prefixIcon: Icon(Icons.person_outlined),
      ),
      validator: (v) => v?.isEmpty == true ? 'Le nom est requis' : null,
    );
  }

  Widget _buildPrenomField() {
    return TextFormField(
      controller: _prenomController,
      decoration: const InputDecoration(
        labelText: 'Prénom *',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (v) => v?.isEmpty == true ? 'Le prénom est requis' : null,
    );
  }

  Widget _buildSexeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexe *',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'M', label: Text('Masculin'), icon: Icon(Icons.male)),
            ButtonSegment(value: 'F', label: Text('Féminin'), icon: Icon(Icons.female)),
          ],
          selected: {_sexe},
          onSelectionChanged: (v) => setState(() => _sexe = v.first),
        ),
      ],
    );
  }

  Widget _buildDateNaissanceField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date de naissance',
          prefixIcon: Icon(Icons.cake_outlined),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _dateNaissance ?? 'Sélectionner une date',
          style: TextStyle(
            color: _dateNaissance != null ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupeSelector() {
    return BlocBuilder<GroupesBloc, GroupesState>(
      builder: (context, state) {
        final groupes = state is GroupesLoaded ? state.groupes : [];
        return DropdownButtonFormField<String?>(
          initialValue: _selectedGroupe,
          decoration: const InputDecoration(
            labelText: 'Groupe',
            prefixIcon: Icon(Icons.group_outlined),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Aucun groupe')),
            ...groupes.map((g) => DropdownMenuItem(value: g.id, child: Text(g.nom))),
          ],
          onChanged: (v) => setState(() => _selectedGroupe = v),
        );
      },
    );
  }
}
