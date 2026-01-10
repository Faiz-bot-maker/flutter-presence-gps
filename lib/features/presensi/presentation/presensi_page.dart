import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/constants.dart';
import 'presensi_provider.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PresensiProvider>();
      provider.getCurrentLocation();
      provider.startLocationUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final maxContentWidth = width >= 900 ? 820.0 : width;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: const Text('Presensi'),
                    centerTitle: false,
                    backgroundColor: scheme.surface,
                    surfaceTintColor: Colors.transparent,
                    titleTextStyle: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          onPressed: () => context.read<PresensiProvider>().getCurrentLocation(),
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Refresh Lokasi',
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Consumer<PresensiProvider>(
                          builder: (context, provider, child) {
                            final isReady = provider.currentPosition != null;
                            final inRadius = provider.isInOfficeRadius;
                            final hasCheckedIn = provider.hasCheckedIn;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Jam Realtime
                                Center(
                                  child: _DigitalClock(color: scheme.primary),
                                ),
                                const SizedBox(height: 24),

                                // 2. Status Card (Lampu & Map)
                                Card(
                                  elevation: 0,
                                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        // Lampu Status Masuk/Belum
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: hasCheckedIn ? Colors.green : Colors.red,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (hasCheckedIn ? Colors.green : Colors.red).withValues(alpha: 0.5),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              hasCheckedIn ? 'SUDAH MASUK' : 'BELUM MASUK',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: hasCheckedIn ? Colors.green : Colors.red,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        const Divider(),
                                        const SizedBox(height: 20),
                                        
                                        // MAP WIDGET (Pengganti Info Jarak)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: SizedBox(
                                            height: 250, // Tinggi map
                                            child: _OfficeMap(
                                              currentLatLng: provider.currentPosition != null
                                                  ? LatLng(provider.currentPosition!.latitude, provider.currentPosition!.longitude)
                                                  : null,
                                              inRadius: inRadius,
                                            ),
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),

                                // 3. Tombol Aksi
                                Text(
                                  'Aksi Presensi',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    // Tombol Masuk selalu ada
                                    Expanded(
                                      child: _PresenceButton(
                                        label: 'Absen Masuk',
                                        icon: Icons.login_rounded,
                                        color: Colors.green,
                                        onPressed: provider.isLoading || !isReady || !inRadius
                                            ? null
                                            : () async {
                                                await provider.submitPresensi('MASUK');
                                                if (!context.mounted) return;
                                                _showResultSnack(context, provider.message, scheme);
                                              },
                                        isLoading: provider.isLoading,
                                      ),
                                    ),
                                    
                                    // Tombol Keluar: Hanya muncul jika hasCheckedIn
                                    if (hasCheckedIn) ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _PresenceButton(
                                          label: 'Absen Keluar',
                                          icon: Icons.logout_rounded,
                                          color: Colors.red,
                                          isOutlined: true,
                                          onPressed: provider.isLoading || !isReady || !inRadius
                                              ? null
                                              : () async {
                                                  await provider.submitPresensi('KELUAR');
                                                  if (!context.mounted) return;
                                                  _showResultSnack(context, provider.message, scheme);
                                                },
                                          isLoading: provider.isLoading,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                
                                // Pesan error/info tambahan di bawah
                                if (provider.message.isNotEmpty) ...[
                                   const SizedBox(height: 16),
                                   Center(
                                     child: Text(
                                       provider.message,
                                       textAlign: TextAlign.center,
                                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                         color: scheme.onSurfaceVariant,
                                       ),
                                     ),
                                   ),
                                ],
                              ],
                            );
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DigitalClock extends StatelessWidget {
  final Color color;
  
  const _DigitalClock({required this.color});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final hour = now.hour.toString().padLeft(2, '0');
        final minute = now.minute.toString().padLeft(2, '0');
        final second = now.second.toString().padLeft(2, '0');
        
        return Column(
          children: [
            Text(
              '$hour:$minute:$second',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            Text(
              _formatDate(now),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    
    final dayName = days[date.weekday - 1];
    final day = date.day;
    final monthName = months[date.month - 1];
    final year = date.year;
    
    return '$dayName, $day $monthName $year';
  }
}

class _OfficeMap extends StatelessWidget {
  final LatLng? currentLatLng;
  final bool inRadius;

  const _OfficeMap({required this.currentLatLng, required this.inRadius});

  @override
  Widget build(BuildContext context) {
    final officeLatLng = LatLng(Constants.officeLatitude, Constants.officeLongitude);
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: officeLatLng,
        initialZoom: 16.0,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.presence_glosindo',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: officeLatLng,
              color: Colors.blue.withValues(alpha: 0.1),
              borderStrokeWidth: 2,
              borderColor: Colors.blue,
              useRadiusInMeter: true,
              radius: Constants.maxDistanceInMeters, // Radius kantor
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            // Marker Kantor
            Marker(
              point: officeLatLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.business_rounded, color: Colors.blue, size: 40),
            ),
            // Marker User
            if (currentLatLng != null)
              Marker(
                point: currentLatLng!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Icon(
                    Icons.person_pin_circle_rounded, 
                    color: inRadius ? Colors.green : Colors.red, 
                    size: 32
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PresenceButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;

  const _PresenceButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  State<_PresenceButton> createState() => _PresenceButtonState();
}

class _PresenceButtonState extends State<_PresenceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final theme = Theme.of(context);
    final effectiveColor = isDisabled ? theme.disabledColor : widget.color;
    
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _controller.forward(),
      onTapUp: isDisabled ? null : (_) => _controller.reverse(),
      onTapCancel: isDisabled ? null : () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isOutlined 
                ? theme.colorScheme.surface 
                : effectiveColor,
            borderRadius: BorderRadius.circular(20),
            border: widget.isOutlined
                ? Border.all(color: effectiveColor.withValues(alpha: 0.5), width: 2)
                : null,
            boxShadow: isDisabled || widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
            gradient: widget.isOutlined || isDisabled
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      effectiveColor.withValues(alpha: 0.8),
                      effectiveColor,
                    ],
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: widget.isOutlined ? effectiveColor : Colors.white,
                  ),
                )
              else
                Icon(
                  widget.icon,
                  size: 32,
                  color: widget.isOutlined ? effectiveColor : Colors.white,
                ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isOutlined ? effectiveColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showResultSnack(BuildContext context, String message, ColorScheme scheme) {
  final isSuccess = message.toLowerCase().contains('berhasil');
  final bg = isSuccess ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12);
  final fg = isSuccess ? Colors.green : Colors.red;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: scheme.surface,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fg.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_rounded, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
