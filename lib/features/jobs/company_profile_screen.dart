import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';

class CompanyProfileScreen extends ConsumerWidget {
  const CompanyProfileScreen({super.key, required this.employerId});

  final String employerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: StreamBuilder(
        stream: ref.watch(userRepositoryProvider).watchEmployerProfile(employerId),
        builder: (context, snap) {
          if (!snap.hasData) return const LoadingView();
          final p = snap.data;
          if (p == null) return EmptyState(message: l10n.errorGeneric);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DesignGradientHeader(
                  height: 180,
                  imageUrl: p.coverUrl.isNotEmpty ? p.coverUrl : null,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: const Offset(0, 40),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surface,
                        backgroundImage: ProfileImage.provider(p.logoUrl),
                        child: p.logoUrl.isEmpty
                            ? const Icon(Icons.business, size: 40)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 48)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.verified, color: AppColors.warning, size: 20),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    p.sector,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DesignSectionCard(
                      title: l10n.aboutCompany,
                      child: Text(p.about),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.companyActivity,
                      child: Text(p.activity),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.servicesOffered,
                      child: Text(p.servicesOffered),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.operatingHours,
                      child: Text(p.operatingHours),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.location,
                      child: Text(p.hqAddress),
                    ),
                    if (p.website.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DesignSectionCard(
                        title: 'Website',
                        child: Text(p.website),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
