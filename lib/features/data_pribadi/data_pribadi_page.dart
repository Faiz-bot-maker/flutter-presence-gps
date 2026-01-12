import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_session.dart';

class DataPribadiPage extends StatelessWidget {
  const DataPribadiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthSession>().currentUser;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Data Pribadi'),
            centerTitle: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileHeader(user: user),
                const SizedBox(height: 24),
                Text(
                  'Informasi Dasar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface.withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 16),
                _InfoCard(user: user),
                const SizedBox(height: 24),

                /// LOGOUT DI PALING BAWAH
                _LogoutTile(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// PROFILE HEADER
/// ======================
class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFE0E7FF),
              backgroundImage: NetworkImage(
                user?.profileImage ?? 'https://i.pravatar.cc/150?img=11',
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Muhammad Faiz Fathurahman',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role ?? 'Mobile Developer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// INFO CARD
/// ======================
class _InfoCard extends StatelessWidget {
  final UserModel? user;
  const _InfoCard({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.badge_rounded,
            title: 'Nama Lengkap',
            value: user?.name ?? 'Muhammad Faiz Fathurahman',
            color: const Color(0xFF2563EB),
          ),
          const Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.credit_card_rounded,
            title: 'NIK',
            value: user?.nik ?? '1234567890',
            color: const Color(0xFF2563EB),
          ),
          const Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.work_rounded,
            title: 'Jabatan',
            value: user?.role ?? 'Mobile Developer',
            color: const Color(0xFF2563EB),
          ),
          const Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.email_rounded,
            title: 'Email',
            value: user?.email ?? 'faiz.dev@glosindo.com',
            color: const Color(0xFF2563EB),
          ),
          const Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.schedule_rounded,
            title: 'Shift Kerja',
            value: user?.shift ?? 'Shift Pagi',
            color: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// INFO TILE
/// ======================
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// LOGOUT TILE (PALING BAWAH)
/// ======================
class _LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.read<AuthSession>().logout();
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Keluar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
