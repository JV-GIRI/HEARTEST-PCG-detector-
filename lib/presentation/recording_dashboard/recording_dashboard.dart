import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_settings_bottom_sheet_widget.dart';
import './widgets/audio_level_meter_widget.dart';
import './widgets/patient_info_header_widget.dart';
import './widgets/quick_notes_widget.dart';
import './widgets/record_button_widget.dart';
import './widgets/recording_quality_indicator_widget.dart';
import './widgets/waveform_visualization_widget.dart';

class RecordingDashboard extends StatefulWidget {
  const RecordingDashboard({Key? key}) : super(key: key);

  @override
  State<RecordingDashboard> createState() => _RecordingDashboardState();
}

class _RecordingDashboardState extends State<RecordingDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AudioRecorder _audioRecorder;
  late Timer? _recordingTimer;
  late Timer? _audioLevelTimer;

  // Recording state
  bool _isRecording = false;
  bool _hasPermission = false;
  Duration _recordingDuration = Duration.zero;
  double _currentAudioLevel = 0.0;
  RecordingQuality _recordingQuality = RecordingQuality.good;
  List<double> _waveformData = [];
  String _currentSessionId = '';
  String _patientId = '';
  String _recordingNotes = '';

  // Recording settings
  int _sampleRate = 44100;
  double _noiseReduction = 0.5;
  String _selectedMicrophone = 'Built-in Microphone';

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockRecordings = [
    {
      "id": "REC001",
      "patientId": "P12345",
      "date": "2025-08-01",
      "duration": "00:45",
      "quality": "Excellent",
      "notes": "Normal rhythm, clear sounds",
      "analysisStatus": "Completed",
    },
    {
      "id": "REC002",
      "patientId": "P12346",
      "date": "2025-07-31",
      "duration": "01:12",
      "quality": "Good",
      "notes": "Slight murmur detected",
      "analysisStatus": "Pending",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _audioRecorder = AudioRecorder();
    _currentSessionId = _generateSessionId();
    _requestMicrophonePermission();
    _simulateAudioLevel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recordingTimer?.cancel();
    _audioLevelTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _generateSessionId() {
    final now = DateTime.now();
    final random = Random();
    return 'SES${now.millisecondsSinceEpoch.toString().substring(8)}${random.nextInt(100).toString().padLeft(2, '0')}';
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status.isGranted;
    });

    if (!_hasPermission) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Microphone Permission Required'),
        content: Text(
            'CardioScope AI needs microphone access to record heart sounds for analysis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _simulateAudioLevel() {
    _audioLevelTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRecording) {
        setState(() {
          _currentAudioLevel = 0.3 + (Random().nextDouble() * 0.6);
          _recordingQuality = _currentAudioLevel < 0.4
              ? RecordingQuality.poor
              : _currentAudioLevel < 0.7
                  ? RecordingQuality.good
                  : RecordingQuality.excellent;

          // Simulate waveform data
          _waveformData.add((Random().nextDouble() - 0.5) * _currentAudioLevel);
          if (_waveformData.length > 200) {
            _waveformData.removeAt(0);
          }
        });
      } else {
        setState(() {
          _currentAudioLevel = Random().nextDouble() * 0.3;
        });
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (!_hasPermission) {
      _requestMicrophonePermission();
      return;
    }

    try {
      if (_isRecording) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
    } catch (e) {
      _showErrorDialog('Recording Error',
          'Failed to ${_isRecording ? 'stop' : 'start'} recording. Please try again.');
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: _sampleRate,
        numChannels: 1,
      ), path: 'recording_${DateTime.now().millisecondsSinceEpoch}.wav');

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
        _waveformData.clear();
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      });

      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });

    _recordingTimer?.cancel();
    HapticFeedback.mediumImpact();

    if (path != null) {
      _showRecordingCompleteDialog(path);
    }
  }

  void _showRecordingCompleteDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Recording Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${_formatDuration(_recordingDuration)}'),
            Text('Quality: ${_recordingQuality.name.toUpperCase()}'),
            Text('File saved successfully'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save Only'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/audio-analysis-results');
            },
            child: Text('Analyze Now'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedSettingsBottomSheetWidget(
        currentSampleRate: _sampleRate,
        currentNoiseReduction: _noiseReduction,
        currentMicrophone: _selectedMicrophone,
        onSampleRateChanged: (rate) {
          setState(() {
            _sampleRate = rate;
          });
        },
        onNoiseReductionChanged: (level) {
          setState(() {
            _noiseReduction = level;
          });
        },
        onMicrophoneChanged: (mic) {
          setState(() {
            _selectedMicrophone = mic;
          });
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('CardioScope AI'),
        actions: [
          GestureDetector(
            onTap: _showAdvancedSettings,
            child: Container(
              margin: EdgeInsets.only(right: 4.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Record'),
            Tab(text: 'History'),
            Tab(text: 'Reports'),
            Tab(text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordTab(),
          _buildHistoryTab(),
          _buildReportsTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/audio-file-upload'),
              child: CustomIconWidget(
                iconName: 'upload_file',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }

  Widget _buildRecordTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            // Patient Information Header
            PatientInfoHeaderWidget(
              onPatientIdChanged: (id) {
                setState(() {
                  _patientId = id;
                });
              },
              currentSessionId: _currentSessionId,
            ),

            SizedBox(height: 3.h),

            // Audio Level Meter
            AudioLevelMeterWidget(
              audioLevel: _currentAudioLevel,
              isRecording: _isRecording,
            ),

            SizedBox(height: 2.h),

            // Recording Quality Indicator
            RecordingQualityIndicatorWidget(
              quality: _recordingQuality,
              isRecording: _isRecording,
            ),

            SizedBox(height: 4.h),

            // Record Button
            RecordButtonWidget(
              isRecording: _isRecording,
              onPressed: _toggleRecording,
              recordingDuration: _recordingDuration,
            ),

            SizedBox(height: 4.h),

            // Waveform Visualization
            if (_isRecording || _waveformData.isNotEmpty)
              WaveformVisualizationWidget(
                waveformData: _waveformData,
                isRecording: _isRecording,
                currentPosition: _recordingDuration,
              ),

            SizedBox(height: 3.h),

            // Quick Notes
            QuickNotesWidget(
              onNotesChanged: (notes) {
                setState(() {
                  _recordingNotes = notes;
                });
              },
              initialNotes: _recordingNotes,
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recording History',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/recording-history'),
                  icon: CustomIconWidget(
                    iconName: 'history',
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                itemCount: _mockRecordings.length,
                itemBuilder: (context, index) {
                  final recording = _mockRecordings[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'graphic_eq',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      title: Text(
                          '${recording["patientId"]} - ${recording["id"]}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${recording["date"]} • ${recording["duration"]}'),
                          Text(
                            recording["notes"] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: recording["analysisStatus"] == "Completed"
                              ? AppTheme.getSuccessColor(true)
                                  .withValues(alpha: 0.1)
                              : AppTheme.getWarningColor(true)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recording["analysisStatus"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: recording["analysisStatus"] == "Completed"
                                ? AppTheme.getSuccessColor(true)
                                : AppTheme.getWarningColor(true),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(
                          context, '/audio-analysis-results'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Reports',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'assessment',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 64,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No Reports Available',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Complete a recording analysis to generate reports',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Settings',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('User Profile'),
                    subtitle: Text('Manage your account settings'),
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: () =>
                        Navigator.pushNamed(context, '/user-profile-settings'),
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'settings',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('App Settings'),
                    subtitle: Text('Configure app preferences'),
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: _showAdvancedSettings,
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'help',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Help & Support'),
                    subtitle: Text('Get help and contact support'),
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'logout',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 24,
                    ),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.error),
                    ),
                    subtitle: Text('Sign out of your account'),
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login-screen',
                      (route) => false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}