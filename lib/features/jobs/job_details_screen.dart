import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/employer_profile.dart';
import '../../core/models/job_post.dart';
import '../../core/models/app_user.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/utils/subscription_utils.dart';
import '../../core/widgets/apply_success_dialog.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  const JobDetailsScreen({
    super.key,
    required this.jobId,
    this.initialJob,
  });

  final String jobId;
  final JobPost? initialJob;

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  JobPost? _job;
  EmployerProfile? _employer;
  bool _applied = false;
  bool _saved = false;
  bool _loading = false;
  bool _loadComplete = false;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    JobPost? job = widget.initialJob;
    if (job == null || job.id != widget.jobId) {
      try {
        job = await ref.read(jobRepositoryProvider).getJob(widget.jobId);
      } catch (_) {
        job = null;
      }
    }

    if (job == null) {
      if (mounted) setState(() => _loadComplete = true);
      return;
    }

    if (mounted) {
      setState(() {
        _job = job;
        _loadComplete = true;
      });
    }

    unawaited(_loadExtras(job));
  }

  Future<void> _loadExtras(JobPost job) async {
    EmployerProfile? employer;
    var applied = false;
    var saved = false;

    try {
      employer = await ref
          .read(userRepositoryProvider)
          .getEmployerProfile(job.employerId);
    } catch (_) {}

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      try {
        applied = await ref
            .read(applicationRepositoryProvider)
            .hasApplied(uid, widget.jobId);
      } catch (_) {}
      try {
        saved = await ref
            .read(applicationRepositoryProvider)
            .isSaved(uid, widget.jobId);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _employer = employer;
        _applied = applied;
        _saved = saved;
      });
    }

    unawaited(_loadUserLocation());
  }

  Future<void> _loadUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
      });
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          setState(() {
            _userLat = last.latitude;
            _userLng = last.longitude;
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(currentUserProvider).valueOrNull;
    final job = _job;
    if (user == null || job == null) return;

    if (!user.hasActiveSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noSubscription)),
      );
      return;
    }

    if (user.points < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.insufficientPoints)),
      );
      return;
    }

    if (job.isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.jobExpired)),
      );
      return;
    }

    final alreadyApplied = await ref
        .read(applicationRepositoryProvider)
        .hasApplied(user.uid, job.id);
    if (alreadyApplied) {
      if (mounted) {
        setState(() => _applied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.applied)),
        );
      }
      return;
    }

    final profile = await ref.read(userRepositoryProvider).getSeekerProfile(user.uid);
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 5),
        ),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    if (pos != null &&
        !SubscriptionUtils.canApplyToJob(
          user: user,
          job: job,
          seekerLat: pos.latitude,
          seekerLng: pos.longitude,
          seekerCity: profile?.city,
          seekerCountry: profile?.countryOfResidence,
        )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your subscription plan does not cover this job location',
            ),
          ),
        );
      }
      return;
    }

    if (pos == null &&
        user.activeTier != SubscriptionTier.gold &&
        user.hasActiveSubscription) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location is required to verify your subscription area'),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    final subRepo = ref.read(subscriptionRepositoryProvider);
    try {
      final ok = await subRepo.deductPoint(
            user.uid,
            'Applied to ${job.title}',
          );
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.insufficientPoints)),
          );
        }
        return;
      }

      try {
        await ref.read(applicationRepositoryProvider).apply(
              jobId: job.id,
              seekerId: user.uid,
              employerId: job.employerId,
              jobTitle: job.title,
              companyName: job.companyName,
              seekerName: user.displayName,
              seekerPhotoUrl: profile?.photoUrl ?? '',
            );
        await ref.read(jobRepositoryProvider).incrementApplicants(job.id);
        await ref.read(notificationServiceProvider).send(
              userId: job.employerId,
              subject: 'New applicant',
              body: '${user.displayName} applied for ${job.title}',
              route: '/employer/job/${job.id}/applicants',
            );
      } catch (e) {
        await subRepo.refundPoint(user.uid, 'Refund: failed apply to ${job.title}');
        rethrow;
      }

      if (mounted) {
        setState(() => _applied = true);
        await showApplySuccessDialog(
          context: context,
          ref: ref,
          companyName: job.companyName,
          user: user,
        );
      }
    } catch (e) {
      if (mounted) {
        final duplicate = e is StateError && e.message == 'already_applied';
        if (duplicate) setState(() => _applied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(duplicate ? l10n.applied : l10n.errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleSave() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await ref.read(applicationRepositoryProvider).toggleSaved(uid, widget.jobId);
    setState(() => _saved = !_saved);
  }

  String? _distanceLabel(JobPost job) {
    if (_userLat == null ||
        _userLng == null ||
        job.lat == null ||
        job.lng == null) {
      return null;
    }
    return '${Formatters.distance(GeoUtils.distanceKm(_userLat!, _userLng!, job.lat!, job.lng!))} KM';
  }

  List<String> get _displaySkills {
    final job = _job!;
    return job.requiredSkills.isNotEmpty ? job.requiredSkills : job.skills;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_loadComplete) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: const LoadingView(),
      );
    }
    if (_job == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(title: Text(l10n.jobs)),
        body: EmptyState(
          message: l10n.noResults,
          icon: Icons.work_off_outlined,
        ),
      );
    }

    final job = _job!;
    final coverUrl = _employer?.coverUrl ?? '';
    final timeLeft = Formatters.timeRemaining(job.expiresAt);
    final distance = _distanceLabel(job);
    final locationLine = [
      if (job.city.isNotEmpty) job.city,
      if (job.country.isNotEmpty) job.country,
    ].join(', ');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DesignGradientHeader(
                      imageUrl: coverUrl.isNotEmpty ? coverUrl : null,
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(width: 48),
                            if (!job.isExpired && timeLeft.isNotEmpty)
                              _TimeRemainingBadge(label: 'Time Remaining $timeLeft'),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 8,
                      right: 16,
                      child: _CircleIconButton(
                        icon: Icons.close,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: -28,
                      child: _CompanyLogo(
                        logoUrl: job.companyLogoUrl.isNotEmpty
                            ? job.companyLogoUrl
                            : (_employer?.logoUrl ?? ''),
                        companyName: job.companyName,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                context.push('/company/${job.employerId}'),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    job.companyName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _saved ? Icons.bookmark : Icons.bookmark_border,
                            color: _saved ? AppColors.primary : null,
                          ),
                          onPressed: _toggleSave,
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TealChip(label: job.jobType.toUpperCase()),
                        Text(
                          'Salary: ${job.salaryLabel}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (distance != null)
                          _TealChip(
                            label: distance,
                            icon: Icons.location_on_outlined,
                          ),
                        if (locationLine.isNotEmpty)
                          Text(
                            locationLine,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (job.levelOfEducation.isNotEmpty)
                          _InfoChip(
                            icon: Icons.school_outlined,
                            label: job.levelOfEducation,
                          ),
                        if (job.experienceLevel.isNotEmpty)
                          _InfoChip(
                            icon: Icons.military_tech_outlined,
                            label: job.experienceLevel,
                          ),
                        if (job.yearsOfExperience > 0)
                          _InfoChip(
                            icon: Icons.work_outline,
                            label: '${job.yearsOfExperience}+ Experience',
                          ),
                      ],
                    ),
                    if (job.publishedAt != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          'Posted on : ${Formatters.date(job.publishedAt)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    if (job.isExpired) ...[
                      const SizedBox(height: 8),
                      const Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: StatusChip(status: 'expired'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (job.about.isNotEmpty) ...[
                      _SectionTitle(title: 'About the job'),
                      const SizedBox(height: 8),
                      Text(
                        job.about,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (job.duties.isNotEmpty) ...[
                      _SectionTitle(title: l10n.duties),
                      const SizedBox(height: 8),
                      _BulletList(items: _linesFromText(job.duties)),
                      const SizedBox(height: 20),
                    ],
                    if (_displaySkills.isNotEmpty) ...[
                      _SectionTitle(title: 'Required Skills'),
                      const SizedBox(height: 8),
                      _BulletList(items: _displaySkills),
                      const SizedBox(height: 20),
                    ],
                    if (job.benefits.isNotEmpty) ...[
                      _SectionTitle(title: 'Benefits'),
                      const SizedBox(height: 8),
                      _BulletList(items: job.benefits),
                      const SizedBox(height: 20),
                    ],
                    _DetailCard(
                      title: 'Job Gender type',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genderChips(job.genderType),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (job.languages.isNotEmpty)
                      _DetailCard(
                        title: l10n.languages,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: job.languages
                              .map((l) => _PurpleChip(label: l))
                              .toList(),
                        ),
                      ),
                    if (job.languages.isNotEmpty) const SizedBox(height: 12),
                    if (job.joiningDate != null)
                      _DetailCard(
                        title: 'Joining Date',
                        child: Text(
                          Formatters.date(job.joiningDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (job.joiningDate != null) const SizedBox(height: 12),
                    _DetailCard(
                      title: l10n.salaryRange,
                      child: Text(
                        '${job.salaryLabel} Monthly',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailCard(
                      title: 'Applicants',
                      child: Text(
                        '${job.applicantsCount}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryAction,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          if (_applied)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(
                          l10n.applied,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (!job.isExpired)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                child: DesignPrimaryButton(
                  label: l10n.applyNow,
                  loading: _loading,
                  onPressed: _apply,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> _linesFromText(String text) {
    return text
        .split(RegExp(r'[\n•]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<Widget> _genderChips(String genderType) {
    if (genderType == 'All') {
      return [
        const _PurpleChip(label: 'Male'),
        const _PurpleChip(label: 'Female'),
      ];
    }
    return [_PurpleChip(label: genderType)];
  }
}

class _TimeRemainingBadge extends StatelessWidget {
  const _TimeRemainingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.logoUrl, required this.companyName});

  final String logoUrl;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: logoUrl.isNotEmpty
            ? ProfileImage(
                url: logoUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorWidget: _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        companyName.isNotEmpty ? companyName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TealChip extends StatelessWidget {
  const _TealChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryAction.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primaryAction),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryAction,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _PurpleChip extends StatelessWidget {
  const _PurpleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pink.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
