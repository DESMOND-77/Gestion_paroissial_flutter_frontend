import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/permissions.dart';
import '../../data/repositories/auth_repository.dart';
import '../blocs/auth/auth_bloc.dart';
import 'user_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Tableau de bord',
                  route: '/dashboard',
                  isSelected: currentLocation == '/dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: 'Membres',
                  route: '/membres',
                  isSelected: currentLocation.startsWith('/membres'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/membres');
                  },
                ),
                _DrawerItem(
                  icon: Icons.group_outlined,
                  label: 'Groupes',
                  route: '/groupes',
                  isSelected: currentLocation.startsWith('/groupes'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/groupes');
                  },
                ),
                _DrawerItem(
                  icon: Icons.event_outlined,
                  label: 'Événements',
                  route: '/evenements',
                  isSelected: currentLocation.startsWith('/evenements'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/evenements');
                  },
                ),
                // Finances : réservé au trésorier et au-dessus (la vue backend
                // elle-même exige IsTreasurerOrAbove).
                if (context.perms.canViewFinances)
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Finances',
                    route: '/finances',
                    isSelected: currentLocation.startsWith('/finances'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/finances');
                    },
                  ),
                _DrawerItem(
                  icon: Icons.menu_book_outlined,
                  label: 'Librairie',
                  route: '/librairie',
                  isSelected: currentLocation.startsWith('/librairie'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/librairie');
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.person_outline,
                  label: 'Mon profil',
                  route: '/profile',
                  isSelected: currentLocation == '/profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
              ],
            ),
          ),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return DrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.sidebarBg, AppTheme.primaryColor],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              UserAvatar(
                imageUrl: user?.profilePictureUrl,
                localImageFile: user != null
                    ? sl<AuthRepository>().getCachedProfilePicture(user.id)
                    : null,
                initials: user?.firstName.isNotEmpty == true
                    ? user!.firstName[0].toUpperCase()
                    : 'U',
                radius: 36,
                backgroundColor: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                user?.fullName ?? 'Administrateur',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppTheme.errorColor),
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(const AuthLogoutRequested());
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppTheme.primaryColor.withAlpha(26) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
