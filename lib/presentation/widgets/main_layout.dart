import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/auth/auth_bloc.dart';
import 'app_drawer.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final SidebarXController _sidebarController;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Tableau de bord',
      route: '/dashboard',
    ),
    _NavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Membres',
      route: '/membres',
    ),
    _NavItem(
      icon: Icons.group_outlined,
      selectedIcon: Icons.group,
      label: 'Groupes',
      route: '/groupes',
    ),
    _NavItem(
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      label: 'Événements',
      route: '/evenements',
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Finances',
      route: '/finances',
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Librairie',
      route: '/librairie',
    ),
    _NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profil',
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarController = SidebarXController(selectedIndex: 0, extended: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].route)) {
        index = i;
        break;
      }
    }
    if (_sidebarController.selectedIndex != index) {
      _sidebarController.selectIndex(index);
    }
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerThan(TABLET);

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Paroissiale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const AppDrawer(),
      ),
      body: widget.child,
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final location = GoRouterState.of(context).matchedLocation;
              String title = 'Tableau de bord';
              for (final item in _navItems) {
                if (location.startsWith(item.route)) {
                  title = item.label;
                  break;
                }
              }
              return Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state is AuthAuthenticated ? state.user : null;
              return InkWell(
                onTap: () => context.go('/profile'),
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?.firstName.isNotEmpty == true
                        ? user!.firstName[0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return SidebarX(
      controller: _sidebarController,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
          color: AppTheme.sidebarBg,
        ),
        hoverColor: Colors.white.withAlpha(160),
        textStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        itemTextPadding: const EdgeInsets.only(left: 12),
        selectedItemTextPadding: const EdgeInsets.only(left: 12),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.primaryColor,
        ),
        iconTheme: const IconThemeData(color: Colors.white60, size: 20),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 20),
      ),
      extendedTheme: const SidebarXTheme(
        width: 220,
        decoration: BoxDecoration(color: AppTheme.sidebarBg),
      ),
      footerDivider: const Divider(color: Colors.white24, height: 1),
      headerBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: extended
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.church,
                            color: AppTheme.sidebarBg,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Flexible(
                          child: Text(
                            'Gestion\nParoissiale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.church,
                      color: AppTheme.sidebarBg,
                      size: 20,
                    ),
                  ),
                ),
        );
      },
      items: _navItems
          .map(
            (item) => SidebarXItem(
              icon: item.icon,
              iconWidget: Icon(
                _sidebarController.selectedIndex == _navItems.indexOf(item)
                    ? item.selectedIcon
                    : item.icon,
                size: 20,
              ),
              label: item.label,
              onTap: () {
                context.go(item.route);
              },
            ),
          )
          .toList(),
      footerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: extended
              ? BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state is AuthAuthenticated ? state.user : null;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(160),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.secondaryColor,
                            child: Text(
                              user?.firstName.isNotEmpty == true
                                  ? user!.firstName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: AppTheme.sidebarBg,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user?.fullName ?? 'Admin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Administrateur',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white54, size: 16),
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthLogoutRequested());
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Déconnexion',
                          ),
                        ],
                      ),
                    );
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white54),
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  tooltip: 'Déconnexion',
                ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
