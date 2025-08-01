import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_section.dart';
import './widgets/analysis_summary_card.dart';
import './widgets/audio_player_widget.dart';
import './widgets/detailed_findings_section.dart';
import './widgets/emergency_alert_modal.dart';
import './widgets/medical_disclaimer_widget.dart';

class AudioAnalysisResults extends StatefulWidget {
  const AudioAnalysisResults({Key? key}) : super(key: key);

  @override
  State<AudioAnalysisResults> createState() => _AudioAnalysisResultsState();
}

class _AudioAnalysisResultsState extends State<AudioAnalysisResults> {
  bool _showEmergencyAlert = false;

  // Mock analysis data
  final Map<String, dynamic> _analysisData = {
    "confidence": 87.5,
    "riskLevel": "medium",
    "overallStatus": "Irregular Heart Rhythm Detected",
    "recordingDate": "2025-08-01 20:11:20",
    "duration": 45.0,
    "audioFilePath": "/recordings/heart_sound_20250801.wav"
  };

  final List<Map<String, dynamic>> _detailedFindings = [
    {
      "title": "Heart Rate Analysis",
      "confidence": 92.3,
      "status": "normal",
      "description":
          "Heart rate is within normal range with regular intervals between beats. No significant arrhythmias detected.",
      "currentValue": "72 BPM",
      "normalRange": "60-100 BPM"
    },
    {
      "title": "Murmur Detection",
      "confidence": 78.9,
      "status": "warning",
      "description":
          "Mild systolic murmur detected. This may indicate minor valve irregularity or could be benign. Further evaluation recommended.",
      "currentValue": "Grade 2/6 Systolic",
      "normalRange": "No murmur"
    },
    {
      "title": "Rhythm Irregularities",
      "confidence": 85.4,
      "status": "abnormal",
      "description":
          "Occasional premature ventricular contractions (PVCs) detected. Pattern suggests possible stress-related arrhythmia.",
      "currentValue": "3-4 PVCs/minute",
      "normalRange": "0-1 PVCs/minute"
    },
    {
      "title": "S1/S2 Sound Analysis",
      "confidence": 94.1,
      "status": "normal",
      "description":
          "First and second heart sounds are clear and well-defined. Normal splitting patterns observed during respiratory cycle.",
      "currentValue": "Clear S1/S2",
      "normalRange": "Clear S1/S2"
    }
  ];

  final List<Map<String, dynamic>> _abnormalityMarkers = [
    {"timestamp": 12.5, "duration": 2.0, "type": "PVC", "severity": "mild"},
    {
      "timestamp": 28.3,
      "duration": 1.5,
      "type": "Murmur",
      "severity": "moderate"
    },
    {"timestamp": 38.7, "duration": 1.8, "type": "PVC", "severity": "mild"}
  ];

  @override
  void initState() {
    super.initState();
    _checkForCriticalFindings();
  }

  void _checkForCriticalFindings() {
    // Check if any findings are critical
    final hasCriticalFindings = _detailedFindings.any(
        (finding) => (finding['status'] as String).toLowerCase() == 'critical');

    if (hasCriticalFindings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEmergencyAlert = true;
        _showEmergencyAlertDialog();
      });
    }
  }

  void _showEmergencyAlertDialog() {
    EmergencyAlertModal.show(
      context,
      alertMessage:
          "The analysis has detected patterns that may require immediate medical attention. Irregular heart rhythms and abnormal sounds have been identified.",
      onContactEmergency: () {
        Navigator.of(context).pop();
        _contactEmergencyServices();
      },
      onDismiss: () {
        Navigator.of(context).pop();
        setState(() {
          _showEmergencyAlert = false;
        });
      },
    );
  }

  void _contactEmergencyServices() {
    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Show emergency contact options
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildEmergencyContactSheet(),
    );
  }

  Widget _buildEmergencyContactSheet() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Emergency Contacts',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildEmergencyContactOption(
            icon: 'local_hospital',
            title: 'Emergency Services',
            subtitle: 'Call 911',
            onTap: () {
              // Launch phone dialer with 911
            },
          ),
          SizedBox(height: 2.h),
          _buildEmergencyContactOption(
            icon: 'medical_services',
            title: 'Primary Care Physician',
            subtitle: 'Dr. Sarah Johnson',
            onTap: () {
              // Call primary care physician
            },
          ),
          SizedBox(height: 2.h),
          _buildEmergencyContactOption(
            icon: 'favorite',
            title: 'Cardiologist',
            subtitle: 'Dr. Michael Chen',
            onTap: () {
              // Call cardiologist
            },
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
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
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Analysis Results',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _shareAnalysis,
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // Analysis Summary Card
            AnalysisSummaryCard(
              analysisData: _analysisData,
            ),

            SizedBox(height: 2.h),

            // Audio Player Widget
            AudioPlayerWidget(
              audioFilePath: _analysisData['audioFilePath'] as String,
              abnormalityMarkers: _abnormalityMarkers,
            ),

            SizedBox(height: 2.h),

            // Detailed Findings Section
            DetailedFindingsSection(
              findings: _detailedFindings,
            ),

            SizedBox(height: 2.h),

            // Medical Disclaimer
            const MedicalDisclaimerWidget(),

            SizedBox(height: 2.h),

            // Action Buttons
            ActionButtonsSection(
              onSaveToHistory: _saveToHistory,
              onGenerateReport: _generateReport,
              onShareWithPhysician: _shareWithPhysician,
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _shareAnalysis() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Share Analysis',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption('email', 'Email', () {}),
                _buildShareOption('message', 'Message', () {}),
                _buildShareOption('cloud_upload', 'Cloud', () {}),
                _buildShareOption('print', 'Print', () {}),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 7.w,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveToHistory() {
    HapticFeedback.lightImpact();

    // Navigate to recording history
    Navigator.pushNamed(context, '/recording-history');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Analysis saved to history successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _generateReport() {
    HapticFeedback.lightImpact();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Generating PDF Report...',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );

    // Simulate report generation
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF report generated and saved to downloads'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

  void _shareWithPhysician() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Share with Physician',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will securely share your analysis results with your healthcare provider. Continue?',
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Analysis shared with Dr. Sarah Johnson'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text(
              'Share',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
