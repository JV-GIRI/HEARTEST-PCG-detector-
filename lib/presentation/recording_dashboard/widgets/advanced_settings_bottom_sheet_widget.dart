import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedSettingsBottomSheetWidget extends StatefulWidget {
  final int currentSampleRate;
  final double currentNoiseReduction;
  final String currentMicrophone;
  final Function(int) onSampleRateChanged;
  final Function(double) onNoiseReductionChanged;
  final Function(String) onMicrophoneChanged;

  const AdvancedSettingsBottomSheetWidget({
    Key? key,
    required this.currentSampleRate,
    required this.currentNoiseReduction,
    required this.currentMicrophone,
    required this.onSampleRateChanged,
    required this.onNoiseReductionChanged,
    required this.onMicrophoneChanged,
  }) : super(key: key);

  @override
  State<AdvancedSettingsBottomSheetWidget> createState() =>
      _AdvancedSettingsBottomSheetWidgetState();
}

class _AdvancedSettingsBottomSheetWidgetState
    extends State<AdvancedSettingsBottomSheetWidget> {
  late int _selectedSampleRate;
  late double _selectedNoiseReduction;
  late String _selectedMicrophone;

  final List<int> _sampleRates = [8000, 16000, 22050, 44100, 48000];
  final List<String> _microphones = [
    'Built-in Microphone',
    'External Microphone',
    'Bluetooth Headset',
    'USB Microphone',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSampleRate = widget.currentSampleRate;
    _selectedNoiseReduction = widget.currentNoiseReduction;
    _selectedMicrophone = widget.currentMicrophone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Advanced Recording Settings',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),

          // Settings content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sample Rate Section
                  _buildSectionHeader('Sample Rate',
                      'Higher rates provide better quality but larger files'),
                  SizedBox(height: 1.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: _sampleRates.map((rate) {
                        return RadioListTile<int>(
                          title: Text(
                            '${rate} Hz',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            _getSampleRateDescription(rate),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: rate,
                          groupValue: _selectedSampleRate,
                          onChanged: (value) {
                            setState(() {
                              _selectedSampleRate = value!;
                            });
                            widget.onSampleRateChanged(value!);
                          },
                          activeColor: AppTheme.lightTheme.colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Noise Reduction Section
                  _buildSectionHeader(
                      'Noise Reduction', 'Adjust background noise filtering'),
                  SizedBox(height: 1.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Level: ${(_selectedNoiseReduction * 100).toInt()}%',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _getNoiseReductionDescription(
                                  _selectedNoiseReduction),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16),
                          ),
                          child: Slider(
                            value: _selectedNoiseReduction,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _selectedNoiseReduction = value;
                              });
                              widget.onNoiseReductionChanged(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Microphone Selection Section
                  _buildSectionHeader(
                      'Microphone Source', 'Select audio input device'),
                  SizedBox(height: 1.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: _microphones.map((mic) {
                        return RadioListTile<String>(
                          title: Text(
                            mic,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            _getMicrophoneDescription(mic),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: mic,
                          groupValue: _selectedMicrophone,
                          onChanged: (value) {
                            setState(() {
                              _selectedMicrophone = value!;
                            });
                            widget.onMicrophoneChanged(value!);
                          },
                          activeColor: AppTheme.lightTheme.colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Reset to defaults
                            setState(() {
                              _selectedSampleRate = 44100;
                              _selectedNoiseReduction = 0.5;
                              _selectedMicrophone = 'Built-in Microphone';
                            });
                            widget.onSampleRateChanged(44100);
                            widget.onNoiseReductionChanged(0.5);
                            widget.onMicrophoneChanged('Built-in Microphone');
                          },
                          child: Text('Reset to Defaults'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Apply Settings'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          description,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getSampleRateDescription(int rate) {
    switch (rate) {
      case 8000:
        return 'Basic quality - Smallest file size';
      case 16000:
        return 'Good quality - Balanced size';
      case 22050:
        return 'High quality - Recommended';
      case 44100:
        return 'CD quality - Best for analysis';
      case 48000:
        return 'Professional - Largest file size';
      default:
        return '';
    }
  }

  String _getNoiseReductionDescription(double level) {
    if (level < 0.3) {
      return 'Minimal';
    } else if (level < 0.7) {
      return 'Moderate';
    } else {
      return 'Aggressive';
    }
  }

  String _getMicrophoneDescription(String mic) {
    switch (mic) {
      case 'Built-in Microphone':
        return 'Device internal microphone';
      case 'External Microphone':
        return 'Connected external microphone';
      case 'Bluetooth Headset':
        return 'Wireless audio device';
      case 'USB Microphone':
        return 'USB connected microphone';
      default:
        return '';
    }
  }
}
