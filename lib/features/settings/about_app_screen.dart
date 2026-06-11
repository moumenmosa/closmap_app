import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../l10n/app_localizations.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: DesignAppBar(title: l10n.aboutApp),
      body: Column(
        children: [
          const _AboutHero(),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aboutUs,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.aboutAppBody,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.aboutAppBodySecondary,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0F2B),
            Color(0xFF1A2A6C),
            AppColors.teal,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.chat,
                onTap: () => launchUrl(
                  Uri.parse('https://wa.me/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SocialIcon(
                icon: Icons.facebook,
                onTap: () => launchUrl(
                  Uri.parse('https://facebook.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SocialIcon(
                icon: Icons.camera_alt_outlined,
                onTap: () => launchUrl(
                  Uri.parse('https://instagram.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SocialIcon(
                icon: Icons.photo_camera_outlined,
                onTap: () => launchUrl(
                  Uri.parse('https://snapchat.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
