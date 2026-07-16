import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paroisse_gest/core/auth/permissions.dart';
import 'package:paroisse_gest/core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(const LoadDashboard()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const LoadingWidget(
                message: 'Chargement du tableau de bord...');
          }
          if (state is DashboardError) {
            return _buildError(context, state.message);
          }
          if (state is DashboardLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<DashboardBloc>().add(const LoadDashboard()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    final formatter = AppConstants.formatter;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboard());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 24),
            _buildStatsGrid(context, state, formatter),
            const SizedBox(height: 24),
            _buildChartsRow(context, state),
            const SizedBox(height: 24),
            _buildRecentActivity(context, state, formatter),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final now = DateTime.now();
        final greeting = now.hour < 12
            ? 'Bonjour'
            : now.hour < 18
                ? 'Bon après-midi'
                : 'Bonsoir';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user?.firstName ?? 'Administrateur'} !',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(now),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    DashboardLoaded state,
    NumberFormat formatter,
  ) {
    final cards = [
      _StatCardData(
        title: 'Total Membres',
        value: state.totalMembres.toString(),
        icon: Icons.people,
        color: AppTheme.primaryColor,
        route: '/membres',
      ),
      _StatCardData(
        title: 'Groupes',
        value: state.totalGroupes.toString(),
        icon: Icons.group,
        color: const Color(0xFF00897B),
        route: '/groupes',
      ),
      _StatCardData(
        title: 'Événements à venir',
        value: state.evenementsAVenir.toString(),
        icon: Icons.event,
        color: const Color(0xFFE65100),
        route: '/evenements',
      ),
      _StatCardData(
        title: 'Balance financière',
        value: formatter.format(state.balanceFinanciere),
        icon: Icons.account_balance_wallet,
        color: state.balanceFinanciere >= 0
            ? AppTheme.successColor
            : AppTheme.errorColor,
        route: '/finances',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 500;
        final maxCrossAxisExtent = isSmall ? 250.0 : 280.0;
        final childAspectRatio = isSmall ? 1.0 : 1.5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return StatCard(
              title: card.title,
              value: card.value,
              icon: card.icon,
              color: card.color,
              onTap: () => context.go(card.route),
            );
          },
        );
      },
    );
  }

  Widget _buildChartsRow(BuildContext context, DashboardLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildBarChart(context, state)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildPieChart(context, state)),
            ],
          );
        }
        return Column(
          children: [
            _buildBarChart(context, state),
            const SizedBox(height: 16),
            _buildPieChart(context, state),
          ],
        );
      },
    );
  }

  Widget _buildBarChart(BuildContext context, DashboardLoaded state) {
    final formatter = NumberFormat.compact(locale: 'fr_FR');

    // Build last 6 months data
    final now = DateTime.now();
    final months = <String>[];
    final recettesData = <double>[];
    final depensesData = <double>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMM', 'fr_FR').format(month));
      final key = DateFormat('yyyy-MM', 'fr_FR').format(month);

      final monthData = state.recettesDepensesParMois.firstWhere(
        (m) => m['mois'] == key || m['month'] == key,
        orElse: () => <String, dynamic>{},
      );

      recettesData.add((monthData['recettes'] as num?)?.toDouble() ?? 0.0);
      depensesData.add((monthData['depenses'] as num?)?.toDouble() ?? 0.0);
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
                const Text(
                  'Recettes vs Dépenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildLegendItem('Recettes', AppTheme.successColor),
                const SizedBox(width: 12),
                _buildLegendItem('Dépenses', AppTheme.errorColor),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '6 derniers mois',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = rodIndex == 0 ? 'Recettes' : 'Dépenses';
                        return BarTooltipItem(
                          '$label\n${formatter.format(rod.toY)} FCFA',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formatter.format(value),
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textSecondary),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < months.length) {
                            return Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(months.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: recettesData[i],
                          color: AppTheme.successColor,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: depensesData[i],
                          color: AppTheme.errorColor,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
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
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, DashboardLoaded state) {
    final categories = state.depensesParCategorie.entries.toList();
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.successColor,
      AppTheme.errorColor,
      const Color(0xFF00897B),
      const Color(0xFF6A1B9A),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition par catégorie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Toutes transactions',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Aucune donnée',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else ...[
              SizedBox(
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(categories.length, (i) {
                      final entry = categories[i];
                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: entry.value,
                        title: '',
                        radius: 50,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(categories.length, (i) {
                final entry = categories[i];
                final label = {
                      'quete': 'Quête',
                      'don': 'Don',
                      'location': 'Location',
                      'librairie': 'Librairie',
                      'autre': 'Autre',
                    }[entry.key] ??
                    entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ),
                      Text(
                        NumberFormat.compact(locale: 'fr_FR')
                            .format(entry.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    DashboardLoaded state,
    NumberFormat formatter,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.perms.canViewFinances) ...[
              Row(
                children: [
                  const Text(
                    'Transactions récentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/finances'),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.recentTransactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aucune transaction récente',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ...state.recentTransactions.take(5).map((tx) {
                  final isRecette = tx.isRecette;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isRecette
                                ? AppTheme.successColor
                                : AppTheme.errorColor)
                            .withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isRecette ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isRecette
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tx.categorieLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${tx.date}${tx.description != null ? ' · ${tx.description}' : ''}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    trailing: Text(
                      '${isRecette ? '+' : '-'} ${formatter.format(tx.montant)}',
                      style: TextStyle(
                        color: isRecette
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }),
            ],
            if (state.prochainEvenements.isNotEmpty) ...[
              const Divider(height: 32),
              Row(
                children: [
                  const Text(
                    'Prochains événements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/evenements'),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...state.prochainEvenements.map((ev) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    ev.titre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${ev.typeDisplay ?? ev.type} · ${ev.lieu ?? ''}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  trailing: Text(
                    DateFormat('dd MMM', 'fr_FR').format(
                      DateTime.tryParse(ev.dateDebut) ?? DateTime.now(),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String route;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.route,
  });
}
