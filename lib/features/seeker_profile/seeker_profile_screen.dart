import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/seeker_profile.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/design/design_widgets.dart';
import '../../core/widgets/profile_image.dart';
import '../../l10n/app_localizations.dart';
import 'add_education_sheet.dart';
import 'add_experience_sheet.dart';
import 'add_language_sheet.dart';
import 'add_skill_sheet.dart';

class SeekerProfileScreen extends ConsumerStatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  ConsumerState<SeekerProfileScreen> createState() =>
      _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends ConsumerState<SeekerProfileScreen> {
  static const _wizardSteps = {
    'personal': 0,
    'education': 1,
    'experience': 2,
    'languages': 3,
    'skills': 4,
    'resume': 5,
    'links': 5,
  };

  void _openWizard(SeekerProfile profile, String section) {
    final step = _wizardSteps[section] ?? 0;
    context.push(
      '/seeker/profile-wizard?edit=1&step=$step',
      extra: profile,
    );
  }

  Future<bool> _saveProfile(SeekerProfile profile) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(userRepositoryProvider).saveSeekerProfile(
            profile,
            enforceDailyLimit: true,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.save)),
        );
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      if (e.toString().contains('profile_update_limit')) {
        final uid = ref.read(authStateProvider).valueOrNull?.uid;
        final userDoc = uid == null
            ? null
            : await ref.read(userRepositoryProvider).getUser(uid);
        if (!mounted) return false;
        final last = userDoc?.lastProfileUpdate;
        final hoursLeft = last == null
            ? 0
            : 24 - DateTime.now().difference(last).inHours;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hoursLeft > 0
                  ? l10n.hoursLeft(hoursLeft.clamp(1, 24))
                  : l10n.profileUpdateLimit,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
      return false;
    }
  }

  Future<void> _editEducation(SeekerProfile profile, int index) async {
    final updated = await AddEducationSheet.show(
      context,
      initial: profile.education[index],
    );
    if (updated == null) return;
    final list = List<EducationEntry>.from(profile.education);
    list[index] = updated;
    await _saveProfile(profile.copyWith(education: list));
  }

  Future<void> _addEducation(SeekerProfile profile) async {
    final entry = await AddEducationSheet.show(context);
    if (entry == null) return;
    await _saveProfile(
      profile.copyWith(education: [...profile.education, entry]),
    );
  }

  Future<void> _deleteEducation(SeekerProfile profile, int index) async {
    final ok = await _confirmDelete();
    if (ok != true) return;
    final list = List<EducationEntry>.from(profile.education)..removeAt(index);
    await _saveProfile(profile.copyWith(education: list));
  }

  Future<void> _editExperience(SeekerProfile profile, int index) async {
    final updated = await AddExperienceSheet.show(
      context,
      initial: profile.experience[index],
    );
    if (updated == null) return;
    final list = List<ExperienceEntry>.from(profile.experience);
    list[index] = updated;
    await _saveProfile(profile.copyWith(experience: list));
  }

  Future<void> _addExperience(SeekerProfile profile) async {
    final entry = await AddExperienceSheet.show(context);
    if (entry == null) return;
    await _saveProfile(
      profile.copyWith(experience: [...profile.experience, entry]),
    );
  }

  Future<void> _deleteExperience(SeekerProfile profile, int index) async {
    final ok = await _confirmDelete();
    if (ok != true) return;
    final list = List<ExperienceEntry>.from(profile.experience)..removeAt(index);
    await _saveProfile(profile.copyWith(experience: list));
  }

  Future<void> _editLanguage(SeekerProfile profile, int index) async {
    final updated = await AddLanguageSheet.show(
      context,
      initial: profile.languages[index],
    );
    if (updated == null) return;
    final list = List<LanguageEntry>.from(profile.languages);
    list[index] = updated;
    await _saveProfile(profile.copyWith(languages: list));
  }

  Future<void> _addLanguage(SeekerProfile profile) async {
    final entry = await AddLanguageSheet.show(context);
    if (entry == null) return;
    await _saveProfile(
      profile.copyWith(languages: [...profile.languages, entry]),
    );
  }

  Future<void> _deleteLanguage(SeekerProfile profile, int index) async {
    final ok = await _confirmDelete();
    if (ok != true) return;
    final list = List<LanguageEntry>.from(profile.languages)..removeAt(index);
    await _saveProfile(profile.copyWith(languages: list));
  }

  Future<void> _editSkill(SeekerProfile profile, int index) async {
    final updated = await AddSkillSheet.show(
      context,
      education: profile.education,
      experience: profile.experience,
      initial: profile.skills[index],
    );
    if (updated == null) return;
    final list = List<SkillEntry>.from(profile.skills);
    list[index] = updated;
    await _saveProfile(profile.copyWith(skills: list));
  }

  Future<void> _addSkill(SeekerProfile profile) async {
    final entry = await AddSkillSheet.show(
      context,
      education: profile.education,
      experience: profile.experience,
    );
    if (entry == null) return;
    await _saveProfile(profile.copyWith(skills: [...profile.skills, entry]));
  }

  Future<void> _deleteSkill(SeekerProfile profile, int index) async {
    final ok = await _confirmDelete();
    if (ok != true) return;
    final list = List<SkillEntry>.from(profile.skills)..removeAt(index);
    await _saveProfile(profile.copyWith(skills: list));
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Remove this item from your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _itemActions({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: AppColors.primary,
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: AppColors.error,
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _addButton(String label, VoidCallback onPressed) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 18),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder(
      stream: ref.watch(userRepositoryProvider).watchSeekerProfile(uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: LoadingView());
        }
        final p = snap.data;
        if (p == null) {
          return Scaffold(
            appBar: DesignAppBar(title: l10n.profile, showBack: true),
            body: EmptyState(message: l10n.profile),
          );
        }

        final totalExp = p.totalExperienceLabel;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DesignGradientHeader(
                  height: 160,
                  imageUrl: p.photoUrl.isNotEmpty ? p.photoUrl : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => _openWizard(p, 'personal'),
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: Center(
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.surface,
                      backgroundImage: ProfileImage.provider(p.photoUrl),
                      child: p.photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(
                      user?.displayName ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      p.latestJobTitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.experience}: $totalExp',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DesignSectionCard(
                      title: l10n.personalInfo,
                      onEdit: () => _openWizard(p, 'personal'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row(l10n.dateOfBirth, Formatters.date(p.dateOfBirth)),
                          _row(l10n.gender, p.gender),
                          _row(l10n.maritalStatus, p.maritalStatus),
                          _row(l10n.nationality, p.nationality),
                          _row(l10n.countryOfResidence, p.countryOfResidence),
                          if (p.city.isNotEmpty) _row('City', p.city),
                          const Divider(),
                          _verifiedRow(l10n.email, user?.email ?? '', true),
                          _verifiedRow(
                            l10n.phone,
                            user?.phone ?? '',
                            (user?.phone.isNotEmpty ?? false) &&
                                (user?.emailVerified ?? false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.education,
                      onEdit: () => _openWizard(p, 'education'),
                      child: Column(
                        children: [
                          ...p.education.asMap().entries.map((e) {
                            final edu = e.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${edu.level} - ${edu.field}'),
                              subtitle: Text(
                                '${Formatters.date(edu.startDate)} - ${Formatters.date(edu.endDate)}',
                              ),
                              trailing: _itemActions(
                                onEdit: () => _editEducation(p, e.key),
                                onDelete: () => _deleteEducation(p, e.key),
                              ),
                              onTap: () => _editEducation(p, e.key),
                            );
                          }),
                          _addButton(l10n.add, () => _addEducation(p)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.experience,
                      onEdit: () => _openWizard(p, 'experience'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.experience}: $totalExp',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ...p.experience.asMap().entries.map((e) {
                            final exp = e.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryAction,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _editExperience(p, e.key),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp.jobTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Chip(label: Text(exp.employmentType)),
                                          Text(exp.companyName),
                                          Text(
                                            '${Formatters.date(exp.startDate)} - ${exp.ongoing ? l10n.ongoing : Formatters.date(exp.endDate)}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _itemActions(
                                    onEdit: () => _editExperience(p, e.key),
                                    onDelete: () => _deleteExperience(p, e.key),
                                  ),
                                ],
                              ),
                            );
                          }),
                          _addButton(l10n.add, () => _addExperience(p)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.skills,
                      onEdit: () => _openWizard(p, 'skills'),
                      child: Column(
                        children: [
                          ...p.skills.asMap().entries.map((e) {
                            final skill = e.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(skill.name),
                              subtitle: Text(p.skillSourceLabel(skill)),
                              trailing: _itemActions(
                                onEdit: () => _editSkill(p, e.key),
                                onDelete: () => _deleteSkill(p, e.key),
                              ),
                              onTap: () => _editSkill(p, e.key),
                            );
                          }),
                          _addButton(l10n.add, () => _addSkill(p)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.languages,
                      onEdit: () => _openWizard(p, 'languages'),
                      child: Column(
                        children: [
                          ...p.languages.asMap().entries.map((e) {
                            final lang = e.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(lang.language),
                              subtitle: Text(lang.proficiency),
                              trailing: _itemActions(
                                onEdit: () => _editLanguage(p, e.key),
                                onDelete: () => _deleteLanguage(p, e.key),
                              ),
                              onTap: () => _editLanguage(p, e.key),
                            );
                          }),
                          _addButton(l10n.add, () => _addLanguage(p)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: l10n.resume,
                      onEdit: () => _openWizard(p, 'resume'),
                      child: p.resumeUrl.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No resume uploaded',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                _addButton('Upload resume', () => _openWizard(p, 'resume')),
                              ],
                            )
                          : ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.picture_as_pdf,
                                  color: AppColors.error),
                              title: Text(
                                p.resumeName.isEmpty ? l10n.resume : p.resumeName,
                              ),
                              subtitle: p.resumeSizeBytes > 0
                                  ? Text('${(p.resumeSizeBytes / 1024).round()} KB')
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download_outlined),
                                    onPressed: () =>
                                        launchUrl(Uri.parse(p.resumeUrl)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    color: AppColors.primary,
                                    onPressed: () => _openWizard(p, 'resume'),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    DesignSectionCard(
                      title: 'Links',
                      onEdit: () => _openWizard(p, 'links'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.linkedInUrl.isEmpty && p.otherLinks.isEmpty)
                            Text(
                              'No links added',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          if (p.linkedInUrl.isNotEmpty)
                            _linkTile('LinkedIn', p.linkedInUrl),
                          ...p.otherLinks.map((l) => _linkTile('Website', l)),
                          _addButton('Edit links', () => _openWizard(p, 'links')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Joining Date: ${Formatters.monthYear(user?.createdAt)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _verifiedRow(String label, String value, bool verified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
          if (verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Verified',
                style: TextStyle(color: AppColors.success, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _linkTile(String title, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(url, style: const TextStyle(color: AppColors.primary)),
      onTap: () => launchUrl(Uri.parse(url)),
    );
  }
}
