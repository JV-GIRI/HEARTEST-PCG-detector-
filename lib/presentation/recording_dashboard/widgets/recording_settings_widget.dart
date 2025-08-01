import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class RecordingSettingsWidget extends StatefulWidget {
  const RecordingSettingsWidget({super.key});

  @override
  State<RecordingSettingsWidget> createState() => _RecordingSettingsWidgetState();
}

class _RecordingSettingsWidgetState extends State<RecordingSettingsWidget> {
  double _sampleRate = 44100;
  double _noiseReduction = 0.5;
  String _selectedMicrophone = 'Internal';
  bool _autoGain = true;
  bool _highPassFilter = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'tune',
                  size: 6.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Recording Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const CustomIconWidget(iconName: 'close'),
                ),
              ],
            ),
          ),
          
          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio Quality Section
                  _buildSectionHeader('Audio Quality', 'high_quality'),
                  
                  _buildSliderSetting(
                    title: 'Sample Rate',
                    subtitle: '${_sampleRate.toInt()} Hz',
                    value: _sampleRate,
                    min: 8000,
                    max: 48000,
                    divisions: 8,
                    onChanged: (value) {
                      setState(() {
                        _sampleRate = value;
                      });
                    },
                  ),
                  
                  _buildSliderSetting(
                    title: 'Noise Reduction',
                    subtitle: 'Level ${(_noiseReduction * 10).toInt()}',
                    value: _noiseReduction,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _noiseReduction = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Hardware Section
                  _buildSectionHeader('Hardware', 'mic'),
                  
                  _buildDropdownSetting(
                    title: 'Microphone Source',
                    value: _selectedMicrophone,
                    items: ['Internal', 'External USB', 'Bluetooth'],
                    onChanged: (value) {
                      setState(() {
                        _selectedMicrophone = value!;
                      });
                    },
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Processing Section
                  _buildSectionHeader('Audio Processing', 'graphic_eq'),
                  
                  _buildSwitchSetting(
                    title: 'Automatic Gain Control',
                    subtitle: 'Automatically adjust recording levels',
                    value: _autoGain,
                    onChanged: (value) {
                      setState(() {
                        _autoGain = value;
                      });
                    },
                  ),
                  
                  _buildSwitchSetting(
                    title: 'High-Pass Filter',
                    subtitle: 'Remove low-frequency noise',
                    value: _highPassFilter,
                    onChanged: (value) {
                      setState(() {
                        _highPassFilter = value;
                      });
                    },
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Calibration Section
                  _buildSectionHeader('Calibration', 'equalizer'),
                  
                  _buildActionTile(
                    title: 'Microphone Calibration',
                    subtitle: 'Test and calibrate microphone sensitivity',
                    icon: 'mic_external_on',
                    onTap: () {
                      _showCalibrationDialog();
                    },
                  ),
                  
                  _buildActionTile(
                    title: 'Reset to Defaults',
                    subtitle: 'Restore factory settings',
                    icon: 'settings_backup_restore',
                    onTap: () {
                      _resetToDefaults();
                    },
                  ),
                  
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String iconName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            size: 5.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: icon,
          size: 6.w,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const CustomIconWidget(iconName: 'arrow_forward_ios'),
        onTap: onTap,
      ),
    );
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Calibration'),
        content: const Text('This will test your microphone and adjust sensitivity levels for optimal recording quality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calibration started')),
              );
            },
            child: const Text('Start Calibration'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _sampleRate = 44100;
      _noiseReduction = 0.5;
      _selectedMicrophone = 'Internal';
      _autoGain = true;
      _highPassFilter = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults')),
    );
  }
}