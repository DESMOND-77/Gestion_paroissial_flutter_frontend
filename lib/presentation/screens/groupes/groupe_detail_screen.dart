import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../blocs/groupes/groupes_bloc.dart';
import '../../../data/models/groupe_model.dart';
import '../../../data/models/membre_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/user_avatar.dart';

/// Détail d'un groupe : ses informations, son responsable et l'ensemble de ses
/// membres.
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

class _GroupeDetailView extends StatelessWidget {
  final String groupeId;

  const _GroupeDetailView({required this.groupeId});

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
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () => context.push('/groupes/$groupeId/edit'),
          ),
        ],
      ),
      body: BlocBuilder<GroupesBloc, GroupesState>(
        builder: (context, state) {
          if (state is GroupesLoading || state is GroupesInitial) {
            return const LoadingWidget(message: 'Chargement...');
          }
          if (state is GroupeDetailLoaded) {
            return _buildContent(context, state.groupe, state.membres ?? []);
          }
          if (state is GroupesError) {
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
                        .read<GroupesBloc>()
                        .add(LoadGroupeDetail(id: groupeId)),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Groupe groupe, List<Membre> membres) {
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
                      child: Text(
                        groupe.nom,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (groupe.description != null &&
                    groupe.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(groupe.description!,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ],
                const Divider(height: 28),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined,
                        size: 18, color: AppTheme.secondaryColor),
                    const SizedBox(width: 8),
                    const Text('Responsable : ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(
                        groupe.responsableNom ?? 'Non défini',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('Membres',
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
          ],
        ),
        const SizedBox(height: 8),
        if (membres.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Aucun membre dans ce groupe',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
          )
        else
          ...membres.map((m) => _membreTile(context, m)),
      ],
    );
  }

  Widget _membreTile(BuildContext context, Membre membre) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
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
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => context.push('/membres/${membre.id}'),
      ),
    );
  }
}
