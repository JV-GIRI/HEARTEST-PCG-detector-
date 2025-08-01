import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioFilePath;
  final List<Map<String, dynamic>> abnormalityMarkers;

  const AudioPlayerWidget({
    Key? key,
    required this.audioFilePath,
    required this.abnormalityMarkers,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 45.0; // Mock duration in seconds
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'audiotrack',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Audio Playback',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildWaveformVisualization(),
          SizedBox(height: 3.h),
          _buildProgressBar(),
          SizedBox(height: 2.h),
          _buildPlaybackControls(),
          SizedBox(height: 2.h),
          _buildAbnormalityMarkers(),
        ],
      ),
    );
  }

  Widget _buildWaveformVisualization() {
    return Container(
      height: 15.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: CustomPaint(
        painter: WaveformPainter(
          progress: _currentPosition / _totalDuration,
          abnormalityMarkers: widget.abnormalityMarkers,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: _currentPosition,
            max: _totalDuration,
            onChanged: (value) {
              setState(() {
                _currentPosition = value;
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                _formatDuration(_totalDuration),
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentPosition =
                  (_currentPosition - 10).clamp(0.0, _totalDuration);
            });
          },
          icon: CustomIconWidget(
            iconName: 'replay_10',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 7.w,
          ),
        ),
        SizedBox(width: 4.w),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            icon: CustomIconWidget(
              iconName: _isPlaying ? 'pause' : 'play_arrow',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 8.w,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        IconButton(
          onPressed: () {
            setState(() {
              _currentPosition =
                  (_currentPosition + 10).clamp(0.0, _totalDuration);
            });
          },
          icon: CustomIconWidget(
            iconName: 'forward_10',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 7.w,
          ),
        ),
        SizedBox(width: 6.w),
        _buildSpeedSelector(),
      ],
    );
  }

  Widget _buildSpeedSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: _playbackSpeed,
          isDense: true,
          items: _speedOptions.map((speed) {
            return DropdownMenuItem<double>(
              value: speed,
              child: Text(
                '${speed}x',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _playbackSpeed = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAbnormalityMarkers() {
    if (widget.abnormalityMarkers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Abnormalities',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: widget.abnormalityMarkers.map((marker) {
            final timestamp = marker['timestamp'] as double? ?? 0.0;
            final type = marker['type'] as String? ?? '';

            return InkWell(
              onTap: () {
                setState(() {
                  _currentPosition = timestamp;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${_formatDuration(timestamp)} - $type',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final List<Map<String, dynamic>> abnormalityMarkers;

  WaveformPainter({
    required this.progress,
    required this.abnormalityMarkers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    final progressPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    final abnormalPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.6)
      ..strokeWidth = 3;

    // Draw waveform
    final waveformData = _generateWaveformData(size.width.toInt());
    for (int i = 0; i < waveformData.length - 1; i++) {
      final x1 = (i / waveformData.length) * size.width;
      final x2 = ((i + 1) / waveformData.length) * size.width;
      final y1 = size.height / 2 + waveformData[i] * size.height / 4;
      final y2 = size.height / 2 + waveformData[i + 1] * size.height / 4;

      final currentPaint =
          (x1 / size.width) <= progress ? progressPaint : paint;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), currentPaint);
    }

    // Draw abnormality markers
    for (final marker in abnormalityMarkers) {
      final timestamp = marker['timestamp'] as double? ?? 0.0;
      final duration = marker['duration'] as double? ?? 1.0;
      final totalDuration = 45.0; // Mock total duration

      final startX = (timestamp / totalDuration) * size.width;
      final endX = ((timestamp + duration) / totalDuration) * size.width;

      canvas.drawRect(
        Rect.fromLTWH(startX, 0, endX - startX, size.height),
        abnormalPaint,
      );
    }
  }

  List<double> _generateWaveformData(int points) {
    // Generate mock waveform data
    return List.generate(points, (index) {
      return (index % 20 - 10) / 10.0 * (1 + 0.5 * (index % 7) / 7);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
