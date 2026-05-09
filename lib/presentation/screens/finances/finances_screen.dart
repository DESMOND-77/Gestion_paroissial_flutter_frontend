import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/app_constants.dart';
import '../../blocs/finances/finances_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../widgets/loading_widget.dart';

class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FinancesBloc>()..add(const LoadRapportFinancier()),
      child: const _FinancesView(),
    );
  }
}

class _FinancesView extends StatefulWidget {
  const _FinancesView();

  @override
  State<_FinancesView> createState() => _FinancesViewState();
}

class _FinancesViewState extends State<_FinancesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  RapportFinancier? _rapport;
  String? _filterType;
  String? _filterCategorie;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteTransaction(BuildContext ctx, int id) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Supprimer cette transaction ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<FinancesBloc>().add(DeleteTransaction(id: id));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return BlocConsumer<FinancesBloc, FinancesState>(
      listener: (context, state) {
        if (state is RapportFinancierLoaded) {
          setState(() {
            _transactions = state.transactions;
            _rapport = state.rapport;
          });
        }
        if (state is TransactionsLoaded) {
          setState(() => _transactions = state.transactions);
        }
        if (state is TransactionDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction supprimée'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.read<FinancesBloc>().add(const LoadRapportFinancier());
        }
        if (state is FinancesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is FinancesLoading;

        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          body: Column(
            children: [
              if (_rapport != null) _buildSummaryCards(_rapport!, formatter),
              _buildFilterBar(context),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Transactions'),
                  Tab(text: 'Rapport graphique'),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const LoadingWidget(message: 'Chargement...')
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTransactionsTable(context, formatter),
                          _buildRapportChart(context, formatter),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/finances/new'),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle transaction'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(RapportFinancier rapport, NumberFormat formatter) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryChip(
              label: 'Recettes',
              amount: formatter.format(rapport.totalRecettes),
              color: AppTheme.successColor,
              icon: Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryChip(
              label: 'Dépenses',
              amount: formatter.format(rapport.totalDepenses),
              color: AppTheme.errorColor,
              icon: Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryChip(
              label: 'Balance',
              amount: formatter.format(rapport.balance),
              color: rapport.balance >= 0 ? AppTheme.primaryColor : AppTheme.errorColor,
              icon: Icons.account_balance_wallet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          DropdownButton<String?>(
            value: _filterType,
            hint: const Text('Type'),
            isDense: true,
            items: [
              const DropdownMenuItem(value: null, child: Text('Tous types')),
              ...AppConstants.transactionTypes.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: (v) {
              setState(() => _filterType = v);
              context.read<FinancesBloc>().add(
                    LoadTransactions(type: v, categorie: _filterCategorie),
                  );
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<String?>(
            value: _filterCategorie,
            hint: const Text('Catégorie'),
            isDense: true,
            items: [
              const DropdownMenuItem(value: null, child: Text('Toutes catégories')),
              ...AppConstants.transactionCategories.entries.map(
                (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
              ),
            ],
            onChanged: (v) {
              setState(() => _filterCategorie = v);
              context.read<FinancesBloc>().add(
                    LoadTransactions(type: _filterType, categorie: v),
                  );
            },
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _filterType = null;
                _filterCategorie = null;
              });
              context.read<FinancesBloc>().add(const LoadRapportFinancier());
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable(BuildContext context, NumberFormat formatter) {
    if (_transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('Aucune transaction', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withAlpha(30)),
          columns: const [
            DataColumn2(label: Text('Date'), size: ColumnSize.S),
            DataColumn2(label: Text('Type'), size: ColumnSize.S),
            DataColumn2(label: Text('Catégorie'), size: ColumnSize.M),
            DataColumn2(label: Text('Description'), size: ColumnSize.L),
            DataColumn2(label: Text('Montant'), size: ColumnSize.M, numeric: true),
            DataColumn2(label: Text('Membre'), size: ColumnSize.M),
            DataColumn2(label: Text('Actions'), size: ColumnSize.S, fixedWidth: 80),
          ],
          rows: _transactions.map((tx) {
            return DataRow2(
              cells: [
                DataCell(Text(tx.date, style: const TextStyle(fontSize: 12))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (tx.isRecette ? AppTheme.successColor : AppTheme.errorColor)
                          .withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tx.typeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: tx.isRecette ? AppTheme.successColor : AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(tx.categorieLabel, style: const TextStyle(fontSize: 12))),
                DataCell(Text(tx.description ?? '-', style: const TextStyle(fontSize: 12))),
                DataCell(
                  Text(
                    formatter.format(tx.montant),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: tx.isRecette ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ),
                ),
                DataCell(Text(tx.membreNom ?? '-', style: const TextStyle(fontSize: 12))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => context.push('/finances/${tx.id}/edit'),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16, color: AppTheme.errorColor),
                        onPressed: () => _deleteTransaction(context, tx.id),
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

  Widget _buildRapportChart(BuildContext context, NumberFormat formatter) {
    if (_rapport == null) {
      return const Center(child: Text('Aucun rapport disponible'));
    }

    final rapport = _rapport!;
    final categories = rapport.parCategorie.entries.toList();
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.successColor,
      AppTheme.errorColor,
      const Color(0xFF00897B),
      const Color(0xFF6A1B9A),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Répartition par catégorie',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (categories.isEmpty)
                    const Center(
                      child: Text('Aucune donnée', style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final label = categories[group.x].key;
                                return BarTooltipItem(
                                  '$label\n${formatter.format(rod.toY)}',
                                  const TextStyle(color: Colors.white, fontSize: 12),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) => Text(
                                  NumberFormat.compact(locale: 'fr_FR').format(value),
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                ),
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < categories.length) {
                                    final label = AppConstants.transactionCategories[categories[i].key] ?? categories[i].key;
                                    return Text(
                                      label,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(categories.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: categories[i].value,
                                  color: colors[i % colors.length],
                                  width: 30,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
