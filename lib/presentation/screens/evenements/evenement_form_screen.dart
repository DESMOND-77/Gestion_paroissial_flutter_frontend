import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/evenements/evenements_bloc.dart';
import '../../widgets/loading_widget.dart';
import '../../../data/models/groupe_model.dart';
import '../../../data/models/membre_model.dart';
import '../../../data/repositories/groupe_repository.dart';
import '../../../data/repositories/membre_repository.dart';

/// Rôles (accounts.User.ROLES_CHOICES) proposés pour la conviction par rôle.
const Map<String, String> kRoleLabels = {
  'fidele': 'Fidèle',
  'responsable': 'Responsable',
  'secretaire': 'Secrétaire',
  'tresorier': 'Trésorier',
  'pretre': 'Prêtre',
  'admin': 'Administrateur',
};

class EvenementFormScreen extends StatelessWidget {
  final String? evenementId;

  const EvenementFormScreen({super.key, this.evenementId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<EvenementsBloc>();
        if (evenementId != null) bloc.add(LoadEvenementDetail(id: evenementId!));
        return bloc;
      },
      child: _EvenementFormView(evenementId: evenementId),
    );
  }
}

class _EvenementFormView extends StatefulWidget {
  final String? evenementId;
  const _EvenementFormView({this.evenementId});

  @override
  State<_EvenementFormView> createState() => _EvenementFormViewState();
}

class _EvenementFormViewState extends State<_EvenementFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  String _type = 'messe';
  String? _dateDebut;
  String? _dateFin;
  bool _estInscriptionRequise = false;
  bool _dataLoaded = false;

  // Conviés
  bool _inviteTous = false;
  final Set<String> _rolesInvites = {};
  final Set<String> _groupesInvites = {};
  final Set<String> _membresInvites = {};
  List<Groupe> _allGroupes = [];
  List<Membre> _allMembres = [];
  bool _optionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        sl<GroupeRepository>().getGroupes(),
        sl<MembreRepository>().getMembres(),
      ]);
      if (!mounted) return;
      setState(() {
        _allGroupes = results[0] as List<Groupe>;
        _allMembres = results[1] as List<Membre>;
        _optionsLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _optionsLoaded = true);
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, {required bool isDebut}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && context.mounted) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        final dt = DateTime(picked.year, picked.month, picked.day,
            timePicked.hour, timePicked.minute);
        // Envoi en UTC (avec « Z ») : l'instant est non ambigu quel que soit le
        // fuseau du serveur (sinon une heure naïve est interprétée dans le
        // fuseau serveur et décalée).
        final formatted = dt.toUtc().toIso8601String();
        setState(() {
          if (isDebut) {
            _dateDebut = formatted;
          } else {
            _dateFin = formatted;
          }
        });
      }
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'titre': _titreController.text.trim(),
        'type': _type,
        if (_descriptionController.text.isNotEmpty) 'description': _descriptionController.text.trim(),
        'date_debut': _dateDebut!,
        if (_dateFin != null) 'date_fin': _dateFin,
        if (_lieuController.text.isNotEmpty) 'lieu': _lieuController.text.trim(),
        'est_inscription_requise': _estInscriptionRequise,
        'invite_tous': _inviteTous,
        'roles_invites': _rolesInvites.toList(),
        'groupes_invites': _groupesInvites.toList(),
        'membres_invites': _membresInvites.toList(),
      };
      if (widget.evenementId != null) {
        context.read<EvenementsBloc>().add(UpdateEvenement(id: widget.evenementId!, data: data));
      } else {
        context.read<EvenementsBloc>().add(CreateEvenement(data: data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.evenementId != null;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier l\'événement' : 'Nouvel événement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/evenements'),
        ),
      ),
      body: BlocConsumer<EvenementsBloc, EvenementsState>(
        listener: (context, state) {
          if (state is EvenementDetailLoaded && !_dataLoaded) {
            final e = state.evenement;
            _titreController.text = e.titre;
            _descriptionController.text = e.description ?? '';
            _lieuController.text = e.lieu ?? '';
            setState(() {
              _type = e.type;
              _dateDebut = e.dateDebut;
              _dateFin = e.dateFin;
              _estInscriptionRequise = e.estInscriptionRequise;
              _inviteTous = e.inviteTous;
              _rolesInvites
                ..clear()
                ..addAll(e.rolesInvites);
              _groupesInvites
                ..clear()
                ..addAll(e.groupesInvites);
              _membresInvites
                ..clear()
                ..addAll(e.membresInvites);
              _dataLoaded = true;
            });
          }
          if (state is EvenementCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Événement créé avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/evenements');
          }
          if (state is EvenementUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Événement modifié avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/evenements');
          }
          if (state is EvenementsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          if (isEdit && state is EvenementsLoading && !_dataLoaded) {
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
                            isEdit ? 'Modifier l\'événement' : 'Informations de l\'événement',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _titreController,
                            decoration: const InputDecoration(
                              labelText: 'Titre *',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _type,
                            decoration: const InputDecoration(
                              labelText: 'Type *',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: AppConstants.evenementTypes.entries
                                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) => setState(() => _type = v ?? 'messe'),
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
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 500;
                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateTimeField(
                                        context,
                                        label: 'Date de début *',
                                        value: _dateDebut,
                                        isDebut: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDateTimeField(
                                        context,
                                        label: 'Date de fin',
                                        value: _dateFin,
                                        isDebut: false,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  _buildDateTimeField(
                                    context,
                                    label: 'Date de début *',
                                    value: _dateDebut,
                                    isDebut: true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDateTimeField(
                                    context,
                                    label: 'Date de fin',
                                    value: _dateFin,
                                    isDebut: false,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lieuController,
                            decoration: const InputDecoration(
                              labelText: 'Lieu',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Inscription requise'),
                            subtitle: const Text(
                              'Les membres doivent s\'inscrire pour participer',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _estInscriptionRequise,
                            onChanged: (v) => setState(() => _estInscriptionRequise = v),
                            activeThumbColor: AppTheme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(height: 32),
                          _buildConvocationSection(),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go('/evenements'),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: 12),
                              BlocBuilder<EvenementsBloc, EvenementsState>(
                                builder: (context, state) {
                                  final isLoading = state is EvenementsLoading;
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

  Widget _buildConvocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conviés',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Qui est invité à cet événement ? (l\'événement s\'affichera chez les personnes conviées)',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        SwitchListTile(
          title: const Text('Convier toute la paroisse'),
          value: _inviteTous,
          onChanged: (v) => setState(() => _inviteTous = v),
          activeThumbColor: AppTheme.primaryColor,
          contentPadding: EdgeInsets.zero,
        ),
        if (!_inviteTous) ...[
          const SizedBox(height: 8),
          const Text('Par rôle',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: kRoleLabels.entries.map((e) {
              final selected = _rolesInvites.contains(e.key);
              return FilterChip(
                label: Text(e.value),
                labelStyle: TextStyle(
                  color: selected ? AppTheme.accentColor : AppTheme.textPrimary,
                ),
                selected: selected,
                onSelected: (on) => setState(() {
                  if (on) {
                    _rolesInvites.add(e.key);
                  } else {
                    _rolesInvites.remove(e.key);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildPickerRow(
            label: 'Groupes entiers',
            icon: Icons.groups_outlined,
            count: _groupesInvites.length,
            enabled: _optionsLoaded,
            onTap: () => _pickMulti(
              title: 'Groupes conviés',
              options: {for (final g in _allGroupes) g.id: g.nom},
              selection: _groupesInvites,
            ),
          ),
          const SizedBox(height: 8),
          _buildPickerRow(
            label: 'Membres précis',
            icon: Icons.person_outline,
            count: _membresInvites.length,
            enabled: _optionsLoaded,
            onTap: () => _pickMulti(
              title: 'Membres conviés',
              options: {for (final m in _allMembres) m.id: m.nomComplet},
              selection: _membresInvites,
            ),
          ),
          if (!_optionsLoaded)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Chargement des groupes et membres…',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ),
        ],
      ],
    );
  }

  Widget _buildPickerRow({
    required String label,
    required IconData icon,
    required int count,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(
          count == 0 ? 'Aucun sélectionné' : '$count sélectionné(s)',
          style: TextStyle(
            color: count == 0 ? AppTheme.textSecondary : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickMulti({
    required String title,
    required Map<String, String> options,
    required Set<String> selection,
  }) async {
    final search = TextEditingController();
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) {
        final temp = Set<String>.from(selection);
        return StatefulBuilder(
          builder: (context, setD) {
            final query = search.text.trim().toLowerCase();
            final entries = options.entries
                .where((e) => e.value.toLowerCase().contains(query))
                .toList();
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 400,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      controller: search,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher…',
                        prefixIcon: Icon(Icons.search, size: 20),
                        isDense: true,
                      ),
                      onChanged: (_) => setD(() {}),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: entries.isEmpty
                          ? const Center(child: Text('Aucun résultat'))
                          : ListView(
                              children: entries.map((e) {
                                return CheckboxListTile(
                                  dense: true,
                                  title: Text(e.value),
                                  value: temp.contains(e.key),
                                  onChanged: (on) => setD(() {
                                    if (on == true) {
                                      temp.add(e.key);
                                    } else {
                                      temp.remove(e.key);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, temp),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        selection
          ..clear()
          ..addAll(result);
      });
    }
  }

  Widget _buildDateTimeField(
    BuildContext context, {
    required String label,
    required String? value,
    required bool isDebut,
  }) {
    return FormField<String>(
      validator: (v) {
        if (isDebut && _dateDebut == null) return 'Date de début requise';
        return null;
      },
      builder: (field) => InkWell(
        onTap: () => _selectDateTime(context, isDebut: isDebut),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            errorText: field.errorText,
          ),
          child: Text(
            value != null
                ? DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.parse(value).toLocal())
                : 'Sélectionner',
            style: TextStyle(
              color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
