import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/api_client.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../../wisps/domain/wisp.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _notify(BuildContext context, String message, {required Color color}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  Future<void> _testConnection(BuildContext context, WidgetRef ref) async {
    try {
      final data = await ref.read(apiClientProvider).getProtectedData();
      if (context.mounted) _notify(context, 'Success! ${data['message']}', color: Colors.green.shade800);
    } catch (e) {
      if (context.mounted) _notify(context, 'Backend Rejected Request: $e', color: Colors.red.shade800);
    }
  }

  Future<void> _saveWisp(BuildContext context, WidgetRef ref) async {
    try {
      final wisp = await ref.read(recentWispsProvider.notifier).save(
            mood: 'Zen',
            reflection: 'The architecture is pure and the connection is secure. Handshake complete.',
          );
      if (context.mounted) _notify(context, 'Success! Wisp ID: ${wisp.id}', color: Colors.blue.shade800);
    } catch (e) {
      if (context.mounted) _notify(context, 'Failed to Save Wisp: $e', color: Colors.orange.shade900);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wisps = ref.watch(recentWispsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('WISP Dashboard', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.cloud_done_outlined, size: 80, color: Colors.white24),
              const SizedBox(height: 24),
              Text(
                'Security Handshake Ready',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Firebase session is active. You can now securely communicate with the WISP Node.js backend.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54, height: 1.5),
              ),
              const SizedBox(height: 48),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _testConnection(context, ref),
                  child: Text('Test Secure Backend Connection', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent.shade200,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                  ),
                  onPressed: () => _saveWisp(context, ref),
                  child: Text('Save My First Wisp', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT WISPS',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
                    onPressed: () => ref.invalidate(recentWispsProvider),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _RecentWisps(wisps: wisps),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentWisps extends StatelessWidget {
  const _RecentWisps({required this.wisps});

  final AsyncValue<List<Wisp>> wisps;

  @override
  Widget build(BuildContext context) {
    return wisps.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2)),
      ),
      error: (error, _) => _Message(
        icon: Icons.cloud_off_outlined,
        text: 'Could not load your wisps.\n$error',
      ),
      data: (items) => items.isEmpty
          ? const _Message(icon: Icons.auto_awesome_outlined, text: 'No wisps yet. Save your first one above.')
          : Column(children: [for (final wisp in items) _WispTile(wisp: wisp)]),
    );
  }
}

class _WispTile extends StatelessWidget {
  const _WispTile({required this.wisp});

  final Wisp wisp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.shade200.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(wisp.mood, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(_formatDate(wisp.createdAt), style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(wisp.reflection, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} h ago';
    if (difference.inDays < 7) return '${difference.inDays} d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 32),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
