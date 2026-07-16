import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/auth/permissions.dart';
import '../../blocs/groupes/groupes_bloc.dart';
import '../../../data/models/groupe_model.dart';
import '../../../data/models/membre_model.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/groupe_repository.dart';
import '../../../data/repositories/membre_repository.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_avatar.dart';

/// Détail d'un groupe : infos + responsables (assignables) + membres
/// (ajout/retrait), avec les actions réservées à `canManageGroupes`.
class GroupeDetailScreen extends StatelessWidget {
  final String groupeId;

  const GroupeDetailScreen({super.key, required this.groupeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupesBloc>()..add(LoadGroupeDetail(id: groupeId)),
      child: _GroupeDetailView(groupeId: groupeId),
    );
  }
}

class _GroupeDetailView extends StatefulWidget {
  final String groupeId;
  const _GroupeDetailView({required this.groupeId});

  @override
  State<_GroupeDetailView> createState() => _GroupeDetailViewState();
}

class _GroupeDetailViewState extends State<_GroupeDetailView> {
  // Caché localement pour survivre aux états transitoires (succès d'action).
  Groupe? _groupe;
  List<Membre> _membres = [];

  // Options des sélecteurs.
  List<AuthUser> _users = [];
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
        sl<GroupeRepository>().getUsers(),
        sl<MembreRepository>().getMembres(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0] as List<AuthUser>;
        _allMembres = results[1] as List<Membre>;
        _optionsLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _optionsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Détail du groupe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/groupes'),
        ),
        actions: [
          if (context.perms.canManageGroupes)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
              onPressed: () => context.push('/groupes/${widget.groupeId}/edit'),
            ),
        ],
      ),
      body: BlocConsumer<GroupesBloc, GroupesState>(
        listener: (context, state) {
          if (state is GroupeDetailLoaded) {
            setState(() {
              _groupe = state.groupe;
              _membres = state.membres ?? [];
            });
          } else if (state is GroupeActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is GroupesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_groupe == null) {
            return const LoadingWidget(message: 'Chargement...');
          }
          return _buildContent(context, _groupe!, _membres);
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Groupe groupe, List<Membre> membres) {
    final canManage = context.perms.canManageGroupes;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _infoCard(groupe),
        const SizedBox(height: 20),
        _responsablesCard(groupe, canManage),
        const SizedBox(height: 20),
        _membresCard(groupe, membres, canManage),
      ],
    );
  }

  Widget _infoCard(Groupe groupe) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group,
                  color: AppTheme.primaryColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupe.nom,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  if (groupe.description != null &&
                      groupe.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(groupe.description!,
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsablesCard(Groupe groupe, bool canManage) {
    // Fusionne responsables multiples + éventuel responsable legacy.
    final noms = <String, String>{...groupe.responsablesNoms};
    if (groupe.responsable != null &&
        groupe.responsableNom != null &&
        !noms.containsKey(groupe.responsable)) {
      noms[groupe.responsable!] = groupe.responsableNom!;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.badge_outlined,
                    size: 18, color: AppTheme.secondaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Responsables',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                ),
                if (canManage)
                  TextButton.icon(
                    onPressed: _optionsLoaded ? _assignResponsables : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Assigner'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (noms.isEmpty)
              Text('Aucun responsable assigné',
                  style: TextStyle(color: AppTheme.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: noms.entries
                    .map((e) => Chip(
                          avatar: const Icon(Icons.person, size: 16),
                          label: Text(e.value),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _membresCard(Groupe groupe, List<Membre> membres, bool canManage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Membres',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${membres.length}',
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (canManage)
                  TextButton.icon(
                    onPressed: _optionsLoaded ? _addMembre : null,
                    icon: const Icon(Icons.person_add_alt, size: 18),
                    label: const Text('Ajouter'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (membres.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('Aucun membre dans ce groupe',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else
              ...membres.map((m) => _membreTile(m, groupe, canManage)),
          ],
        ),
      ),
    );
  }

  Widget _membreTile(Membre membre, Groupe groupe, bool canManage) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: UserAvatar(
        imageUrl: membre.profilePictureUrl,
        localImageFile: membre.user != null
            ? sl<AuthRepository>().getCachedProfilePicture(membre.user!)
            : null,
        initials:
            membre.prenom.isNotEmpty ? membre.prenom[0].toUpperCase() : 'M',
        radius: 20,
        backgroundColor: AppTheme.secondaryColor,
      ),
      title: Text(membre.nomComplet),
      subtitle: membre.telephone != null && membre.telephone!.isNotEmpty
          ? Text(membre.telephone!)
          : null,
      trailing: canManage
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppTheme.errorColor, size: 20),
              tooltip: 'Retirer du groupe',
              onPressed: () => _confirmRemove(membre, groupe),
            )
          : const Icon(Icons.chevron_right, size: 20),
      onTap: () => context.push('/membres/${membre.id}'),
    );
  }

  // --- Actions --------------------------------------------------------------

  Future<void> _assignResponsables() async {
    final current = <String>{..._groupe!.responsables};
    if (_groupe!.responsable != null) current.add(_groupe!.responsable!);
    final selected = await _multiSelect(
      title: 'Assigner des responsables',
      options: {
        for (final u in _users) u.id: u.fullName.isEmpty ? u.email : u.fullName
      },
      initial: current,
    );
    if (selected != null && mounted) {
      context.read<GroupesBloc>().add(AssignResponsables(
            groupeId: widget.groupeId,
            userIds: selected.toList(),
          ));
    }
  }

  Future<void> _addMembre() async {
    final inGroup = _membres.map((m) => m.id).toSet();
    final candidates =
        _allMembres.where((m) => !inGroup.contains(m.id)).toList();
    final membreId = await _singleSelect(
      title: 'Ajouter un membre',
      options: {for (final m in candidates) m.id: m.nomComplet},
    );
    if (membreId != null && mounted) {
      context.read<GroupesBloc>().add(AddMembreToGroupe(
            groupeId: widget.groupeId,
            membreId: membreId,
          ));
    }
  }

  void _confirmRemove(Membre membre, Groupe groupe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer du groupe'),
        content:
            Text('Retirer ${membre.nomComplet} du groupe "${groupe.nom}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GroupesBloc>().add(RemoveMembreFromGroupe(
                    groupeId: widget.groupeId,
                    membreId: membre.id,
                  ));
            },
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  // --- Sélecteurs génériques ------------------------------------------------

  Future<Set<String>?> _multiSelect({
    required String title,
    required Map<String, String> options,
    required Set<String> initial,
  }) {
    final search = TextEditingController();
    return showDialog<Set<String>>(
      context: context,
      builder: (context) {
        final temp = Set<String>.from(initial);
        return StatefulBuilder(
          builder: (context, setD) {
            final q = search.text.trim().toLowerCase();
            final entries = options.entries
                .where((e) => e.value.toLowerCase().contains(q))
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
                              children: entries
                                  .map((e) => CheckboxListTile(
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
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, temp),
                    child: const Text('Valider')),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _singleSelect({
    required String title,
    required Map<String, String> options,
  }) {
    final search = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setD) {
            final q = search.text.trim().toLowerCase();
            final entries = options.entries
                .where((e) => e.value.toLowerCase().contains(q))
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
                          ? const Center(
                              child: Text('Aucun membre disponible'))
                          : ListView(
                              children: entries
                                  .map((e) => ListTile(
                                        dense: true,
                                        title: Text(e.value),
                                        onTap: () =>
                                            Navigator.pop(context, e.key),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler')),
              ],
            );
          },
        );
      },
    );
  }
}
