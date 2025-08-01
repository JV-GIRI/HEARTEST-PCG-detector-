import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onStartRecording;

  const EmptyStateWidget({
    Key? key,
    this.onStartRecording,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'graphic_eq',
                  size: 20.w,
                  color: (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                      .withValues(alpha: 0.6),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'No Recordings Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Start your first heart sound recording to begin cardiac analysis and build your medical history.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Action button
            ElevatedButton.icon(
              onPressed: onStartRecording,
              icon: CustomIconWidget(
                iconName: 'mic',
                size: 20,
                color:
                    isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
              ),
              label: Text('Start Recording'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary action
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/audio-file-upload');
              },
              icon: CustomIconWidget(
                iconName: 'upload_file',
                size: 18,
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              ),
              label: Text('Upload Audio File'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
            ),

            SizedBox(height: 6.h),

            // Tips section
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color:
                    (isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark
                          ? AppTheme.secondaryDark
                          : AppTheme.secondaryLight)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb_outline',
                        size: 20,
                        color: isDark
                            ? AppTheme.secondaryDark
                            : AppTheme.secondaryLight,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Recording Tips',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: isDark
                                  ? AppTheme.secondaryDark
                                  : AppTheme.secondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildTip(
                    context,
                    'Use a quiet environment for best results',
                    isDark,
                  ),
                  SizedBox(height: 1.h),
                  _buildTip(
                    context,
                    'Place device microphone close to chest',
                    isDark,
                  ),
                  SizedBox(height: 1.h),
                  _buildTip(
                    context,
                    'Record for at least 10-15 seconds',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String tip, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            tip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
        ),
      ],
    );
  }
}
