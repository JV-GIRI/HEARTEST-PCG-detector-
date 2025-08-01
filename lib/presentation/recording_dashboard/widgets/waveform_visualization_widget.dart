import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaveformVisualizationWidget extends StatefulWidget {
  final List<double> waveformData;
  final bool isRecording;
  final Duration currentPosition;

  const WaveformVisualizationWidget({
    Key? key,
    required this.waveformData,
    required this.isRecording,
    required this.currentPosition,
  }) : super(key: key);

  @override
  State<WaveformVisualizationWidget> createState() =>
      _WaveformVisualizationWidgetState();
}

class _WaveformVisualizationWidgetState
    extends State<WaveformVisualizationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    if (widget.isRecording) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _animationController.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 20.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'graphic_eq',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Heart Sound Waveform',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.isRecording)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          AppTheme.getSuccessColor(true).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'LIVE',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getSuccessColor(true),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: widget.waveformData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'hearing',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          widget.isRecording
                              ? 'Listening for heart sounds...'
                              : 'Start recording to see waveform',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(double.infinity, double.infinity),
                        painter: WaveformPainter(
                          waveformData: widget.waveformData,
                          primaryColor: AppTheme.lightTheme.colorScheme.primary,
                          secondaryColor: AppTheme
                              .lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          isRecording: widget.isRecording,
                          animationValue: _animationController.value,
                        ),
                      );
                    },
                  ),
          ),
          if (widget.waveformData.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Text(
                  '0:00',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.currentPosition.inMinutes}:${(widget.currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isRecording;
  final double animationValue;

  WaveformPainter({
    required this.waveformData,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isRecording,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final backgroundPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final backgroundPath = Path();

    final centerY = size.height / 2;
    final stepX = size.width / (waveformData.length - 1);

    // Draw background waveform
    for (int i = 0; i < waveformData.length; i++) {
      final x = i * stepX;
      final y = centerY + (waveformData[i] * centerY * 0.8);

      if (i == 0) {
        backgroundPath.moveTo(x, y);
      } else {
        backgroundPath.lineTo(x, y);
      }
    }

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw active waveform with animation effect
    final activeLength = isRecording
        ? (waveformData.length * animationValue).round()
        : waveformData.length;

    for (int i = 0; i < activeLength && i < waveformData.length; i++) {
      final x = i * stepX;
      final y = centerY + (waveformData[i] * centerY * 0.8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );

    // Draw recording indicator
    if (isRecording && activeLength > 0) {
      final indicatorPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;

      final indicatorX = (activeLength - 1) * stepX;
      canvas.drawCircle(
        Offset(indicatorX,
            centerY + (waveformData[activeLength - 1] * centerY * 0.8)),
        4.0,
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
