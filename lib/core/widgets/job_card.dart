import 'package:flutter/material.dart';
import '../models/job_post.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/geo_utils.dart';
import 'common_widgets.dart';
import 'profile_image.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onBookmark,
    this.bookmarked = false,
    this.userLat,
    this.userLng,
    this.trailing,
    this.logoUrlFallback,
  });

  final JobPost job;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final bool bookmarked;
  final double? userLat;
  final double? userLng;
  final Widget? trailing;
  final String? logoUrlFallback;

  String get _logoUrl {
    if (job.companyLogoUrl.isNotEmpty) return job.companyLogoUrl;
    return logoUrlFallback ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final expired = job.isExpired;
    String? distance;
    if (userLat != null && userLng != null && job.lat != null && job.lng != null) {
      distance = Formatters.distance(
        GeoUtils.distanceKm(userLat!, userLng!, job.lat!, job.lng!),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _logo(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          job.companyName,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (onBookmark != null)
                    IconButton(
                      icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: bookmarked ? AppColors.primary : null,
                      ),
                      onPressed: onBookmark,
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(job.jobType),
                  _chip(job.salaryLabel),
                  if (distance != null) _chip('$distance KM'),
                  if (expired)
                    const StatusChip(status: 'expired')
                  else if (job.expiresAt != null)
                    _chip(Formatters.timeRemaining(job.expiresAt!)),
                ],
              ),
              if (job.locationText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.locationText,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    if (_logoUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: AppColors.surfaceMuted,
        child: Text(job.companyName.isNotEmpty ? job.companyName[0] : '?'),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ProfileImage(
        url: _logoUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorWidget: CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          child: Text(job.companyName.isNotEmpty ? job.companyName[0] : '?'),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
