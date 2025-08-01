import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecordingCardWidget extends StatelessWidget {
  final Map<String, dynamic> recording;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onAnalyze;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final bool isSelected;

  const RecordingCardWidget({
    Key? key,
    required this.recording,
    this.onTap,
    this.onPlay,
    this.onAnalyze,
    this.onShare,
    this.onDelete,
    this.onArchive,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String patientName =
        recording['patientName'] as String? ?? 'Unknown Patient';
    final String patientId = recording['patientId'] as String? ?? 'N/A';
    final DateTime recordingDate =
        recording['date'] as DateTime? ?? DateTime.now();
    final String duration = recording['duration'] as String? ?? '0:00';
    final String status = recording['status'] as String? ?? 'pending';
    final double confidenceScore =
        (recording['confidenceScore'] as num?)?.toDouble() ?? 0.0;
    final String abnormalityType =
        recording['abnormalityType'] as String? ?? 'Normal';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? AppTheme.primaryDark.withValues(alpha: 0.1)
                : AppTheme.primaryLight.withValues(alpha: 0.1))
            : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with patient info and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'ID: $patientId',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context, status, isDark),
                  ],
                ),

                SizedBox(height: 2.h),

                // Waveform visualization
                Container(
                  height: 8.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                        : AppTheme.backgroundLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(
                    painter: WaveformPainter(
                      waveformData: _generateWaveformData(),
                      color:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Recording details
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      size: 16,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${_formatDate(recordingDate)} • $duration',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (status == 'completed') ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(confidenceScore)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(confidenceScore * 100).toInt()}%',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _getConfidenceColor(confidenceScore),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (status == 'completed' && abnormalityType != 'Normal') ...[
                  SizedBox(height: 1.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.warningLight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          size: 16,
                          color: AppTheme.warningLight,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            abnormalityType,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.warningLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 2.h),

                // Action buttons
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      icon: 'play_arrow',
                      label: 'Play',
                      onTap: onPlay,
                      isDark: isDark,
                    ),
                    SizedBox(width: 3.w),
                    _buildActionButton(
                      context,
                      icon: status == 'completed' ? 'analytics' : 'refresh',
                      label: status == 'completed' ? 'Results' : 'Analyze',
                      onTap: onAnalyze,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    _buildActionButton(
                      context,
                      icon: 'share',
                      onTap: onShare,
                      isDark: isDark,
                      isIconOnly: true,
                    ),
                    SizedBox(width: 2.w),
                    _buildActionButton(
                      context,
                      icon: 'delete_outline',
                      onTap: onDelete,
                      isDark: isDark,
                      isIconOnly: true,
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, bool isDark) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = isDark ? AppTheme.successDark : AppTheme.successLight;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case 'analyzing':
        statusColor = isDark ? AppTheme.warningDark : AppTheme.warningLight;
        statusText = 'Analyzing';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'failed':
        statusColor = isDark ? AppTheme.errorDark : AppTheme.errorLight;
        statusText = 'Failed';
        statusIcon = Icons.error;
        break;
      default:
        statusColor =
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: statusColor,
          ),
          SizedBox(width: 1.w),
          Text(
            statusText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    String? label,
    VoidCallback? onTap,
    required bool isDark,
    bool isIconOnly = false,
    bool isDestructive = false,
  }) {
    final Color buttonColor = isDestructive
        ? (isDark ? AppTheme.errorDark : AppTheme.errorLight)
        : (isDark ? AppTheme.primaryDark : AppTheme.primaryLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isIconOnly ? 2.w : 3.w,
            vertical: 1.h,
          ),
          decoration: BoxDecoration(
            color: buttonColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: buttonColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: icon,
                size: 16,
                color: buttonColor,
              ),
              if (!isIconOnly && label != null) ...[
                SizedBox(width: 1.w),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: buttonColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.successLight;
    if (confidence >= 0.6) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  List<double> _generateWaveformData() {
    // Generate realistic heart sound waveform pattern
    return List.generate(50, (index) {
      final double baseAmplitude = 0.3;
      final double heartbeat = (index % 12 < 2) ? 0.8 : baseAmplitude;
      final double noise = (index % 3) * 0.1;
      return heartbeat + noise;
    });
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;

  WaveformPainter({required this.waveformData, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepWidth = size.width / (waveformData.length - 1);

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * stepWidth;
      final y = size.height - (waveformData[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
