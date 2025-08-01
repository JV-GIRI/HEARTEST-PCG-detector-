import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum RecordingQuality { poor, good, excellent }

class RecordingQualityIndicatorWidget extends StatelessWidget {
  final RecordingQuality quality;
  final bool isRecording;

  const RecordingQualityIndicatorWidget({
    Key? key,
    required this.quality,
    required this.isRecording,
  }) : super(key: key);

  Color _getQualityColor() {
    switch (quality) {
      case RecordingQuality.poor:
        return AppTheme.lightTheme.colorScheme.error;
      case RecordingQuality.good:
        return AppTheme.getWarningColor(true);
      case RecordingQuality.excellent:
        return AppTheme.getSuccessColor(true);
    }
  }

  String _getQualityText() {
    switch (quality) {
      case RecordingQuality.poor:
        return 'Poor Quality';
      case RecordingQuality.good:
        return 'Good Quality';
      case RecordingQuality.excellent:
        return 'Excellent Quality';
    }
  }

  String _getGuidanceText() {
    switch (quality) {
      case RecordingQuality.poor:
        return 'Check microphone position and reduce background noise';
      case RecordingQuality.good:
        return 'Recording quality is acceptable for analysis';
      case RecordingQuality.excellent:
        return 'Optimal recording conditions detected';
    }
  }

  IconData _getQualityIcon() {
    switch (quality) {
      case RecordingQuality.poor:
        return Icons.warning;
      case RecordingQuality.good:
        return Icons.check_circle_outline;
      case RecordingQuality.excellent:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _getQualityColor().withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getQualityColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getQualityColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: quality == RecordingQuality.poor
                      ? 'warning'
                      : quality == RecordingQuality.good
                          ? 'check_circle_outline'
                          : 'check_circle',
                  color: _getQualityColor(),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getQualityText(),
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: _getQualityColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getGuidanceText(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isRecording)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'REC',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (quality == RecordingQuality.poor) ...[
            SizedBox(height: 1.5.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb_outline',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Tip: Place microphone 2-3 inches from chest for optimal heart sound capture',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
