import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecordButtonWidget extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onPressed;
  final Duration recordingDuration;

  const RecordButtonWidget({
    Key? key,
    required this.isRecording,
    required this.onPressed,
    required this.recordingDuration,
  }) : super(key: key);

  @override
  State<RecordButtonWidget> createState() => _RecordButtonWidgetState();
}

class _RecordButtonWidgetState extends State<RecordButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RecordButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isRecording) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color:
                  AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Recording: ${_formatDuration(widget.recordingDuration)}',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
        ],
        GestureDetector(
          onTapDown: (_) {
            _scaleController.forward();
          },
          onTapUp: (_) {
            _scaleController.reverse();
            widget.onPressed();
          },
          onTapCancel: () {
            _scaleController.reverse();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 35.w,
                  height: 35.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isRecording
                            ? AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.3)
                            : AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                        blurRadius: widget.isRecording
                            ? 20
                            : 15 * _pulseAnimation.value,
                        spreadRadius:
                            widget.isRecording ? 5 : 2 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isRecording
                            ? [
                                AppTheme.lightTheme.colorScheme.error,
                                AppTheme.lightTheme.colorScheme.error
                                    .withValues(alpha: 0.8),
                              ]
                            : [
                                AppTheme.lightTheme.colorScheme.primary,
                                AppTheme
                                    .lightTheme.colorScheme.primaryContainer,
                              ],
                      ),
                    ),
                    child: Center(
                      child: widget.isRecording
                          ? Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                          : CustomIconWidget(
                              iconName: 'mic',
                              color: Colors.white,
                              size: 12.w,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.isRecording
              ? 'Tap to Stop Recording'
              : 'Tap to Start Recording',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            color: widget.isRecording
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!widget.isRecording) ...[
          SizedBox(height: 1.h),
          Text(
            'Position microphone near chest area',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
