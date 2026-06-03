import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../blocs/membres/membres_bloc.dart';
import '../../../data/models/membre_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/refresh_wrapper.dart';

class MembresScreen extends StatelessWidget {
  const MembresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MembresBloc>()..add(const LoadMembres()),
      child: const _MembresView(),
    );
  }
}

class _MembresView extends StatefulWidget {
  const _MembresView();

  @override
  State<_MembresView> createState() => _MembresViewState();
}

class _MembresViewState extends State<_MembresView> {
  final _searchController = TextEditingController();
  String? _selectedSexe;
  List<Membre> _membres = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<MembresBloc>().add(LoadMembres(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          sexe: _selectedSexe,
        ));
  }

  Future<void> _refresh() async {
    final bloc = context.read<MembresBloc>();
    bloc.add(LoadMembres(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      sexe: _selectedSexe,
    ));
    await bloc.stream
        .firstWhere((s) => s is MembresLoaded || s is MembresError);
  }

  void _deleteMembre(BuildContext ctx, int id, String nom) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le membre "$nom" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              ctx.read<MembresBloc>().add(DeleteMembre(id: id));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MembresBloc, MembresState>(
      listener: (context, state) {
        if (state is MembresLoaded) {
          setState(() => _membres = state.membres);
        }
        if (state is MembreDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membre supprimé avec succès'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.read<MembresBloc>().add(const LoadMembres());
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
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          body: Column(
            children: [
              _buildToolbar(context),
              Expanded(
                child: (state is MembresLoading && _membres.isEmpty)
                    ? const LoadingWidget(message: 'Chargement des membres...')
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: _buildTable(context),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/membres/new'),
            icon: const Icon(
              Icons.person_add,
              size: 20,
            ),
            label: const SizedBox(),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un membre...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              onChanged: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _selectedSexe,
            hint: const Text('Sexe'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tous')),
              DropdownMenuItem(value: 'M', child: Text('Masculin')),
              DropdownMenuItem(value: 'F', child: Text('Féminin')),
            ],
            onChanged: (v) {
              setState(() => _selectedSexe = v);
              _onSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
   
    if (_membres.isEmpty) {
      return const RefreshableEmpty(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'Aucun membre trouvé',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DataTable2(
          columnSpacing: 10,
          horizontalMargin: 16,
          minWidth: 600,
          headingRowColor:
              WidgetStateProperty.all(AppTheme.primaryColor.withAlpha(25)),
          columns: const [
            DataColumn2(label: Text('Nom complet'), size: ColumnSize.L),
            DataColumn2(label: Text('Sexe'), size: ColumnSize.S),
            DataColumn2(label: Text('Téléphone'), size: ColumnSize.M),
            DataColumn2(label: Text('Quartier'), size: ColumnSize.M),
            DataColumn2(label: Text('Groupe'), size: ColumnSize.M),
            DataColumn2(label: Text('Baptisé'), size: ColumnSize.S),
            DataColumn2(
                label: Text('Actions'), size: ColumnSize.S, fixedWidth: 105),
          ],
          rows: _membres.map((membre) {
            return DataRow2(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => context.push('/membres/${membre.id}'),
                    child: Text(
                      membre.nomComplet,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(membre.sexe == 'M' ? 'M' : 'F')),
                DataCell(Text(membre.telephone ?? '-')),
                DataCell(Text(membre.quartier ?? '-')),
                DataCell(Text(membre.groupeNom ?? '-')),
                DataCell(
                  Icon(
                    membre.estBaptise ? Icons.check_circle : Icons.cancel,
                    color: membre.estBaptise
                        ? AppTheme.successColor
                        : AppTheme.textSecondary,
                    size: 18,
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () =>
                            context.push('/membres/${membre.id}/edit'),
                        tooltip: 'Modifier',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 18, color: AppTheme.errorColor),
                        onPressed: () => _deleteMembre(
                            context, membre.id, membre.nomComplet),
                        tooltip: 'Supprimer',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
