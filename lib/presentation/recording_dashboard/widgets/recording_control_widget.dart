import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class RecordingControlWidget extends StatefulWidget {
  final bool isRecording;
  final String recordingTime;
  final VoidCallback onToggleRecording;

  const RecordingControlWidget({
    super.key,
    required this.isRecording,
    required this.recordingTime,
    required this.onToggleRecording,
  });

  @override
  State<RecordingControlWidget> createState() => _RecordingControlWidgetState();
}

class _RecordingControlWidgetState extends State<RecordingControlWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(RecordingControlWidget oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Recording Status and Quality Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Audio Level Meter (simulated)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Level',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAudioLevelMeter(),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Recording Quality Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getQualityColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getQualityColor().withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getQualityColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getQualityText(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getQualityColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Main Recording Button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: widget.onToggleRecording,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isRecording
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.secondary,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isRecording
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.secondary)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.isRecording
                          ? CustomIconWidget(
                              iconName: 'stop',
                              size: 48,
                              color: Theme.of(context).colorScheme.onError,
                            )
                          : CustomIconWidget(
                              iconName: 'radio_button_checked',
                              size: 48,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Recording Time Display
          if (widget.isRecording) ...[
            Text(
              widget.recordingTime,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.error,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recording in progress...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ] else ...[
            Text(
              'Tap to Start Recording',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Position stethoscope for optimal sound capture',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Live Waveform Display (when recording)
          if (widget.isRecording) ...[
            Container(
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _buildWaveformVisualization(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioLevelMeter() {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: List.generate(10, (index) {
          final isActive = widget.isRecording && index < 7; // Simulate audio level
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? _getAudioLevelColor(index)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWaveformVisualization() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(20, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 100 + (index * 50)),
          width: 3.2,
          height: (2 + (index % 8)) * 8.0, // Simulate waveform
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }),
    );
  }

  Color _getQualityColor() {
    if (!widget.isRecording) return Theme.of(context).colorScheme.outline;
    // Simulate quality based on recording status
    return Theme.of(context).colorScheme.secondary; // Good quality
  }

  String _getQualityText() {
    if (!widget.isRecording) return 'Ready';
    return 'Good Quality';
  }

  Color _getAudioLevelColor(int index) {
    if (index < 3) return Theme.of(context).colorScheme.secondary;
    if (index < 7) return Theme.of(context).colorScheme.tertiary;
    return Theme.of(context).colorScheme.error;
  }
}