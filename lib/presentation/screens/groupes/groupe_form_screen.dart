import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../blocs/groupes/groupes_bloc.dart';
import '../../widgets/loading_widget.dart';

class GroupeFormScreen extends StatelessWidget {
  final int? groupeId;

  const GroupeFormScreen({super.key, this.groupeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<GroupesBloc>();
        if (groupeId != null) bloc.add(LoadGroupeDetail(id: groupeId!));
        return bloc;
      },
      child: _GroupeFormView(groupeId: groupeId),
    );
  }
}

class _GroupeFormView extends StatefulWidget {
  final int? groupeId;
  const _GroupeFormView({this.groupeId});

  @override
  State<_GroupeFormView> createState() => _GroupeFormViewState();
}

class _GroupeFormViewState extends State<_GroupeFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _dataLoaded = false;

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nomController.text.trim(),
        if (_descriptionController.text.isNotEmpty)
          'description': _descriptionController.text.trim(),
      };
      if (widget.groupeId != null) {
        context.read<GroupesBloc>().add(UpdateGroupe(id: widget.groupeId!, data: data));
      } else {
        context.read<GroupesBloc>().add(CreateGroupe(data: data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.groupeId != null;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le groupe' : 'Nouveau groupe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/groupes'),
        ),
      ),
      body: BlocConsumer<GroupesBloc, GroupesState>(
        listener: (context, state) {
          if (state is GroupeDetailLoaded && !_dataLoaded) {
            _nomController.text = state.groupe.nom;
            _descriptionController.text = state.groupe.description ?? '';
            setState(() => _dataLoaded = true);
          }
          if (state is GroupeCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Groupe créé avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/groupes');
          }
          if (state is GroupeUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Groupe modifié avec succès'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            context.go('/groupes');
          }
          if (state is GroupesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          if (isEdit && state is GroupesLoading && !_dataLoaded) {
            return const LoadingWidget(message: 'Chargement...');
          }
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
                          Text(
                            isEdit ? 'Modifier le groupe' : 'Informations du groupe',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: 'Nom du groupe *',
                              prefixIcon: Icon(Icons.group_outlined),
                            ),
                            validator: (v) => v?.isEmpty == true ? 'Le nom est requis' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              prefixIcon: Icon(Icons.description_outlined),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go('/groupes'),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: 12),
                              BlocBuilder<GroupesBloc, GroupesState>(
                                builder: (context, state) {
                                  final isLoading = state is GroupesLoading;
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
}
