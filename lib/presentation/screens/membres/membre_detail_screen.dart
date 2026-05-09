import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/membres/membres_bloc.dart';
import '../../../data/models/membre_model.dart';
import '../../../data/models/sacrement_model.dart';
import '../../widgets/loading_widget.dart';

class MembreDetailScreen extends StatelessWidget {
  final int membreId;

  const MembreDetailScreen({super.key, required this.membreId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MembresBloc>()..add(LoadMembreDetail(id: membreId)),
      child: _MembreDetailView(membreId: membreId),
    );
  }
}

class _MembreDetailView extends StatelessWidget {
  final int membreId;

  const _MembreDetailView({required this.membreId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Détail du membre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/membres'),
        ),
        actions: [
          BlocBuilder<MembresBloc, MembresState>(
            builder: (context, state) {
              if (state is MembreDetailLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/membres/$membreId/edit'),
                  tooltip: 'Modifier',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<MembresBloc, MembresState>(
        listener: (context, state) {
          if (state is MembresError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          if (state is SacrementAjoute) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sacrement ajouté avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.read<MembresBloc>().add(LoadMembreDetail(id: membreId));
          }
        },
        builder: (context, state) {
          if (state is MembresLoading || state is MembresInitial) {
            return const LoadingWidget(message: 'Chargement...');
          }
          if (state is MembreDetailLoaded) {
            return _buildContent(context, state.membre);
          }
          if (state is MembresError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context
                        .read<MembresBloc>()
                        .add(LoadMembreDetail(id: membreId)),
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

  Widget _buildContent(BuildContext context, MembreDetail membre) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildInfoCard(context, membre)),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 3, child: _buildSacrementsCard(context, membre)),
                  ],
                )
              : Column(
                  children: [
                    _buildInfoCard(context, membre),
                    const SizedBox(height: 16),
                    _buildSacrementsCard(context, membre),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, MembreDetail membre) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      membre.prenom.isNotEmpty
                          ? membre.prenom[0].toUpperCase()
                          : 'M',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    membre.nomComplet,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (membre.groupeNom != null) ...[
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(membre.groupeNom!),
                      backgroundColor: AppTheme.primaryColor.withAlpha(26),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 32),
            _infoRow(Icons.calendar_today, 'Date d\'inscription',
                membre.dateInscription),
            if (membre.dateNaissance != null)
              _infoRow(Icons.cake, 'Date de naissance', membre.dateNaissance!),
            _infoRow(
              Icons.person,
              'Sexe',
              membre.sexe == 'M' ? 'Masculin' : 'Féminin',
            ),
            if (membre.telephone != null)
              _infoRow(Icons.phone, 'Téléphone', membre.telephone!),
            if (membre.email != null)
              _infoRow(Icons.email, 'Email', membre.email!),
            if (membre.quartier != null)
              _infoRow(Icons.location_on, 'Quartier', membre.quartier!),
            const Divider(height: 24),
            Row(
              children: [
                _sacrementsChip('Baptisé', membre.estBaptise),
                const SizedBox(width: 8),
                _sacrementsChip('Confirmé', membre.estConfirme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sacrementsChip(String label, bool value) {
    return Chip(
      avatar: Icon(
        value ? Icons.check_circle : Icons.cancel,
        size: 16,
        color: value ? AppTheme.successColor : AppTheme.textSecondary,
      ),
      label: Text(label,
          style: TextStyle(
            fontSize: 12,
            color: value
                ? AppTheme.textPrimary
                : AppTheme.textPrimary.withAlpha(167),
          )),
      backgroundColor: value
          ? AppTheme.successColor.withAlpha(26)
          : AppTheme.textSecondary.withAlpha(26),
    );
  }

  Widget _buildSacrementsCard(BuildContext context, MembreDetail membre) {
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
                const Text(
                  'Sacrements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showAjouterSacrementDialog(context, membre.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (membre.sacrements.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.church,
                          size: 48, color: AppTheme.textSecondary),
                      SizedBox(height: 8),
                      Text(
                        'Aucun sacrement enregistré',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...membre.sacrements.map((s) => _buildSacrementTile(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildSacrementTile(Sacrement sacrement) {
    final icons = {
      'bapteme': Icons.water,
      'mariage': Icons.favorite,
      'confirmation': Icons.verified,
      'communion': Icons.volunteer_activism,
      'funerailles': Icons.spa,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icons[sacrement.type] ?? Icons.church,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        sacrement.typeLabel,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${sacrement.date}', style: const TextStyle(fontSize: 12)),
          if (sacrement.observations != null)
            Text(
              sacrement.observations!,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
        ],
      ),
    );
  }

  void _showAjouterSacrementDialog(BuildContext context, int membreId) {
    final formKey = GlobalKey<FormState>();
    String selectedType = 'bapteme';
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final observationsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Ajouter un sacrement'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration:
                        const InputDecoration(labelText: 'Type de sacrement'),
                    items: AppConstants.sacrementLabels.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedType = v ?? 'bapteme'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      hintText: 'YYYY-MM-DD',
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: observationsController,
                    decoration:
                        const InputDecoration(labelText: 'Observations'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<MembresBloc>().add(
                        AjouterSacrement(
                          membreId: membreId,
                          data: {
                            'type': selectedType,
                            'date': dateController.text,
                            if (observationsController.text.isNotEmpty)
                              'observations': observationsController.text,
                          },
                        ),
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
