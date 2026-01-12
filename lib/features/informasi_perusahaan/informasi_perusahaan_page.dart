import 'package:flutter/material.dart';

class InformasiPerusahaanPage extends StatelessWidget {
  const InformasiPerusahaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Informasi Perusahaan'),
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
                const _CompanyHeroImage(),
                const SizedBox(height: 32),
                Text(
                  'Profil Perusahaan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface.withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 16),
                _InfoCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= HERO IMAGE ================= */

class _CompanyHeroImage extends StatelessWidget {
  const _CompanyHeroImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Image.network(
              'https://k2space.imgix.net/app/uploads/2023/06/K2-Criteo-Office-Curator-LARGE-102-scaled.jpg?auto=format&fit=max&q=90&w=5000',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PT. Glosindo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Solusi Teknologi & Informasi Terpercaya',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

/* ================= INFO CARD ================= */

class _InfoCard extends StatelessWidget {
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
      child: const Column(
        children: [
          _InfoTile(
            icon: Icons.location_on_rounded,
            title: 'Alamat Kantor',
            value: 'Jl. Sudirman No. 1, Jakarta Pusat, DKI Jakarta',
            color: Color(0xFF2563EB),
          ),
          Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.phone_rounded,
            title: 'Telepon',
            value: '(021) 1234-5678',
            color: Color(0xFF2563EB),
          ),
          Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.language_rounded,
            title: 'Website',
            value: 'www.glosindo.com',
            color: Color(0xFF2563EB),
          ),
          Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.visibility_rounded,
            title: 'Visi',
            value: 'Menjadi perusahaan teknologi terdepan di Indonesia.',
            color: Color(0xFF2563EB),
          ),
          Divider(height: 1, indent: 64),
          _InfoTile(
            icon: Icons.flag_rounded,
            title: 'Misi',
            value: 'Memberikan solusi digital terbaik bagi masyarakat.',
            color: Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}

/* ================= INFO TILE ================= */

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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
