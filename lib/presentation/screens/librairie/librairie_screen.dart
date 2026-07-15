import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paroisse_gest/core/constants/app_constants.dart';
import 'package:paroisse_gest/presentation/widgets/auto_scrolling_text.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/permissions.dart';
import '../../../data/models/article_model.dart';
import '../../../data/models/vente_model.dart';
import '../../blocs/librairie/librairie_bloc.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/refresh_wrapper.dart';

class LibrairieScreen extends StatefulWidget {
  const LibrairieScreen({super.key});

  @override
  State<LibrairieScreen> createState() => _LibrairieScreenState();
}

class _LibrairieScreenState extends State<LibrairieScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final LibrairieBloc _bloc;
  final _searchController = TextEditingController();
  String? _selectedCategorie;

  static const _categories = [
    {'value': 'livre', 'label': 'Livre'},
    {'value': 'bougie', 'label': 'Bougie'},
    {'value': 'chapelet', 'label': 'Chapelet'},
    {'value': 'vetement', 'label': 'Vêtement'},
    {'value': 'autre', 'label': 'Autre'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bloc = context.read<LibrairieBloc>();
    _bloc.add(const LoadArticles());
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0:
        _bloc.add(LoadArticles(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          categorie: _selectedCategorie,
        ));
        break;
      case 1:
        _bloc.add(const LoadVentes());
        break;
      case 2:
        _bloc.add(const LoadAlertes());
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshArticles() async {
    _bloc.add(LoadArticles(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      categorie: _selectedCategorie,
    ));
    await _bloc.stream
        .firstWhere((s) => s is ArticlesLoaded || s is LibrairieError);
  }

  Future<void> _refreshVentes() async {
    _bloc.add(const LoadVentes());
    await _bloc.stream
        .firstWhere((s) => s is VentesLoaded || s is LibrairieError);
  }

  Future<void> _refreshAlertes() async {
    _bloc.add(const LoadAlertes());
    await _bloc.stream
        .firstWhere((s) => s is AlertesLoaded || s is LibrairieError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: Column(
        children: [
          _buildHeader(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Articles'),
              Tab(text: 'Ventes'),
              Tab(text: 'Alertes stock'),
            ],
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
          ),
          Expanded(
            child: BlocConsumer<LibrairieBloc, LibrairieState>(
              listener: (context, state) {
                if (state is LibrairieError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                } else if (state is ArticleDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Article supprimé'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  _bloc.add(const LoadArticles());
                } else if (state is ArticleCreated || state is ArticleUpdated) {
                  _bloc.add(const LoadArticles());
                } else if (state is VenteCreated) {
                  _bloc.add(const LoadVentes());
                }
              },
              builder: (context, state) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildArticlesTab(state),
                    _buildVentesTab(state),
                    _buildAlertesTab(state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (_) {
                if (_tabController.index == 0) {
                  _bloc.add(LoadArticles(
                    search: _searchController.text.isEmpty
                        ? null
                        : _searchController.text,
                    categorie: _selectedCategorie,
                  ));
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategorie,
              decoration: const InputDecoration(
                hintText: 'Catégorie',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Toutes')),
                ..._categories.map(
                  (c) => DropdownMenuItem(
                    value: c['value'],
                    child: Text(c['label']!),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedCategorie = val);
                if (_tabController.index == 0) {
                  _bloc.add(LoadArticles(
                    search: _searchController.text.isEmpty
                        ? null
                        : _searchController.text,
                    categorie: val,
                  ));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab(LibrairieState state) {
    if (state is LibrairieLoading) return const LoadingWidget();

    final articles = state is ArticlesLoaded ? state.articles : <Article>[];

    if (articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshArticles,
        child: _buildEmpty('Aucun article trouvé', Icons.menu_book_outlined),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshArticles,
      child: DataTable2(
      columnSpacing: 16,
      horizontalMargin: 12,
      minWidth: 400,
      headingRowColor:
          WidgetStateProperty.all(AppTheme.primaryColor.withAlpha(25)),
      columns: const [
        DataColumn2(label: Text('Nom'), size: ColumnSize.L),
        DataColumn2(label: Text('Catégorie'), size: ColumnSize.M),
        DataColumn2(label: Text('Prix'), size: ColumnSize.M, numeric: true),
        DataColumn2(label: Text('Stock'), size: ColumnSize.S, numeric: true),
        DataColumn2(
            label: Text('Actions'), size: ColumnSize.S, fixedWidth: 105),
      ],
      rows: articles.map((a) => _buildArticleRow(a)).toList(),
      ),
    );
  }

  DataRow2 _buildArticleRow(Article article) {
    final isLow = article.enAlerte;
    final formatter = AppConstants.formatter;
    return DataRow2(
      cells: [
        DataCell(
          Row(
            children: [
              if (isLow)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.warning_amber_rounded,
                      color: AppTheme.warningColor, size: 16),
                ),
              Flexible(child: Text(article.nom)),
            ],
          ),
        ),
        DataCell(
          Chip(
              label: Text(article.categorieLabel),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              backgroundColor: AppTheme.primaryColor.withAlpha(38),
              labelStyle: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
        ),
        DataCell(AutoScrollingText(
            scrollDuration: const Duration(seconds: 1),
            pauseDuration: const Duration(seconds: 1),
            child: AutoSizeText(
              formatter.format(article.prixUnitaire),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ))),
        DataCell(Text(
          article.stockDisponible.toString(),
          style: TextStyle(
            color: isLow ? AppTheme.warningColor : AppTheme.textPrimary,
            fontWeight: isLow ? FontWeight.bold : FontWeight.normal,
          ),
        )),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (context.perms.canManageLibrairie)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () =>
                      context.go('/librairie/articles/${article.id}/edit'),
                  tooltip: 'Modifier',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              if (context.perms.canDeleteLibrairie)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppTheme.errorColor),
                  onPressed: () => _confirmDelete(article),
                  tooltip: 'Supprimer',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVentesTab(LibrairieState state) {
    if (state is LibrairieLoading) return const LoadingWidget();

    final ventes = state is VentesLoaded ? state.ventes : <Vente>[];

    if (ventes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshVentes,
        child: _buildEmpty(
            'Aucune vente enregistrée', Icons.shopping_cart_outlined),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVentes,
      child: DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      headingRowColor: WidgetStateProperty.all(
        AppTheme.primaryColor.withAlpha(20),
      ),
      columns: const [
        DataColumn2(label: Text('Article'), size: ColumnSize.L),
        DataColumn2(label: Text('Membre'), size: ColumnSize.M),
        DataColumn2(label: Text('Qté'), size: ColumnSize.S, numeric: true),
        DataColumn2(label: Text('Total'), size: ColumnSize.M, numeric: true),
        DataColumn2(label: Text('Date'), size: ColumnSize.M),
      ],
      rows: ventes.map((v) {
        final date = DateTime.tryParse(v.date);
        final dateStr =
            date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : v.date;
        final formater = AppConstants.formatter;
        return DataRow2(
          cells: [
            DataCell(Text(v.articleNom)),
            DataCell(Text(v.membreNom ?? '—')),
            DataCell(Text(v.quantite.toString())),
            DataCell(AutoScrollingText(
                scrollDuration: const Duration(seconds: 1),
                pauseDuration: const Duration(seconds: 1),
                child: AutoSizeText(
                  formater.format(v.prixTotal),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ))),
            DataCell(Text(dateStr, style: const TextStyle(fontSize: 12))),
          ],
        );
      }).toList(),
      ),
    );
  }

  Widget _buildAlertesTab(LibrairieState state) {
    if (state is LibrairieLoading) return const LoadingWidget();

    final articles = state is AlertesLoaded ? state.articles : <Article>[];

    if (articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshAlertes,
        child: _buildEmpty(
          'Aucune alerte de stock',
          Icons.check_circle_outline,
          color: AppTheme.successColor,
          subtitle: 'Tous les stocks sont suffisants',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlertes,
      child: ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.warningColor.withAlpha(38),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningColor,
              ),
            ),
            title: Text(article.nom,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${article.categorieLabel} · Stock: ${article.stockDisponible} / Seuil: ${article.seuilAlerte}'),
            trailing: context.perms.canManageLibrairie
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Réapprovisionner'),
                    onPressed: () =>
                        context.go('/librairie/articles/${article.id}/edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                : null,
          ),
        );
      },
      ),
    );
  }

  Widget _buildEmpty(String message, IconData icon,
      {Color color = AppTheme.textSecondary, String? subtitle}) {
    return RefreshableEmpty(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color.withAlpha(128)),
          const SizedBox(height: 16),
          Text(message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  Widget? _buildFAB() {
    // Nouvelle vente / ajout d'article = IsSecretaryOrAbove côté backend.
    if (!context.perms.canManageLibrairie) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'Options',
          onPressed: () => {},
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.sidebarBg,
          child: PopupMenuButton<String>(
            elevation: 4,
            color: AppTheme.secondaryColor,
            onSelected: (value) {
              if (value == 'sell') {
                context.go('/librairie/ventes/new');
              } else if (value == 'add') {
                context.go('/librairie/articles/new');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'sell',
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined),
                      Text('Nouvelle vente'),
                    ],
                  )),
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    Text('Ajouter article'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(Article article) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'article'),
        content: Text('Voulez-vous supprimer "${article.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bloc.add(DeleteArticle(id: article.id));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
