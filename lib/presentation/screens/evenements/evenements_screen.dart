import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/evenements/evenements_bloc.dart';
import '../../../data/models/evenement_model.dart';
import '../../widgets/loading_widget.dart';

class EvenementsScreen extends StatelessWidget {
  const EvenementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EvenementsBloc>()..add(const LoadEvenements()),
      child: const _EvenementsView(),
    );
  }
}

class _EvenementsView extends StatefulWidget {
  const _EvenementsView();

  @override
  State<_EvenementsView> createState() => _EvenementsViewState();
}

class _EvenementsViewState extends State<_EvenementsView> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String? _selectedType;
  List<Evenement> _evenements = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _deleteEvenement(BuildContext ctx, int id, String titre) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer l\'événement "$titre" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              ctx.read<EvenementsBloc>().add(DeleteEvenement(id: id));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EvenementsBloc, EvenementsState>(
      listener: (context, state) {
        if (state is EvenementsLoaded) setState(() => _evenements = state.evenements);
        if (state is EvenementDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Événement supprimé'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.read<EvenementsBloc>().add(const LoadEvenements());
        }
        if (state is EvenementsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is EvenementsLoading;
        final upcoming = _evenements.where((e) => e.isUpcoming).toList()
          ..sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
        final past = _evenements.where((e) => !e.isUpcoming).toList()
          ..sort((a, b) => b.dateDebut.compareTo(a.dateDebut));

        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          body: Column(
            children: [
              _buildToolbar(context),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
                tabs: [
                  Tab(text: 'À venir (${upcoming.length})'),
                  Tab(text: 'Passés (${past.length})'),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const LoadingWidget(message: 'Chargement des événements...')
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(context, upcoming),
                          _buildList(context, past),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/evenements/new'),
            icon: const Icon(Icons.event_outlined),
            label: const Text('Nouvel événement'),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (v) {
                context.read<EvenementsBloc>().add(
                      LoadEvenements(search: v.isEmpty ? null : v, type: _selectedType),
                    );
              },
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String?>(
            value: _selectedType,
            hint: const Text('Type'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tous')),
              ...AppConstants.evenementTypes.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: (v) {
              setState(() => _selectedType = v);
              context.read<EvenementsBloc>().add(LoadEvenements(type: v));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Evenement> evenements) {
    if (evenements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('Aucun événement', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evenements.length,
      itemBuilder: (context, i) => _buildCard(context, evenements[i]),
    );
  }

  Widget _buildCard(BuildContext context, Evenement ev) {
    final typeColors = {
      'messe': AppTheme.primaryColor,
      'fete_liturgique': const Color(0xFF6A1B9A),
      'reunion': AppTheme.secondaryColor,
      'kermesse': const Color(0xFF00897B),
      'reservation': const Color(0xFFE65100),
    };
    final color = typeColors[ev.type] ?? AppTheme.primaryColor;
    final dateDebut = DateTime.tryParse(ev.dateDebut) ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd', 'fr_FR').format(dateDebut),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'fr_FR').format(dateDebut).toUpperCase(),
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev.titre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AppConstants.evenementTypes[ev.type] ?? ev.type,
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (ev.lieu != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textSecondary),
                          Text(
                            ev.lieu!,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                    if (ev.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        ev.description!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${ev.nbParticipants} participant(s)',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/evenements/${ev.id}/edit');
                  } else if (value == 'delete') {
                    _deleteEvenement(context, ev.id, ev.titre);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
