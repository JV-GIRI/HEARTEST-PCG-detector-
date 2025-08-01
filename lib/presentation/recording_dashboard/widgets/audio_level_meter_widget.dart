import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioLevelMeterWidget extends StatefulWidget {
  final double audioLevel;
  final bool isRecording;

  const AudioLevelMeterWidget({
    Key? key,
    required this.audioLevel,
    required this.isRecording,
  }) : super(key: key);

  @override
  State<AudioLevelMeterWidget> createState() => _AudioLevelMeterWidgetState();
}

class _AudioLevelMeterWidgetState extends State<AudioLevelMeterWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AudioLevelMeterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getLevelColor(double level) {
    if (level < 0.3) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (level < 0.7) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.getSuccessColor(true);
    }
  }

  String _getLevelText(double level) {
    if (level < 0.3) {
      return 'Too Quiet - Move Closer';
    } else if (level < 0.7) {
      return 'Good - Adjust Position';
    } else {
      return 'Optimal Signal Level';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRecording ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 80.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getLevelColor(widget.audioLevel).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _getLevelColor(widget.audioLevel).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'mic',
                      color: _getLevelColor(widget.audioLevel),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Audio Level',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: _getLevelColor(widget.audioLevel),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(widget.audioLevel * 100).toInt()}%',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: _getLevelColor(widget.audioLevel),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: widget.audioLevel,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getLevelColor(widget.audioLevel),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _getLevelText(widget.audioLevel),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getLevelColor(widget.audioLevel),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
