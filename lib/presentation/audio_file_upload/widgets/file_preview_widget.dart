import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../../core/app_export.dart';

class FilePreviewWidget extends StatefulWidget {
  final Map<String, dynamic> file;
  final VoidCallback onClose;
  final VoidCallback onUpload;

  const FilePreviewWidget({
    Key? key,
    required this.file,
    required this.onClose,
    required this.onUpload,
  }) : super(key: key);

  @override
  State<FilePreviewWidget> createState() => _FilePreviewWidgetState();
}

class _FilePreviewWidgetState extends State<FilePreviewWidget> {
  bool _isPlaying = false;
  double _playbackPosition = 0.0;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 3.h),
          _buildFileInfo(context),
          SizedBox(height: 3.h),
          _buildWaveformVisualization(context),
          SizedBox(height: 3.h),
          _buildAudioControls(context),
          SizedBox(height: 3.h),
          _buildQualityAssessment(context),
          const Spacer(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'File Preview',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onClose,
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'audiotrack',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file['name'],
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'WAV Audio File',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildInfoItem('Duration', widget.file['duration']),
              SizedBox(width: 4.w),
              _buildInfoItem('Size', widget.file['size']),
              SizedBox(width: 4.w),
              _buildInfoItem('Quality',
                  widget.file['quality'] == 'high' ? 'HD' : 'Standard'),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildInfoItem('Sample Rate', '44.1 kHz'),
              SizedBox(width: 4.w),
              _buildInfoItem('Bit Depth', '16-bit'),
              SizedBox(width: 4.w),
              _buildInfoItem('Channels', 'Mono'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformVisualization(BuildContext context) {
    return Container(
      height: 15.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waveform Preview',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: CustomPaint(
              painter: WaveformPainter(
                progress: _playbackPosition,
                primaryColor: AppTheme.lightTheme.primaryColor,
                backgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _playbackPosition =
                        (_playbackPosition - 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'replay_10',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.secondary,
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
                    _playbackPosition =
                        (_playbackPosition + 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'forward_10',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Slider(
            value: _playbackPosition,
            onChanged: (value) {
              setState(() {
                _playbackPosition = value;
              });
            },
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_playbackPosition * 45).toInt()}s',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Row(
                children: [
                  Text(
                    'Speed: ${_playbackSpeed}x',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  SizedBox(width: 2.w),
                  DropdownButton<double>(
                    value: _playbackSpeed,
                    underline: const SizedBox.shrink(),
                    items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                      return DropdownMenuItem(
                        value: speed,
                        child: Text('${speed}x'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _playbackSpeed = value ?? 1.0;
                      });
                    },
                  ),
                ],
              ),
              Text(
                '45s',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityAssessment(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color:
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'verified',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Quality Assessment',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child:
                    _buildQualityIndicator('Signal Quality', 0.85, 'Excellent'),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildQualityIndicator('Noise Level', 0.15, 'Low'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'This file meets the quality standards for cardiac analysis.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator(String label, double value, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall,
        ),
        SizedBox(height: 0.5.h),
        LinearProgressIndicator(
          value: value,
          backgroundColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            value > 0.7
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.tertiary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          status,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: value > 0.7
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClose,
            child: Text('Cancel'),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.onUpload,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'upload',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text('Upload File'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  WaveformPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    // Generate mock waveform data
    final points = <Offset>[];
    for (int i = 0; i < width; i += 3) {
      final amplitude = (i / width) < progress
          ? height * 0.3 * (0.5 + 0.5 * sin(i / width))
          : height * 0.2 * (0.3 + 0.3 * sin(i / width));
      points.add(Offset(i.toDouble(), centerY - amplitude));
      points.add(Offset(i.toDouble(), centerY + amplitude));
    }

    // Draw background waveform
    for (int i = 0; i < points.length - 2; i += 2) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw progress waveform
    final progressWidth = width * progress;
    for (int i = 0;
        i < points.length - 2 && points[i].dx <= progressWidth;
        i += 2) {
      canvas.drawLine(points[i], points[i + 1], progressPaint);
    }

    // Draw progress indicator
    if (progress > 0) {
      final indicatorPaint = Paint()
        ..color = primaryColor
        ..strokeWidth = 3;
      canvas.drawLine(
        Offset(progressWidth, 0),
        Offset(progressWidth, height),
        indicatorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}