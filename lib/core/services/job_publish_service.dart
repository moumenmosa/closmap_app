import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/job_post.dart';
import '../providers/providers.dart';

class JobPublishResult {
  const JobPublishResult._({required this.success, this.errorMessage});

  const JobPublishResult.success() : this._(success: true);
  const JobPublishResult.failure(String message)
      : this._(success: false, errorMessage: message);

  final bool success;
  final String? errorMessage;
}

/// Saves job as active in Firestore, then deducts one point (publish after success).
Future<JobPublishResult> publishJobWithSubscription(
  WidgetRef ref, {
  required JobPost job,
  required int validityDays,
  required AppUser user,
}) async {
  if (!user.hasActiveSubscription) {
    return const JobPublishResult.failure('no_subscription');
  }
  if (user.points < 1) {
    return const JobPublishResult.failure('insufficient_points');
  }

  final jobRepo = ref.read(jobRepositoryProvider);
  final subRepo = ref.read(subscriptionRepositoryProvider);
  try {
    await jobRepo.publishJobPost(job, validityDays);
    final ok = await subRepo.deductPoint(
      user.uid,
      'Published job: ${job.title}',
    );
    if (!ok) {
      return const JobPublishResult.failure('insufficient_points');
    }
    return const JobPublishResult.success();
  } catch (e) {
    return JobPublishResult.failure(e.toString());
  }
}
