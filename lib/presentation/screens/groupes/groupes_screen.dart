import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../blocs/groupes/groupes_bloc.dart';
import '../../../data/models/groupe_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/refresh_wrapper.dart';

class GroupesScreen extends StatelessWidget {
  const GroupesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupesBloc>()..add(const LoadGroupes()),
      child: const _GroupesView(),
    );
  }
}

class _GroupesView extends StatefulWidget {
  const _GroupesView();

  @override
  State<_GroupesView> createState() => _GroupesViewState();
}

class _GroupesViewState extends State<_GroupesView> {
  final _searchController = TextEditingController();
  List<Groupe> _groupes = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final bloc = context.read<GroupesBloc>();
    final search = _searchController.text.trim();
    bloc.add(LoadGroupes(search: search.isEmpty ? null : search));
    await bloc.stream.firstWhere((s) => s is GroupesLoaded || s is GroupesError);
  }

  void _deleteGroupe(BuildContext ctx, String id, String nom) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer le groupe "$nom" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              ctx.read<GroupesBloc>().add(DeleteGroupe(id: id));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupesBloc, GroupesState>(
      listener: (context, state) {
        if (state is GroupesLoaded) setState(() => _groupes = state.groupes);
        if (state is GroupeDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groupe supprimé'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.read<GroupesBloc>().add(const LoadGroupes());
        }
        if (state is GroupesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          body: Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: (state is GroupesLoading && _groupes.isEmpty)
                    ? const LoadingWidget(message: 'Chargement des groupes...')
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: _buildGrid(),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/groupes/new'),
            icon: const Icon(Icons.group_add),
            label: const Text('Nouveau groupe'),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un groupe...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<GroupesBloc>().add(const LoadGroupes());
                  },
                )
              : null,
          isDense: true,
        ),
        onChanged: (v) {
          context
              .read<GroupesBloc>()
              .add(LoadGroupes(search: v.isEmpty ? null : v));
        },
      ),
    );
  }

  Widget _buildGrid() {
    if (_groupes.isEmpty) {
      return const RefreshableEmpty(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('Aucun groupe trouvé',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _groupes.length,
      itemBuilder: (context, i) => _buildGroupeCard(context, _groupes[i]),
    );
  }

  Widget _buildGroupeCard(BuildContext context, Groupe groupe) {
    return InkWell(
      onTap: () => context.push('/groupes/${groupe.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group,
                      color: AppTheme.primaryColor, size: 24),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/groupes/${groupe.id}/edit');
                    } else if (value == 'delete') {
                      _deleteGroupe(context, groupe.id, groupe.nom);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer',
                          style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              groupe.nom,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (groupe.description != null) ...[
              const SizedBox(height: 4),
              Text(
                groupe.description!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            if (groupe.responsableNom != null) ...[
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      groupe.responsableNom!,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            Text(
              // groupe.dateCreation.isEmpty
              //     ? 'Date inconnue'
              // :
              'Créé le ${DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.parse(groupe.dateCreation))}',
              style:
                  const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    ));
  }
}
