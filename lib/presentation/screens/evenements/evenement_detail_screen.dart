import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/auth/permissions.dart';
import '../../blocs/evenements/evenements_bloc.dart';
import '../../../data/models/evenement_model.dart';
import '../../widgets/loading_widget.dart';
import 'evenement_form_screen.dart' show kRoleLabels;

/// Détail d'un événement : informations, conviés, et gestion (modifier /
/// supprimer, désactivés si l'événement est passé). La modification des
/// conviés se fait via le formulaire d'édition (sélecteur de conviés).
class EvenementDetailScreen extends StatelessWidget {
  final String evenementId;

  const EvenementDetailScreen({super.key, required this.evenementId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EvenementsBloc>()..add(LoadEvenementDetail(id: evenementId)),
      child: _EvenementDetailView(evenementId: evenementId),
    );
  }
}

class _EvenementDetailView extends StatelessWidget {
  final String evenementId;

  const _EvenementDetailView({required this.evenementId});

  void _confirmDelete(BuildContext ctx, Evenement ev) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous supprimer l\'événement "${ev.titre}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              ctx.read<EvenementsBloc>().add(DeleteEvenement(id: ev.id));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Détail de l\'événement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/evenements'),
        ),
        actions: [
          BlocBuilder<EvenementsBloc, EvenementsState>(
            builder: (context, state) {
              if (state is! EvenementDetailLoaded) return const SizedBox.shrink();
              final ev = state.evenement;
              final disabled = ev.estPasse;
              return Row(
                children: [
                  if (context.perms.canManageEvenements)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: disabled ? 'Événement passé' : 'Modifier',
                      onPressed: disabled
                          ? null
                          : () =>
                              context.push('/evenements/$evenementId/edit'),
                    ),
                  if (context.perms.canDeleteEvenements)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: disabled ? 'Événement passé' : 'Supprimer',
                      onPressed:
                          disabled ? null : () => _confirmDelete(context, ev),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<EvenementsBloc, EvenementsState>(
        listener: (context, state) {
          if (state is EvenementDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Événement supprimé'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/evenements');
          }
          if (state is EvenementsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          if (state is EvenementDetailLoaded) {
            return _buildContent(context, state.evenement);
          }
          if (state is EvenementsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<EvenementsBloc>()
                        .add(LoadEvenementDetail(id: evenementId)),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const LoadingWidget(message: 'Chargement...');
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Evenement ev) {
    // `.toLocal()` : les dates backend sont horodatées (+offset) et parsées en
    // UTC ; on les affiche dans le fuseau de l'appareil.
    final dateDebut = DateTime.tryParse(ev.dateDebut)?.toLocal();
    final dateFin =
        ev.dateFin != null ? DateTime.tryParse(ev.dateFin!)?.toLocal() : null;
    final fmt = DateFormat('EEEE d MMMM yyyy • HH:mm', 'fr_FR');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ev.titre,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (ev.estPasse)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Passé',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _chip(AppConstants.evenementTypes[ev.type] ?? ev.type,
                    AppTheme.primaryColor),
                const Divider(height: 28),
                if (dateDebut != null)
                  _infoRow(Icons.play_arrow_outlined, 'Début', fmt.format(dateDebut)),
                if (dateFin != null)
                  _infoRow(Icons.stop_outlined, 'Fin', fmt.format(dateFin)),
                if (ev.lieu != null && ev.lieu!.isNotEmpty)
                  _infoRow(Icons.location_on_outlined, 'Lieu', ev.lieu!),
                _infoRow(Icons.people_outline, 'Participants',
                    '${ev.nbParticipants}'),
                if (ev.createurNom != null)
                  _infoRow(Icons.person_outline, 'Créé par', ev.createurNom!),
                if (ev.description != null && ev.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(ev.description!,
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildConvies(ev),
      ],
    );
  }

  Widget _buildConvies(Evenement ev) {
    final children = <Widget>[];

    if (ev.inviteTous) {
      children.add(_chip('Toute la paroisse', AppTheme.secondaryColor));
    } else {
      for (final r in ev.rolesInvites) {
        children.add(_chip(kRoleLabels[r] ?? r, AppTheme.primaryColor));
      }
      for (final g in ev.groupesInvites) {
        children.add(_chip('Groupe : ${ev.groupesInvitesNoms[g] ?? g}',
            const Color(0xFF00897B)));
      }
      for (final m in ev.membresInvites) {
        children.add(_chip(ev.membresInvitesNoms[m] ?? m, const Color(0xFF6A1B9A)));
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conviés',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            if (children.isEmpty)
              Text('Personne n\'est convié pour le moment.',
                  style: TextStyle(color: AppTheme.textSecondary))
            else
              Wrap(spacing: 8, runSpacing: 8, children: children),
            if (!ev.estPasse) ...[
              const SizedBox(height: 12),
              Text(
                'Utilisez « Modifier » pour ajouter ou retirer des conviés.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.secondaryColor),
          const SizedBox(width: 8),
          Text('$label : ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}
